import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomeProvider extends ChangeNotifier {
  static const String ssd = 'SSD MobileNet';
  static const String yolo = 'Tiny YOLOv2';

  final String model = ssd;
  File? image;

  double? imageWidth;
  double? imageHeight;

  bool busy = false;

  List? recognitions2;

  void initTFLite() {
    loadModel().then((_) {
      busy = false;
      notifyListeners();
    });
  }

  Future<void> loadModel() async {
    Tflite.close();
    try {
      String? res;
      if (model == yolo) {
        res = await Tflite.loadModel(
          model: 'assets/tflite/yolov2_tiny.tflite',
          labels: 'assets/tflite/yolov2_tiny.txt',
        );
      } else {
        res = await Tflite.loadModel(
          model: 'assets/tflite/ssd_mobilenet.tflite',
          labels: 'assets/tflite/ssd_mobilenet.txt',
        );
      }
      print(res);
    } on PlatformException {
      print('Failed to load the model');
    }
  }

  Future<void> ssdMobileNet(File imageFile) async {
    var recognitions = await Tflite.detectObjectOnImage(
      path: imageFile.path,
      numResultsPerClass: 1,
    );

    recognitions2 = recognitions;
    print(
      "this is image ssdMobileNet ${imageFile.path} \nlength ${recognitions2!.length}",
    );

    notifyListeners();
  }

  List<Widget> renderBoxes(Size screen) {
    if (recognitions2 == null) return [];

    if (imageWidth == null || imageHeight == null) return [];

    double factorX = screen.width;
    double factorY = imageHeight! / imageWidth! * screen.width;

    Color _blue = Colors.blue;

    return recognitions2!
        .map((re) => Positioned(
              left: re['rect']['x'] * factorX,
              top: re['rect']['y'] * factorY,
              width: re['rect']['w'] * factorX,
              height: re['rect']['h'] * factorY,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  ),
                ),
                child: Text(
                  "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    backgroundColor: _blue,
                  ),
                ),
              ),
            ))
        .toList();
  }

  Future<void> selectFromImagePicker() async {
    var imageRaw = await ImagePicker()
        .pickImage(source: ImageSource.gallery)
        .then((value) => value?.path);

    if (imageRaw == null) return;

    File? imageFile = File(imageRaw);

    busy = true;
    notifyListeners();
    await predictImage(imageFile);
  }

  Future<void> predictImage(File imageFile) async {
    if (imageFile == null) return;

    if (model == yolo) {
      await yolov2Tiny(imageFile);
    } else {
      await ssdMobileNet(imageFile);
    }

    FileImage(imageFile)
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((imageInfo, _) {
      imageWidth = imageInfo.image.width.toDouble();
      imageHeight = imageInfo.image.height.toDouble();
      notifyListeners();
    }));

    image = imageFile;
    busy = false;
    notifyListeners();
  }

  Future<void> yolov2Tiny(File imageFile) async {
    var recognitions = await Tflite.detectObjectOnImage(
      path: imageFile.path,
      model: "YOLO",
      threshold: 0.3,
      imageMean: 0.0,
      imageStd: 255.0,
      numResultsPerClass: 1,
    );

    recognitions2 = recognitions;
    notifyListeners();
  }

  List<Widget> stackChildren = [];

  void stackAdded(BuildContext context, Size size) {
    stackChildren.clear();
    stackChildren.add(
      Positioned(
        left: 0.0,
        top: 0.0,
        width: size.width,
        child: image == null
            ? const Text('No Image Selected')
            : Image.file(image!),
      ),
    );
    stackChildren.addAll(renderBoxes(size));
  }

  String getHighestClass() {
    if (recognitions2 == null || recognitions2!.isEmpty) return 'N/A';
    print("this recognitions2 ${recognitions2!}");
    print("this recognitions2 ${recognitions2![0]}");
    print("this recognitions2 ${recognitions2![0]['detectedClass']}");
    return recognitions2![0]['detectedClass'];
  }

  double getHighestConfidence() {
    if (recognitions2 == null || recognitions2!.isEmpty) return 0.0;

    return recognitions2![0]['confidenceInClass'];
  }
}
