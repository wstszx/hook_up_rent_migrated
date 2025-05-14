import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hook_up_rent/pages/utils/common_toast.dart';
import 'package:hook_up_rent/pages/utils/dio_http.dart';
import 'package:hook_up_rent/pages/utils/scoped_model_helper.dart';
import 'package:hook_up_rent/scoped_model/auth.dart';
import 'package:hook_up_rent/widgets/room_appliance.dart';
// Import for filter data
import 'package:hook_up_rent/pages/home/tab_search/filter_bar/data.dart' as filter_data;
import 'package:image_picker/image_picker.dart'; // Needed for XFile type
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:mime/mime.dart'; // For lookupMimeType
import 'package:path/path.dart' as p; // For p.extension
import 'package:hook_up_rent/widgets/common_floating_button.dart';
import 'package:hook_up_rent/widgets/common_form_item.dart';
import 'package:hook_up_rent/widgets/common_image_picker.dart';
import 'package:hook_up_rent/widgets/common_radio_form_item.dart';
import 'package:hook_up_rent/widgets/common_select_form_item.dart';
import 'package:hook_up_rent/widgets/common_title.dart';

class RoomAddPage extends StatefulWidget {
  const RoomAddPage({Key? key}) : super(key: key);

  @override
  State<RoomAddPage> createState() => _RoomAddPageState();
}

class _RoomAddPageState extends State<RoomAddPage> {
  // --- Form Controllers ---
  var titleController = TextEditingController();
  var descController = TextEditingController();
  var communityController = TextEditingController(); // 将映射到 address
  var cityController = TextEditingController();
  var districtController = TextEditingController();
  var priceController = TextEditingController();
  var sizeController = TextEditingController(); // 将作为 tag

  // --- Selectable Options ---
  int rentType = 0; // 0: 合租, 1: 整租
  // String? selectedRoomTypeId; // Will be initialized in initState
  // String? selectedFloorId;    // Will be initialized in initState
  // String? selectedOrientedId; // Will be initialized in initState
  String selectedRoomTypeId = filter_data.roomTypeList.first.id;
  String selectedFloorId = filter_data.floorList.first.id;
  String selectedOrientedId = filter_data.orientedList.first.id;

  int decorationType = 0; // 0: 精装, 1: 简装 (将作为 tag)

  // --- Image Picker & Room Appliances ---
  List<File> _pickedImages = [];
  List<String> _selectedAppliances = [];


  // --- Helper methods for mapping int to String ---
  String _getRentTypeString(int val) => ['合租', '整租'][val];
  // String _getRoomTypeString(int val) => ['一室', '二室', '三室', '四室'][val]; // No longer needed
  // String _getFloorString(int val) => ['高楼层', '中楼层', '低楼层'][val]; // No longer needed
  // String _getOrientedString(int val) => ['东', '南', '西', '北'][val]; // No longer needed
  String _getDecorationTypeString(int val) => ['精装', '简装'][val];

  Future<void> _submit() async {
    // 1. Validate form data
    final title = titleController.text;
    final description = descController.text;
    final city = cityController.text;
    final district = districtController.text;
    final address = communityController.text; // 小区名作为地址
    final price = priceController.text;
    final size = sizeController.text;

    if (title.isEmpty || city.isEmpty || address.isEmpty || price.isEmpty) {
      CommonToast.showToast('标题、城市、小区和租金不能为空');
      return;
    }
    double? parsedPrice;
    try {
      parsedPrice = double.parse(price);
      if (parsedPrice <= 0) throw FormatException();
    } catch (e) {
      CommonToast.showToast('请输入有效的租金');
      return;
    }

    // 2. Prepare data for backend
    List<String> tags = [..._selectedAppliances];
    tags.add(_getDecorationTypeString(decorationType));
    if (size.isNotEmpty) {
      tags.add('$size平方米');
    }
    
    Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'price': parsedPrice,
      'city': city,
      'district': district,
      'address': address,
      'rentType': _getRentTypeString(rentType),
      'roomType': selectedRoomTypeId, // Use ID directly
      'floor': selectedFloorId,       // Use ID directly
      'orientation': selectedOrientedId, // Use ID directly
      'tags': tags,
      // 'roomImages' will be handled by FormData
    };

    // 3. Get token
    final auth = ScopedModelHelper.getModel<AuthModel>(context);
    if (!auth.isLogin || auth.token.isEmpty) {
      CommonToast.showToast('请先登录');
      // Optionally navigate to login page
      return;
    }
    final token = auth.token;

    // 4. Prepare FormData for image uploads
    FormData formData = FormData.fromMap(data);
    if (_pickedImages.isNotEmpty) {
      for (var i = 0; i < _pickedImages.length; i++) {
        File imageFile = _pickedImages[i];
        String? mimeTypeStr = lookupMimeType(imageFile.path);
        MediaType? mediaType;

        if (mimeTypeStr != null) {
          final parts = mimeTypeStr.split('/');
          if (parts.length == 2) {
            mediaType = MediaType(parts[0], parts[1]);
          }
        }

        // Fallback if MIME type couldn't be determined, though unlikely for valid images
        mediaType ??= MediaType('application', 'octet-stream');
        
        // Get file extension for the filename
        String extension = p.extension(imageFile.path); // e.g. '.jpg'
        if (extension.startsWith('.')) {
          extension = extension.substring(1); // remove leading dot -> 'jpg'
        }


        formData.files.add(MapEntry(
          'roomImages', // This must match the field name expected by Multer on the backend
          await MultipartFile.fromFile(
            imageFile.path,
            filename: 'room_image_$i.$extension', // Use dynamic extension
            contentType: mediaType,
          ),
        ));
      }
    }
    
    // 5. Send request
    CommonToast.showToast('正在提交...');
    print('Attempting to submit with token: "$token"'); // Debug: Print token
    try {
      var response = await DioHttp.of(context).post(
        '/api/rooms',
        data: formData, // Pass FormData directly as data
        token: token,
        // Dio will automatically set Content-Type for FormData if data is FormData
        // options: Options(contentType: 'multipart/form-data'), // This line is usually not needed if data is FormData and DioHttp.post is correctly modified
      );

      if (response.statusCode == 201) {
        CommonToast.showToast('房源发布成功！');
        if (mounted) {
          Navigator.of(context).pop(true); // Pop and indicate success
        }
      } else {
        String errorMessage = response.data?['message'] ?? '发布失败，请稍后再试';
        CommonToast.showToast(errorMessage);
      }
    } catch (e) {
      print('Error submitting room: $e');
      if (e is DioException && e.response?.data is Map) {
         CommonToast.showToast(e.response?.data['message'] ?? '提交失败，网络错误');
      } else {
        CommonToast.showToast('提交失败，请检查网络连接');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('房源发布'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CommonFloatingActionButton('提交', _submit), // Call _submit
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80), // Ensure space for FAB
        children: [
          const CommonTitle('房源信息'),
          CommonFormItem(
            label: '城市',
            hintText: '请输入城市，如：北京',
            controller: cityController,
          ),
          CommonFormItem(
            label: '行政区',
            hintText: '请输入行政区，如：海淀区 (可选)',
            controller: districtController,
          ),
          CommonFormItem(
            label: '小区/地址',
            hintText: '请输入小区名称或详细地址',
            controller: communityController,
          ),
          CommonFormItem(
            label: '租金',
            suffixText: '元/月',
            hintText: '请输入租金',
            controller: priceController,
            keyboardType: TextInputType.number,
          ),
          CommonFormItem(
            label: '大小',
            suffixText: '平方米',
            hintText: '请输入房屋大小 (将作为标签)',
            controller: sizeController,
            keyboardType: TextInputType.number,
          ),
          CommonRadioFormItem(
            label: '租赁方式',
            options: const ['合租', '整租'],
            value: rentType,
            onChange: (index) {
              setState(() => rentType = index!);
            },
          ),
          CommonSelectFormItem(
            label: '户型',
            value: filter_data.roomTypeList.indexWhere((item) => item.id == selectedRoomTypeId),
            onChange: (val) {
              if (val != null && val < filter_data.roomTypeList.length) {
                setState(() => selectedRoomTypeId = filter_data.roomTypeList[val].id);
              }
            },
            options: filter_data.roomTypeList.map((item) => item.name).toList(),
          ),
          CommonSelectFormItem(
            label: '楼层',
            value: filter_data.floorList.indexWhere((item) => item.id == selectedFloorId),
            onChange: (val) {
              if (val != null && val < filter_data.floorList.length) {
                setState(() => selectedFloorId = filter_data.floorList[val].id);
              }
            },
            options: filter_data.floorList.map((item) => item.name).toList(),
          ),
          CommonSelectFormItem(
            label: '朝向',
            value: filter_data.orientedList.indexWhere((item) => item.id == selectedOrientedId),
            onChange: (val) {
              if (val != null && val < filter_data.orientedList.length) {
                setState(() => selectedOrientedId = filter_data.orientedList[val].id);
              }
            },
            options: filter_data.orientedList.map((item) => item.name).toList(),
          ),
          CommonRadioFormItem(
            label: '装修',
            options: const ['精装', '简装'], // Will be added as a tag
            value: decorationType,
            onChange: (index) {
              setState(() => decorationType = index!);
            },
          ),
          const CommonTitle('房屋图像 (最多9张)'),
          CommonImagePicker(
            onChange: (xFiles) { // xFiles is List<XFile>
              setState(() {
                // Convert List<XFile> to List<File>
                _pickedImages = xFiles.map((xfile) => File(xfile.path)).toList();
              });
            },
          ),
          const CommonTitle('房屋标题'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: '请输入标题（例如：整租 小区名 二室 2000元）',
                border: InputBorder.none,
              ),
            ),
          ),
          const CommonTitle('房屋配置'),
          RoomAppliance( // Changed from named parameter to positional
            (selectedItems) { // selectedItems is List<RoomApplianceItem>
              setState(() {
                _selectedAppliances = selectedItems
                    .where((item) => item.isChecked) // Filter for checked items
                    .map((item) => item.title)       // Extract the title
                    .toList();                      // Convert to List<String>
              });
            },
          ),
          const CommonTitle('房屋描述'),
          Container(
            margin: const EdgeInsets.only(bottom: 100), // Keep margin for FAB
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: descController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '请输入房屋描述信息',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
