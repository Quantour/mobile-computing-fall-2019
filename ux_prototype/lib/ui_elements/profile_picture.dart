

import 'package:flutter/widgets.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfilePictureWidget extends StatelessWidget {

  final String url;

  ProfilePictureWidget({this.url});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            ClipOval(
              child: Image.asset(
                "assets/images/blank_profile_picture.png",
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
    );
  }
}

