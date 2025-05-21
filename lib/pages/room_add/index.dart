import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rent_share/pages/utils/common_toast.dart';
import 'package:rent_share/pages/utils/dio_http.dart';
import 'package:rent_share/pages/utils/scoped_model_helper.dart';
import 'package:rent_share/scoped_model/auth.dart';
import 'package:rent_share/widgets/room_appliance.dart';
// Import for filter data
import 'package:rent_share/pages/home/tab_search/filter_bar/data.dart' as filter_data;
import 'package:image_picker/image_picker.dart'; // Needed for XFile type
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:mime/mime.dart'; // For lookupMimeType
import 'package:path/path.dart' as p; // For p.extension
import 'package:rent_share/widgets/common_floating_button.dart';
import 'package:rent_share/widgets/common_form_item.dart';
import 'package:rent_share/widgets/common_image_picker.dart';
import 'package:rent_share/widgets/common_radio_form_item.dart';
import 'package:rent_share/widgets/common_select_form_item.dart';
import 'package:rent_share/widgets/common_title.dart';
import 'package:rent_share/services/region_service.dart'; // 引入 RegionService

class RoomAddPage extends StatefulWidget {
  final bool isEdit;
  final String? roomIdForEdit; // Add roomIdForEdit parameter
  const RoomAddPage({Key? key, this.isEdit = false, this.roomIdForEdit}) : super(key: key);

  @override
  State<RoomAddPage> createState() => _RoomAddPageState();
}

class _RoomAddPageState extends State<RoomAddPage> {
  bool isLoading = false;
  // --- Form Controllers ---
  var titleController = TextEditingController();
  var descController = TextEditingController();
  var communityController = TextEditingController(); // 将映射到 address
  // --- City and District Data ---
  List<filter_data.GeneralType> _cities = [];
  List<filter_data.GeneralType> _districts = [filter_data.GeneralType('不限', 'area_any')];
  String? _selectedCityName;
  String? _selectedDistrict;

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

  @override
  void initState() {
    super.initState();
    _loadCityDistrictData();

    // If in edit mode and roomId is provided, load room data
    if (widget.isEdit && widget.roomIdForEdit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRoomData(widget.roomIdForEdit!);
      });
    }
  }

  // Load room data for editing
  Future<void> _loadRoomData(String id) async {
    try {
      final auth = ScopedModelHelper.getModel<AuthModel>(context);
      final token = auth.token;

      final DioHttp dioHttp = DioHttp.of(context);

      // Fetch single room data using GET request
      final response = await dioHttp.get('/api/rooms/$id', null, token);

      // Correctly access the room data directly from response.data
      final data = response.data;
      print('Loaded room data: $data'); // Add this line to print the data
      // Check if data is a Map and not null before proceeding
      if (data != null && data is Map<String, dynamic>) {
        // Set form values from loaded data
        setState(() {
          titleController.text = data['title'] ?? '';
          descController.text = data['description'] ?? '';
          communityController.text = data['address'] ?? '';
          priceController.text = data['price']?.toString() ?? '';
          // Extract size from tags
          final tags = data['tags'] as List?;
          if (tags != null) {
            final sizeTag = tags.firstWhere(
                (tag) => tag.endsWith('平方米'),
                orElse: () => null);
            if (sizeTag != null) {
              // Extract the number part before "平方米"
              final sizeMatch = RegExp(r'(\d+)\s*平方米').firstMatch(sizeTag);
              if (sizeMatch != null && sizeMatch.groupCount > 0) {
                sizeController.text = sizeMatch.group(1) ?? '';
              }
            }

            // Set decoration type from tags
            decorationType = tags.contains('精装') ? 0 : 1;

            // Set appliances from tags
            _selectedAppliances = tags.where((tag) =>
                !['精装', '简装'].contains(tag) && !tag.endsWith('平方米')).cast<String>().toList(); // Exclude size tag
          }


          // Set city and district
          _selectedCityName = data['city'];
          _selectedDistrict = data['district'];

          // Set rent type
          rentType = data['rentType'] == '整租' ? 1 : 0;

          // Set room type, floor, and orientation by finding the corresponding ID
          selectedRoomTypeId = filter_data.roomTypeList
              .firstWhere((item) => item.name == data['roomType'],
                  orElse: () => filter_data.roomTypeList.first).id;

          selectedFloorId = filter_data.floorList
              .firstWhere((item) => item.name == data['floor'],
                  orElse: () => filter_data.floorList.first).id;

          selectedOrientedId = filter_data.orientedList
              .firstWhere((item) => item.name == data['oriented'],
                  orElse: () => filter_data.orientedList.first).id;


          // Set images if available (Note: We can't directly set _pickedImages with remote URLs)
          // You might need a different approach to display existing images,
          // perhaps a separate list of image URLs.
          if (data['images'] != null && data['images'] is List) {
             // Handle displaying existing images if needed
          }

          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading room data: $e');
      CommonToast.showToast('获取房源数据失败');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCityDistrictData() async {
    try {
      // 确保 RegionService 已加载数据
      await RegionService.loadRegionData();

      setState(() {
        _cities = RegionService.getCityList();

        // 预选第一个城市
        if (_cities.isNotEmpty) {
          _selectedCityName = _cities.first.name;
          _districts = RegionService.getDistrictsByCityName(_selectedCityName!);

          // 预选第一个区域
          if (_districts.isNotEmpty) {
            _selectedDistrict = _districts.isNotEmpty ? _districts.first.name : null;
          }
        }
      });
    } catch (e) {
      print('Error loading city and district data: $e');
      CommonToast.showToast('获取城市和行政区数据失败');
    }
  }

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
    // Determine if this is an add or update operation
    final bool isUpdate = widget.isEdit && widget.roomIdForEdit != null;
    // 1. Validate form data
    final title = titleController.text;
    final description = descController.text;
    // 使用选择的城市和区域名称
    final city = _selectedCityName ?? '';
    final district = _selectedDistrict ?? '';
    final address = communityController.text; // 小区名作为地址
    final price = priceController.text;
    final size = sizeController.text;

    // 创建一个列表来收集所有缺失的字段
    List<String> missingFields = [];

    // 检查所有必填字段
    if (title.isEmpty) missingFields.add('标题');
    if (city.isEmpty) missingFields.add('城市');
    if (district.isEmpty) missingFields.add('行政区');
    if (address.isEmpty) missingFields.add('小区/地址');
    if (price.isEmpty) missingFields.add('租金');
    // Note: For editing, images might already exist. You might need to adjust this validation.
    if (_pickedImages.isEmpty && !isUpdate) missingFields.add('房屋图像');

    // 如果有缺失字段，显示具体的错误信息
    if (missingFields.isNotEmpty) {
      CommonToast.showToast('请填写以下必填项: ${missingFields.join('、')}');
      return;
    }

    // 验证租金格式
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

    Map<String, dynamic> params = {
      if (isUpdate) 'id': widget.roomIdForEdit, // Use widget.roomIdForEdit
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
    FormData formData = FormData.fromMap(params);
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
      // Use PUT for update, POST for add
      var response = isUpdate
          ? await DioHttp.of(context).put(
              '/api/rooms/${widget.roomIdForEdit}', // Use PUT endpoint with ID
              data: formData,
              token: token,
            )
          : await DioHttp.of(context).post(
              '/api/rooms', // Use POST endpoint for new room
              data: formData,
              token: token,
            );


      if (response.statusCode == 201 || response.statusCode == 200) { // 201 for create, 200 for update
        CommonToast.showToast(isUpdate ? '房源更新成功！' : '房源发布成功！');
        if (mounted) {
          Navigator.of(context).pop(true); // Pop and indicate success
        }
      } else {
        String errorMessage = response.data?['message'] ?? (isUpdate ? '更新失败，请稍后再试' : '发布失败，请稍后再试');
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
      appBar: AppBar(title: Text(widget.isEdit ? '编辑房源' : '发布房源')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CommonFloatingActionButton('提交', _submit), // Call _submit
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80), // Ensure space for FAB
        children: [
          const CommonTitle('房源信息'),
          // 城市选择
          CommonSelectFormItem(
            label: '城市',
            value: _cities.indexWhere((item) => item.name == _selectedCityName),
            onChange: (val) {
              if (val != null && val < _cities.length) {
                setState(() {
                  _selectedCityName = _cities[val].name;
                  _districts = RegionService.getDistrictsByCityName(_selectedCityName!);
                  // 重置选中的区域
                  _selectedDistrict = _districts.isNotEmpty ? _districts.first.name : null;
                });
              }
            },
            options: _cities.map((item) => item.name).toList(),
          ),
          // 区域选择
          if (_districts.isNotEmpty) // Keep this check
            CommonSelectFormItem(
              label: '行政区',
              value: _districts.indexWhere((item) => item.name == _selectedDistrict),
              onChange: (val) {
                if (val != null && val < _districts.length) {
                  setState(() {
                    _selectedDistrict = _districts[val].name;
                  });
                }
              },
              options: _districts.map((item) => item.name).toList(),
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
