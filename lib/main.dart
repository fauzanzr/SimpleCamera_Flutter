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
  if (cameras.length > 2) {
    cameras = cameras.sublist(
        0, 2); // Penggunaan camera 0 dan 2
  }
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
  int selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.medium,
    );
    initializeControllerFuture = controller.initialize();
  }

  void onSwitchCamera() async {
    await controller.dispose();
    selectedCameraIndex =
        selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.medium,
    );
    initializeControllerFuture = controller.initialize();
    setState(() {});
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
          backgroundColor: Colors.deepPurple, // Bagian AppBar
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FloatingActionButton(
                  child: Icon(Icons.camera_alt),
                  backgroundColor:
                      Color((Random().nextDouble() * 0xFFFFFF).toInt())
                          .withOpacity(1.0),
                  onPressed: () async {
                    try {
                      await initializeControllerFuture;

                      await controller.setFlashMode(FlashMode.off);

                      final XFile photo = await controller.takePicture();

                      // Path untuk Penyimpanan gambar
                      print('Path picture: ${photo.path}');

                      // Save picture to gallery
                      final Directory directory =
                          await getApplicationDocumentsDirectory();
                      final String path =
                          '${directory.path}/${DateTime.now()}.png';
                      await File(photo.path).copy(path);
                      final result = await ImageGallerySaver.saveFile(path);
                      print('Saved to gallery: $result');
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
                FloatingActionButton(
                  child: Icon(Icons.switch_camera),
                  onPressed: onSwitchCamera,
                ),
              ],
            )));
  }
}
