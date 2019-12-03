import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';


class Uploader extends StatefulWidget {
  final File file;

  Uploader({Key key, this.file}) : super(key: key);

  createState() => _UploaderState();

}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage =
  FirebaseStorage(storageBucket: 'gs://wanderlust-a2dd4.appspot.com/');

  StorageUploadTask _uploadTask;

  _startUpload() {
    String filePath = 'images/${DateTime.now()}.png';

    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file)
    });

    @override
    Widget build(BuildContext context) {
      if (_uploadTask != null) {
        return StreamBuilder <StorageTaskEvent>(
            stream: _uploadTask.events,
            builder: (context, snapshot) {
              var event = snapshot?.data?.snapshot;

              double progressPercent = event != null
                  ? event.bytesTransferred / event.totalByteCount
                  : 0;

              return Column(
                children: <Widget>[
                  if (_uploadTask.isComplete)
                    Text('Sucess'),
                  if (_uploadTask.isPaused)
                    FlatButton(
                      child: Icon(Icons.play_arrow),
                      onPressed: _uploadTask.resume,
                    ),
                  if (_uploadTask.isInProgress)
                    FlatButton(
                      child: Icon(Icons.pause),
                      onPressed: _uploadTask.pause,
                    ),


                  LinearProgressIndicator(value: progressPercent),
                  Text(
                      '${(progressPercent * 100).toStringAsFixed(2)} %'
                  ),
                ],
              );
            });
      } else {
        return FlatButton.icon(
          label: Text('Upload to Firebase'),
          icon: Icon(Icons.cloud_upload),
          onPressed: _startUpload,
        );
      }
    }
  }

}
/*
* This Method deletes a cloud image from the cloud
* and is given its URL
*/
Future<void> deleteCloudImage(String url) {
  //TODO: implement here
  return Future.value();
}

/*
* This Method uploades a image file
* to the cloud and returns the url
* of the image in a future
*/
Future<String> uploadCloudImage(File file) {
  //TODO: implement here
  return Future.value("http:cloud.com/my_image");
}


/*
 * Represents a Image which is either loaded from the network or choosen locally as a file
 */
class NetwOrFileImg {
  NetwOrFileImg({this.file, this.url});

  File file;
  String url;

  bool get isFile => file != null;

  bool get isNetw => url != null;

  ImageProvider get image {
    if (isFile)
      return FileImage(file);
    else if (isNetw)
      return NetworkImage(url);
    else
      return MemoryImage(kTransparentImage);
  }
}


/*
 * This function
 * 1) deletes all images from the cloud which occur
 *    in the list "orginal" but do not occur in the
 *    List "updated" as String
 * 2) uploads all file items in the List "updated"
 * 3) returns list of URLs of images in list "updated"
 *    (the Strings in "updated" are just returned and
 *    the urls to the uploaded files in "updated" are
 *    returned instead of the files itself)
 */
Future<List<String>> updateCloudImages(List<String> original,
    List<NetwOrFileImg> updated) async {
  //First: delete all images which occur in original,
  //but not in updated as network images
  List<String> updatedNetw = updated.where((nf) => nf.isNetw).map((nf) =>
  nf.url);
  for (String url in original) {
    if (!updatedNetw.contains(url)) {
      await deleteCloudImage(url);
    }
  }

  //upload all files if neccessarry and build returned list
  List<String> ret = [];
  for (NetwOrFileImg nf in updated) {
    if (nf.isNetw) {
      ret.add(nf.url);
    } else {
      String url = await uploadCloudImage(nf.file);
      ret.add(url);
    }
  }
  return ret;
}


/*
 * This function
 * 1) uploads all file items in the List "updated"
 * 2) returns list of URLs of images in list "updated"
 *    (the Strings in "updated" are just returned and
 *    the urls to the uploaded files in "updated" are
 *    returned instead of the files itself)
 */
Future<List<String>> uploadCloudImages(List<NetwOrFileImg> updated) {
  return updateCloudImages([], updated);
}