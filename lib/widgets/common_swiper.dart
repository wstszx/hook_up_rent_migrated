import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages, import_of_legacy_library_into_null_safe
// import 'package:flutter_swiper/flutter_swiper.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:rent_share/widgets/common_image.dart';

const List<String> defaultImages = [
  'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80', // House with large windows
  'https://images.unsplash.com/photo-1501183638710-841dd1904471', // Interior with plants
  'https://images.unsplash.com/photo-1570129477492-45c003edd2be', // House with a pool
  'https://images.unsplash.com/photo-1568605114967-8130f3a36994?ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80', // Modern house with garage
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
            fit: BoxFit.cover,
          );
        },
        itemCount: images.length, // Use the actual length of the images list
        pagination: images.length > 1 ? const SwiperPagination() : null, // Only show pagination if there's more than one image
        // control: const SwiperControl(),
      ),
    );
  }
}

