

import 'package:flutter/widgets.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfilePictureWidget extends StatelessWidget {

  final String url;
  final String placeholderAsset;
  final void Function() onPress;

  ProfilePictureWidget({this.url, this.onPress, this.placeholderAsset = "assets/images/blank_profile_picture.png"});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Align(
        alignment: Alignment.topLeft,
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              ClipOval(
                child: Image.asset(
                  placeholderAsset,
                  fit: BoxFit.cover
                )
              ),
              if (this.url!=null)
              ClipOval(
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: this.url,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          )
        )
      ),
    );
  }
}

