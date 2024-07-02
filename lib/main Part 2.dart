import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:math';
// import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'splash_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(CameraApp());
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  late Future<void> initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      cameras[1],
      ResolutionPreset.medium,
    );
    initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('(Camera) - Fauzan ZR'),
          backgroundColor: Colors.deepPurple, // Set AppBar color to deep purple
        ),
        body: FutureBuilder<void>(
          future: initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: CameraPreview(controller),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
            margin: EdgeInsets.only(bottom: 40.0),
            child: FloatingActionButton(
              child: Icon(Icons.camera_alt),
              backgroundColor: Color((Random().nextDouble() * 0xFFFFFF).toInt())
                  .withOpacity(1.0),
              onPressed: () async {
                try {
                  await initializeControllerFuture;

                  await controller.setFlashMode(FlashMode.off);

                  final XFile photo = await controller.takePicture();

                  // If you want to get the path of the picture
                  print('Path of the picture is: ${photo.path}');

                  // Save the picture to the gallery
                  final Directory directory =
                      await getApplicationDocumentsDirectory();
                  final String path = '${directory.path}/${DateTime.now()}.png';
                  await File(photo.path).copy(path);
                  final result = await ImageGallerySaver.saveFile(path);
                  print('Saved to gallery: $result');
                } catch (e) {
                  print(e);
                }
              },
            )
          )
        );
  }
}
