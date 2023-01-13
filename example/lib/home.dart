// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vosk_flutter_plugin/vosk_flutter_plugin.dart';
import 'package:vosk_flutter_plugin_example/controller.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Controller controller = Get.put(Controller());

  bool isModelLoading = false;
  bool isModelLoaded = false;
  bool isRecognizing = false;

  String withAccents = 'ÁÉÍÓÚáéíóú';
  String withoutAccents = 'AEIOUaeiou';

  double feedbackOpacity = 0.0;
  bool feedbackVisibility1 = false;
  bool feedbackVisibility2 = false;

  Map<String, int> coloresPalabras = {
    'hola': 0xff000000,
    'soy': 0xff000000,
    'carlos': 0xff000000,
    'y': 0xff000000,
    'estudio': 0xff000000,
    'en': 0xff000000,
    'la': 0xff000000,
    'universidad': 0xff000000,
  };

  List<String> palabrasEsperadas = [
    'hola',
    'soy',
    'carlos',
    'y',
    'estudio',
    'en',
    'la',
    'universidad'
  ];

  void _setColorPalabra(String key) async {
    await Future.delayed(Duration.zero);
    setState(() {
      coloresPalabras.update(key, (value) => 0xFF40C4FF);
    });
  }

  void _setFeedbackVisibility(int numPalabrasCorrespondientes) async {
    await Future.delayed(Duration.zero);
    print('asdsadsadsadadsasdllllllllllllllllllllllll----- ' +
        numPalabrasCorrespondientes.toString() +
        ' de ' +
        palabrasEsperadas.length.toString());
    setState(() {
      feedbackOpacity = 1.0;
    });

    if (numPalabrasCorrespondientes == palabrasEsperadas.length) {
      setState(() {
        feedbackVisibility1 = false;
        feedbackVisibility2 = true;
      });
    }

    if (numPalabrasCorrespondientes > 0 &&
        numPalabrasCorrespondientes != palabrasEsperadas.length) {
      setState(() {
        feedbackVisibility1 = true;
        feedbackVisibility2 = false;
      });
    }
  }

  String _removeAccents(String text) {
    for (int i = 0; i < withAccents.length; i++) {
      text = text.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Definitiva - Pronunciation Module'),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(left: 58, right: 58),
                child: Image.asset(
                  'assets/images/logo_definitiva.png',
                ),
              ),
              StreamBuilder(
                stream: VoskFlutterPlugin.onPartial(),
                builder: (context, snapshot) => Text(''),
              ),
              Container(
                margin: EdgeInsets.only(top: 30, bottom: 30),
                child: Text('Repita:', style: TextStyle(fontSize: 18)),
              ),
              Container(
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hola, ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color:
                                  Color(coloresPalabras['hola'] ?? 0xff000000)),
                        ),
                        TextSpan(
                          text: 'soy ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color:
                                  Color(coloresPalabras['soy'] ?? 0xff000000)),
                        ),
                        TextSpan(
                          text: 'Carlos ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(
                                  coloresPalabras['carlos'] ?? 0xff000000)),
                        ),
                        TextSpan(
                          text: 'y ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(coloresPalabras['y'] ?? 0xff000000)),
                        ),
                        TextSpan(
                          text: 'estudio ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(
                                  coloresPalabras['estudio'] ?? 0xff000000)),
                        ),
                        TextSpan(
                          text: 'en ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color:
                                  Color(coloresPalabras['en'] ?? 0xff000000)),
                        ),
                        TextSpan(
                          text: 'la ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color:
                                  Color(coloresPalabras['la'] ?? 0xff000000)),
                        ),
                        TextSpan(
                          text: 'universidad.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(coloresPalabras['universidad'] ??
                                  0xff000000)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: feedbackOpacity,
                child: Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 30),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Visibility(
                        visible: feedbackVisibility2,
                        child: Icon(Icons.check_circle,
                            color: Colors.green, size: 48),
                      ),
                      Visibility(
                        visible: feedbackVisibility1,
                        child: Text('Intente nuevamente.',
                            style: TextStyle(color: Colors.red, fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
              StreamBuilder(
                  stream: VoskFlutterPlugin.onResult(),
                  builder: (context, snapshot) {
                    try {
                      List<String> palabrasReconocidas = [];
                      List<String> palabrasCorrespondientes = [];
                      Map mapa = Map<String, dynamic>.from(
                          json.decode(snapshot.data.toString()));

                      palabrasReconocidas =
                          _removeAccents(mapa['text']).split(' ');
                      print('Palabras reconocidas: ' +
                          palabrasReconocidas.toString());

                      for (var j = 0; j < palabrasEsperadas.length; j++) {
                        for (var k = 0; k < palabrasReconocidas.length; k++) {
                          if (palabrasEsperadas[j] == palabrasReconocidas[k]) {
                            _setColorPalabra(palabrasEsperadas[j]);
                            palabrasCorrespondientes.add(palabrasEsperadas[j]);
                          }
                        }
                      }

                      _setFeedbackVisibility(palabrasCorrespondientes.length);

                      return Text('');
                    } catch (e) {
                      print('Error: ' + e.toString());
                      return Text('');
                    }
                  }),
              const SizedBox(height: 20),
              //const Text('On final result'),
              StreamBuilder(
                stream: VoskFlutterPlugin.onFinalResult(),
                builder: (context, snapshot) => Text(''),
              ),
              if (!isModelLoaded && !isModelLoading)
                ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isModelLoading = true;
                      });
                      ByteData modelZip = await rootBundle
                          .load('assets/models/vosk-model-small-es-0.42.zip');
                      await VoskFlutterPlugin.initModel(modelZip);
                      setState(() {
                        isModelLoading = false;
                        isModelLoaded = true;
                      });
                    },
                    child: const Text('Load and init model')),
              if (isModelLoading) const CircularProgressIndicator(),
              if (isModelLoaded) const Text('Model loaded'),
              ElevatedButton(
                  onPressed: !isRecognizing && isModelLoaded
                      ? () {
                          VoskFlutterPlugin.start();
                          setState(() {
                            isRecognizing = true;
                          });
                        }
                      : null,
                  child: const Text('Start Test')),
              ElevatedButton(
                  onPressed: isRecognizing
                      ? () {
                          VoskFlutterPlugin.stop();
                          setState(() {
                            isRecognizing = false;
                          });
                        }
                      : null,
                  child: const Text('Stop Test')),
            ],
          ),
        ),
      ),
    );
  }
}
