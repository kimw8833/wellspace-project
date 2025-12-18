import 'package:flutter/material.dart';
import '../../utils/sprite_paths.dart';

class FriendPictureSprite extends StatelessWidget {
  final double width;

  const FriendPictureSprite({
    super.key,
    this.width = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Image.asset("assets/images/additional/friendpicture.png"),
    );
  }
}
