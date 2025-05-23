import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rent_share/config.dart';

final networkUriReg = RegExp('^http'); // 网络图片正则
final localUriReg = RegExp('^static'); // 本地图片正则

class CommonImage extends StatelessWidget {
  final String src;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const CommonImage(this.src, {super.key, this.width, this.height, this.fit});

  @override
  Widget build(BuildContext context) {
    if (src.startsWith('/uploads/')) {
      return CachedNetworkImage(
        imageUrl: '${Config.apiBaseUrl}$src',
        width: width,
        height: height,
        fit: fit,
      );
    } else if (networkUriReg.hasMatch(src)) {
      return CachedNetworkImage(
        imageUrl: src,
        width: width,
        height: height,
        fit: fit,
      );
    } else if (localUriReg.hasMatch(src)) {
      return Image.asset(
        src,
        width: width,
        height: height,
        fit: fit,
      );
    }
    assert(false, '图片地址 src 不合法');
    return Container();
  }
}
