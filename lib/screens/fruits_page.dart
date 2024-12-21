import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FruitsPage extends StatefulWidget {
  @override
  _FruitsPageState createState() => _FruitsPageState();
}

class _FruitsPageState extends State<FruitsPage> {
  File? _image;
  List? _output;
  bool _loading = false;
  Interpreter? _interpreter;
  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/fruit_model.tflite');
      String labelFile = await DefaultAssetBundle.of(context).loadString('assets/models/fruit_labels.txt');
      _labels = labelFile.split('\n');
      print("Model and labels loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> classifyImage(File image) async {
    var inputImage = await image.readAsBytes();
    var input = await _preprocessImage(inputImage);

    var output = List.filled(1, List.filled(12, 0.0));
    _interpreter?.run(input, output);
    print("Output shape: ${output.length}, ${output[0].length}");

    if (output[0].isEmpty) {
      print("Output is empty");
      return;
    }

    int predictedClassIndex = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));

    if (predictedClassIndex < 0 || predictedClassIndex >= _labels.length) {
      print("Invalid predicted class index: $predictedClassIndex");
      return;
    }

    String predictedClassLabel = _labels[predictedClassIndex];

    setState(() {
      _output = [predictedClassLabel];
      _loading = false;
    });
  }

  Future<List<List<List<List<int>>>>> _preprocessImage(List<int> imageBytes) async {
    img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));

    if (image == null) {
      throw Exception("Unable to decode image");
    }

    img.Image resizedImage = img.copyResize(image, width: 32, height: 32);

    var imageTensor = List.generate(1, (i) {
      return List.generate(32, (j) {
        return List.generate(32, (k) {
          var pixel = resizedImage.getPixel(k, j);
          return [
            img.getRed(pixel),
            img.getGreen(pixel),
            img.getBlue(pixel),
          ];
        });
      });
    });

    return imageTensor;
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _loading = true;
        _image = File(image.path);
      });
      classifyImage(File(image.path));
    }
  }

  Future<void> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _loading = true;
        _image = File(image.path);
      });
      classifyImage(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fruits Classifier", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFF4A90E2),  // Blue gradient background
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    // Display image in a sleek card
                    Card(
                      elevation: 15,
                      shadowColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: _image == null
                            ? Text("No image selected", style: TextStyle(fontSize: 18, fontFamily: 'Poppins'))
                            : Image.file(_image!, height: 250, width: 250, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(height: 25),
                    // Display prediction result in a modern card
                    _output != null
                        ? Card(
                            elevation: 10,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "Predicted: ${_output![0]}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(height: 20),
                    // Image selection buttons with modern style
                    ElevatedButton(
                      onPressed: pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF0F0F0),  // Light grey background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        elevation: 8,
                      ),
                      child: Text("Pick Image from Gallery", style: TextStyle(fontSize: 16, fontFamily: 'Poppins')),
                    ),
                    SizedBox(height: 15),
                    FloatingActionButton(
                      onPressed: pickImageFromCamera,
                      backgroundColor: Colors.green,
                      elevation: 10,
                      child: Icon(Icons.camera_alt, size: 35, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
