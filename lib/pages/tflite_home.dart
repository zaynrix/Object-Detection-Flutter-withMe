import 'package:flutter/material.dart';
import 'package:objectsdetections/providers/home_provider.dart';
import 'package:provider/provider.dart';

class TFLiteHome extends StatefulWidget {
  const TFLiteHome({Key? key}) : super(key: key);

  @override
  _TFLiteHomeState createState() => _TFLiteHomeState();
}

class _TFLiteHomeState extends State<TFLiteHome> {
  HomeProvider? _homeProvider;

  @override
  void initState() {
    super.initState();
    _homeProvider = Provider.of<HomeProvider>(context, listen: false);
    _homeProvider!.initTFLite();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, instance, child) {
      instance.stackAdded(context, MediaQuery.of(context).size);
      String highestClass = instance.getHighestClass();
      double highestConfidence = instance.getHighestConfidence();

      return Scaffold(
        appBar: AppBar(
          title: const Text('TensorFlow Lite Demo'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => instance.selectFromImagePicker(),
          tooltip: 'Select image from gallery',
          child: const Icon(Icons.image),
        ),
        body: Stack(
          children: [
            ...instance.stackChildren,
            Positioned(
              bottom: 16.0,
              left: 16.0,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Highest Class: $highestClass\nConfidence: ${(highestConfidence * 100).toStringAsFixed(2)}%',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
