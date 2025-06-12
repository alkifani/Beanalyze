import 'dart:io';

import 'package:beanalyze/configure/constants.dart';
import 'package:beanalyze/home/jenis_biji_kopi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pytorch_lite/lib.dart';

class ObjectDetectionAlbum extends StatefulWidget {
  const ObjectDetectionAlbum({Key? key}) : super(key: key);

  @override
  State<ObjectDetectionAlbum> createState() => _ObjectDetectionAlbumState();
}

class _ObjectDetectionAlbumState extends State<ObjectDetectionAlbum> {
  late ModelObjectDetection _yoloV5Model;
  String? textToShow;
  List? _prediction;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool objectDetection = false;
  List<ResultObjectDetection>? objDetect;
  List<ResultObjectDetection>? objDetect2 = [];
  bool _isLoading = false; // Add loading state
  ModelObjectDetection? _objectModelYoloV11;
  String? usedModelName; // Untuk menampilkan model yang digunakan
  bool? isUsingFallback; // null: belum ditekan, true: fallback, false: berhasil


  @override
  void initState() {
    super.initState();
    loadModel();
  }

  //load your model
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
      _yoloV5Model = await PytorchLite.loadObjectDetectionModel(
          pathObjectDetectionModel, 4, 256, 256,
          labelPath: "assets/labels/labels.txt");
      print("Model pada galeri berhasil diload");
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  Future runObjectDetection() async {
    setState(() {
      _isLoading = true;
      usedModelName = null;
      isUsingFallback = null; // reset status
    });

    // Pilih gambar dari galeri
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return; // Jika tidak ada gambar yang dipilih, keluar dari fungsi

    Stopwatch stopwatch = Stopwatch()..start();
    objDetect = await _yoloV5Model.getImagePrediction(
      await File(image.path).readAsBytes(),
      minimumScore: 0.1,
      iOUThreshold: 0.3,
    );
    textToShow = inferenceTimeAsString(stopwatch);
    print('object executed in ${stopwatch.elapsed.inMilliseconds} ms');

    if (objDetect != null && objDetect!.isNotEmpty) {
      for (var element in objDetect!) {
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
      _image = File(image.path); // Set gambar yang dipilih
      _isLoading = false;
    });

    if (objDetect != null && objDetect!.isNotEmpty) {
      final detectedClasses = objDetect!.map((e) => e.className).toList();
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
  }

  Future runObjectDetectionYoloV11() async {
    setState(() {
      _isLoading = true;
      usedModelName = null;
      isUsingFallback = null; // reset status
    });

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await File(image.path).readAsBytes();
    Stopwatch stopwatch = Stopwatch()..start();

    if (_objectModelYoloV11 != null) {
      objDetect2 = await _objectModelYoloV11!.getImagePrediction(
        bytes,
        minimumScore: 0.1,
        iOUThreshold: 0.3,
      );
    }

    bool isYoloV11ResultValid = objDetect2 != null && objDetect2!.isNotEmpty;

    // Jika hasil dari YoloV11 kosong atau gagal, gunakan _objectModel
    if (!isYoloV11ResultValid) {
      print("Fallback ke model default karena YOLOv11 tidak mendeteksi objek.");
      Stopwatch fallbackStopwatch = Stopwatch()..start();
      objDetect = await _yoloV5Model.getImagePrediction(
        bytes,
        minimumScore: 0.1,
        iOUThreshold: 0.3,
      );
      textToShow = inferenceTimeAsString(fallbackStopwatch);
      isUsingFallback = true; // fallback digunakan
    } else {
      textToShow = inferenceTimeAsString(stopwatch);
      isUsingFallback = false; // YOLOv11 berhasil
    }

    final usedDetection = isYoloV11ResultValid ? objDetect2 : objDetect;
    usedModelName = isYoloV11ResultValid ? "YOLOv11" : "YOLOv5";

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
      _image = File(image.path);
      _isLoading = false; //
    });

    // menghitung jumlah deteksi object
    if (objDetect2 != null && objDetect2!.isNotEmpty) {
      final detectedClasses2 = objDetect2!.map((e) => e.className).toList();
      final typeCount2 = <String, int>{};

      for (var type2 in detectedClasses2) {
        if (type2 != null) {
          typeCount2[type2] = (typeCount2[type2] ?? 0) + 1;
        }
      }

      final mostDetected2 = typeCount2.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      List<JenisKopi> detectedtypes = DataJenisKopi
          .kopiList
          .where((namakopi) => mostDetected2.contains(namakopi.namaKopi))
          .toList();
      print("object terdeteksi $mostDetected2");

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
  }


  String inferenceTimeAsString(Stopwatch stopwatch) =>
      "Object Detection Time: ${stopwatch.elapsed.inMilliseconds} ms";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: header,)) // Show loading indicator
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (_image != null) // Tampilkan SizedBox hanya jika ada gambar
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
              width: MediaQuery.sizeOf(context).width * 0.95,
              child: Padding(
                padding: const EdgeInsets.all(8),
                // child:
                //     _objectModel != null
                //     ? _objectModel!.renderBoxesOnImage(_image!, objDetect ?? [])
                //     : const SizedBox(), // Tidak menampilkan apapun
                child: (_image != null)
                    ? (() {
                  // Tentukan model dan hasil deteksi yang digunakan
                  final isYoloV11Valid = (_objectModelYoloV11 != null && objDetect2 != null && objDetect2!.isNotEmpty);
                  final usedModel = isYoloV11Valid ? _objectModelYoloV11! : _yoloV5Model;
                  final usedResults = isYoloV11Valid ? objDetect2! : (objDetect ?? []);

                  return usedModel.renderBoxesOnImage(_image!, usedResults);
                })()
                    : const SizedBox(), // fallback jika _image null

              ),
            ),
          if (textToShow != null) // Tampilkan waktu inferensi hanya jika ada
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
          if (textToShow != null)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                textToShow!,
                style: TextStyle(color: textbiasa),
                maxLines: 3,
              ),
            ),
          if (isUsingFallback == true)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "YOLOv11 tidak mendeteksi objek, menggunakan model fallback.",
                style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),
              ),
            ),

          Container(
            height: 45,
            width: MediaQuery.of(context).size.width / 2.25,
            child: ElevatedButton(
              // onPressed: runObjectDetection,
              onPressed: runObjectDetectionYoloV11, // 🔁 Ganti ke fungsi YOLOv11
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(button),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _image == null ? 'Pilih Gambar' : 'Ambil Ulang',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: textbutton),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    _image == null
                        ? Icons.photo_album_outlined
                        : Icons.restart_alt_rounded,
                    color: texticon,
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: Visibility(
              visible: _prediction != null,
              child: Text(_prediction != null ? "${_prediction![0]}" : ""),
            ),
          )
        ],
      ),
    );
  }
}
