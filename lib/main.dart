import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import './Check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // File _file = File("zz");
  String url = "z1";
  var textResult = "Select an Image";
  String matched = "";
  final TextEditingController patternController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Upload Image"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              (url == "z1")
                  ? Image.asset("assets/img/images.jpeg")
                  : Image.network(url),
              SizedBox(
                height: 20,
                width: double.infinity,
              ),
              TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a search term'),
                controller: patternController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () => uploadImage(), child: Text("Upload")),
                  ElevatedButton(
                      onPressed: () {
                        var list =
                            searchKMP(textResult, patternController.text);
                        matched = "";
                        setState(() {
                          list.forEach((element) {
                            matched = matched + element + "\n";
                          });
                        });
                      },
                      child: Text("Check"))
                ],
              ),
              SizedBox(
                height: 10,
                width: double.infinity,
              ),
              Text("Detected Text: " + textResult),
              SizedBox(
                height: 10,
                width: double.infinity,
              ),
              Text("Matched Text: " + matched),
            ],
          ),
        ));
  }

  var selected;

  uploadImage() async {
    var permissionStatus = requestPermissions();

    // MOBILE
    if (!kIsWeb && await permissionStatus.isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        var sel = result.files.first;
        var a;

        selected = File(sel.path);
        try {
          var snapshot = firebase_storage.FirebaseStorage.instance
              .ref(sel.name)
              .putFile(selected)
              .snapshot;
          a = await snapshot.ref.getDownloadURL();
        } catch (e) {
          showToast("Failed to upload image");
        }
        setState(() {
          url = a;
          textResult = "Loading...";
        });
        performTextExtraction();
      } else {
        showToast("No file selected");
      }
    } else {
      showToast("Permission not granted");
    }
  }

  performTextExtraction() async {
    final recognizer = GoogleMlKit.vision.textDetector();

    InputImage i = new InputImage.fromFile(selected);
    RecognisedText recognizedText = await recognizer.processImage(i);

    String tr = "";
    for (TextBlock block in recognizedText.blocks) {
      // ignore: unused_local_variable
      String bl = block.text;

      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          tr += element.text + " ";
        }
      }
    }
    setState(() {
      if (textResult == "")
        textResult = "Sorry!!\n\n No text detected!";
      else
        textResult = tr;
    });
  }

  Future<PermissionStatus> requestPermissions() async {
    await Permission.photos.request();
    return Permission.photos.status;
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
