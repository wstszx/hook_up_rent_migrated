import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages, import_of_legacy_library_into_null_safe
// import 'package:flutter_swiper/flutter_swiper.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:hook_up_rent/widgets/common_image.dart';

const List<String> defaultImages = [
  'https://images.unsplash.com/photo-1523217582562-09d0def993a6', // Modern house
  'https://images.unsplash.com/photo-1501183638710-841dd1904471', // Interior with plants
  'https://images.unsplash.com/photo-1570129477492-45c003edd2be', // House with a pool
  'https://images.unsplash.com/photo-1580587771525-78b9dba3b914', // Luxury house
];

var imageWidth = 424;
var imageHeight = 750;

class CommonSwiper extends StatelessWidget {
  final List<String> images;

  const CommonSwiper({Key? key, this.images = defaultImages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width * imageWidth / imageHeight,
      child: Swiper(
        autoplay: true,
        itemBuilder: (BuildContext context, int index) {
          return CommonImage(
            images[index],
            fit: BoxFit.fill,
          );
        },
        itemCount: images.length, // Use the actual length of the images list
        pagination: images.length > 1 ? const SwiperPagination() : null, // Only show pagination if there's more than one image
        // control: const SwiperControl(),
      ),
    );
  }
}
