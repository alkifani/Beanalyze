import 'dart:io';
import 'dart:typed_data';
import 'package:beanalyze/configure/constants.dart';
import 'package:beanalyze/home/jenis_biji_kopi.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class ObjectDetectionCamera extends StatefulWidget {
  const ObjectDetectionCamera({Key? key}) : super(key: key);

  @override
  State<ObjectDetectionCamera> createState() => _ObjectDetectionCameraState();
}

class _ObjectDetectionCameraState extends State<ObjectDetectionCamera> {

  List<ResultObjectDetection>? objectDetectionResults;
  Duration? objectDetectionInferenceTime;
  File? _image;
  ModelObjectDetection? _objectModel;
  bool _isLoading = false; // Add loading state
  List<ResultObjectDetection>? objDetect2 = [];
  ModelObjectDetection? _objectModelYoloV11;
  String? usedModelName; // Untuk menampilkan model yang digunakan

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    String pathObjectDetectionModelYolov11 = "assets/models/yolov11.torchscript";
    String pathObjectDetectionModel = "assets/models/yolov5.torchscript";
    try {
      _objectModelYoloV11 = await PytorchLite.loadObjectDetectionModel(
          pathObjectDetectionModelYolov11,
          4,
          640,
          640,
          labelPath: "assets/labels/labels.txt",
          objectDetectionModelType: ObjectDetectionModelType.yolov8
      );
      _objectModel = await PytorchLite.loadObjectDetectionModel(
        pathObjectDetectionModel, 4, 256, 256,
        labelPath: "assets/labels/labels.txt",
      );
      print("Model pada kamera berhasil diload");
    } catch (e) {
      print("Error loading model: $e");
    }
  }


  Future runModels() async {
    setState(() {
      _isLoading = true;
      usedModelName = null;
    });
    await Future.delayed(Duration(milliseconds: 10)); // memberi ruang render UI

    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage == null) {
      setState(() => _isLoading = false);
      return;
    }

    File image = File(pickedImage.path);
    Uint8List imageBytes = await image.readAsBytes(); // Read bytes once

    // Jalankan model deteksi objek
    try {
      Stopwatch stopwatch = Stopwatch()..start();
      objectDetectionResults = await _objectModel?.getImagePrediction(
        imageBytes,
        minimumScore: 0.1,
        iOUThreshold: 0.3,
      );
      objectDetectionInferenceTime = stopwatch.elapsed;

      print('object executed in ${stopwatch.elapsed.inMilliseconds} ms');

      if (objectDetectionResults != null && objectDetectionResults!.isNotEmpty) {
        for (var element in objectDetectionResults!) {
          print({
            "score": element?.score,
            "className": element?.className,
            "class": element?.classIndex,
            "rect": {
              "left": element?.rect.left,
              "top": element?.rect.top,
              "width": element?.rect.width,
              "height": element?.rect.height,
              "right": element?.rect.right,
              "bottom": element?.rect.bottom,
            },
          });
        }
      }

      // menghitung jumlah object deteksi
      if (objectDetectionResults != null && objectDetectionResults!.isNotEmpty) {
        final detectedClasses = objectDetectionResults!.map((e) => e.className).toList();
        final typeCount = <String, int>{};

        for (var type in detectedClasses) {
          if (type != null) {
            typeCount[type] = (typeCount[type] ?? 0) + 1;
          }
        }

        final mostDetected = typeCount.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

        List<JenisKopi> detectedtypes = DataJenisKopi
            .kopiList
            .where((namakopi) => mostDetected.contains(namakopi.namaKopi))
            .toList();
        print("object terdeteksi $mostDetected");

        if (detectedtypes.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Detail Jenis Kopi Terdeteksi"),
              content: SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: detectedtypes.length,
                  itemBuilder: (context, index) {
                    final jeniskopi = detectedtypes[index];
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jeniskopi.namaKopi,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Ciri-Ciri: ${jeniskopi.ciriciri.join(', ')}"),
                          const SizedBox(height: 8),
                          Text("Rasa Kopi: ${jeniskopi.rasa.join(', ')}"),
                          const Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK", style: TextStyle(color: Colors.black),),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print("Error during object detection: $e");
    } finally {
      setState(() {
        _image = image;
        _isLoading = false;
      });
    }
  }

  Future runObjectDetectionYoloV11() async {
    setState(() {
      _isLoading = true;
      usedModelName = null;
    });

    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage == null) {
      setState(() => _isLoading = false);
      return;
    }

    File image = File(pickedImage.path);
    Uint8List imageBytes = await image.readAsBytes();

    Stopwatch stopwatch = Stopwatch()..start();
    if (_objectModelYoloV11 != null) {
      objDetect2 = await _objectModelYoloV11!.getImagePrediction(
        imageBytes,
        minimumScore: 0.1,
        iOUThreshold: 0.3,
      );
    }
    objectDetectionInferenceTime = stopwatch.elapsed;

    bool isYoloV11ResultValid = objDetect2 != null && objDetect2!.isNotEmpty;

    // ⛔️ fallback kalau YOLOv11 tidak mendeteksi
    if (!isYoloV11ResultValid) {
      print("Fallback ke model default karena YOLOv11 tidak mendeteksi objek.");

      Stopwatch fallbackStopwatch = Stopwatch()..start();
      objectDetectionResults = await _objectModel?.getImagePrediction(
        imageBytes,
        minimumScore: 0.1,
        iOUThreshold: 0.3,
      );
      objectDetectionInferenceTime = fallbackStopwatch.elapsed;
    }

    // Gunakan hasil yang valid
    final usedDetection = isYoloV11ResultValid ? objDetect2 : objectDetectionResults;
    usedModelName = isYoloV11ResultValid ? "YOLOv11" : "YOLOv5";

    // Debug print
    if (usedDetection != null) {
      for (var element in usedDetection) {
        print({
          "score": element?.score,
          "className": element?.className,
          "class": element?.classIndex,
          "rect": {
            "left": element?.rect.left,
            "top": element?.rect.top,
            "width": element?.rect.width,
            "height": element?.rect.height,
            "right": element?.rect.right,
            "bottom": element?.rect.bottom,
          },
        });
      }
    }

    setState(() {
      _image = image;
      _isLoading = false;
    });

    // 🔁 Proses hasil fallback atau YOLOv11
    final detectionToProcess = usedDetection;
    if (detectionToProcess != null && detectionToProcess.isNotEmpty) {
      final detectedClasses = detectionToProcess.map((e) => e.className).toList();
      final typeCount = <String, int>{};

      for (var type in detectedClasses) {
        if (type != null) {
          typeCount[type] = (typeCount[type] ?? 0) + 1;
        }
      }

      final mostDetected = typeCount.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      List<JenisKopi> detectedtypes = DataJenisKopi.kopiList
          .where((kopi) => mostDetected.contains(kopi.namaKopi))
          .toList();

      print("object terdeteksi $mostDetected");

      if (detectedtypes.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Detail Jenis Kopi Terdeteksi"),
            content: SizedBox(
              height: 100,
              child: ListView.builder(
                itemCount: detectedtypes.length,
                itemBuilder: (context, index) {
                  final jeniskopi = detectedtypes[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(jeniskopi.namaKopi,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("Ciri-Ciri: ${jeniskopi.ciriciri.join(', ')}"),
                      const SizedBox(height: 8),
                      Text("Rasa Kopi: ${jeniskopi.rasa.join(', ')}"),
                      const Divider(),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: header,)) // Show loading indicator
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null) ...[
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.5,
                width: MediaQuery.sizeOf(context).width * 0.95,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: (() {
                    final isYoloV11Valid = (_objectModelYoloV11 != null && objDetect2 != null && objDetect2!.isNotEmpty);
                    final usedModel = isYoloV11Valid ? _objectModelYoloV11! : _objectModel!;
                    final usedResults = isYoloV11Valid ? objDetect2! : (objectDetectionResults ?? []);
                    return usedModel.renderBoxesOnImage(_image!, usedResults);
                  })(),
                  // child: _objectModel!.renderBoxesOnImage(
                  //     _image!, objectDetectionResults ?? []),
                ),
              ),
              // const SizedBox(height: 10),
              if (usedModelName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    "Model digunakan: $usedModelName",
                    style: const TextStyle(
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                "Object Detection Time: "
                    "${objectDetectionInferenceTime?.inMilliseconds ??
                    "N/A"} ms",
                style: const TextStyle( color: textbiasa),
              ),
              if (objDetect2 != null && objDetect2!.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "YOLOv11 tidak mendeteksi objek, menggunakan model fallback.",
                    style: TextStyle(
                        color: Colors.orange,
                        fontStyle: FontStyle.italic),
                  ),
                ),
            ],
            Container(
              height: 45,
              width: MediaQuery.of(context).size.width / 2.25,
              child: ElevatedButton(
                // onPressed: runModels,
                onPressed: runObjectDetectionYoloV11, // 🔁 Ganti ke fungsi YOLOv11
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  backgroundColor:
                  MaterialStateProperty.all<Color>(button),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _image == null ? 'Deteksi' : 'Ambil Ulang',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: textbutton),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      _image == null
                          ? Icons.camera
                          : Icons.restart_alt_rounded,
                      color: texticon,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}