import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transliteration/response/transliteration_response.dart';
import 'package:transliteration/transliteration.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MethodChannel channel =
      MethodChannel('com.flutter.dev/clientmanager.evaluate-mvel');
  String mvelResult = "Waiting...";
  TextEditingController _originalTextController = TextEditingController();
  TextEditingController _transliteratedTextController = TextEditingController();
  String originalTextDropdownvalue = 'eng';
  String transliteratedTextDropdownvalue = 'amh';

  
  
  var languages = [
    'eng',
    'amh',
    'ara',
    'hin',
    'tig',
  ];
  var languageKeys = [];
  var languageValues = [];

  Map<String, Languages> languageMap = {
    "eng": Languages.ENGLISH,
    "amh": Languages.AMHARIC,
    "ara": Languages.ARABIC,
    "tig": Languages.TIGRINYA,
    "hin": Languages.HINDI
  };

  String nameTransliterated = "";


  @override
  void initState() {
    super.initState();
    // loadLanguageJson().then((value) {
    //   setState(() {
    //     languageMap = value['language'];
    //   });
    // });
    languageKeys = languageMap.keys.toList();
    languageValues = languageMap.values.toList();
  }

  Future<Map<String, dynamic>> loadLanguageJson() async {
    String jsonString =
        await rootBundle.loadString('assets/config/language_map.json');
    return json.decode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    print(languageMap);
    double _mediaQueryHeight = MediaQuery.of(context).size.height;
    double _mediaQueryWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    height: _mediaQueryHeight,
                    width: _mediaQueryWidth,
                    child: Column(
                      children: [
                        SizedBox(height: 200),
                        Row(
                          children: [
                            TextButton(
                              child: Text("Evaluate MVEL"),
                              onPressed: (() {
                                Fluttertoast.showToast(
                                    msg: 'MVEL Response: ' + _evaluateMvel(),
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white);
                              }),
                            ),

                            Text(mvelResult),
                          ],
                        ),
                        Text(
                          "Transliteration",
                          style: TextStyle(fontSize: 30),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: _mediaQueryWidth / 1.3,
                              child: TextFormField(
                                  controller: _originalTextController,
                                  textDirection:
                                      originalTextDropdownvalue == "ara"
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                  onChanged: (value) async {
                                    setState(() {
                                      
                                    });
                                    setState(() async{
                                      TransliterationResponse? _response =
                                        await Transliteration.transliterate(
                                            value,
                                            languageMap[
                                                transliteratedTextDropdownvalue]!);
                                    _transliteratedTextController.text =
                                        _response!
                                            .transliterationSuggestions.first
                                            .toString();
                                    });
                                  
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Original Text',
                                  )),
                            ),
                            DropdownButton(
                              // Initial Value
                              value: originalTextDropdownvalue,
                              // Down Arrow Icon
                              icon: const Icon(Icons.arrow_drop_down_rounded),
                              // Array list of items
                              items: languageMap.keys.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),

                              // After selecting the desired option,it will
                              // change button value to selected value
                              onChanged: (newValue) {
                                setState(() {
                                  originalTextDropdownvalue =
                                      newValue as String;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: _mediaQueryWidth / 1.3,
                              child: TextFormField(
                                  onTap: (){setState(() {
                                    
                                  });},
                                  controller: _transliteratedTextController,
                                  textDirection:
                                      transliteratedTextDropdownvalue == "ara"
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                  onChanged: (value)  {
                                    setState(() {
                                      
                                    });
                                    setState(() async{
                                      TransliterationResponse? _response =
                                        await Transliteration.transliterate(
                                            value,
                                            languageMap[
                                                transliteratedTextDropdownvalue]!);
                                    _transliteratedTextController.text =
                                        _response!
                                            .transliterationSuggestions.first
                                            .toString();
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Transliterated text",
                                  )),
                            ),
                            DropdownButton(

                                // Initial Value
                                value: transliteratedTextDropdownvalue,
                                // Down Arrow Icon
                                icon: const Icon(Icons.arrow_drop_down_rounded),
                                // Array list of items
                                items: languageMap.keys.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                onChanged: (newValue)  {
                                  setState(() {
                                    
                                  });
                                  setState(() {
                                    transliteratedTextDropdownvalue =
                                        newValue as String;
                                  });
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _getName(value) async {
  //   String nameTransliterated;
  //   TransliterationResponse? _response = await Transliteration.transliterate(
  //       "Name", languageMap[value]!);
  //   nameTransliterated =
  //       _response!.transliterationSuggestions.first.toString();
  //       return  nameTransliterated as String;
  // }

  _evaluateMvel() async {
    List languageList = [
    "ara",
    "eng"
  ];
  List gender =[
    "male",
    "female"
  ];
  String rID = "10001106921003120220704141850";
  String flowType = "NEW";
  String process = "NEW";
  double schemaVersion = 0.1;
    Map<String, dynamic> demographics = {"gender": gender};
    Map<String, dynamic> data = {
      "name": "Cherinet",
      "age": 44,
      "rightEyeAngle": 12.3,
      "leftEyeAngle": 11.7
    };
    String mvelExpression = "identity['IDSchemaVersion'] >= 0.0";
    try {
      bool resultData = await channel.invokeMethod("evaluateMvel", {"languageList": languageList, "rID": rID,
      "flowType": flowType, "process": process, "schemaVersion": schemaVersion, "demographics": demographics, "mvelExpression": mvelExpression
      });
      print('Data received from platform: $resultData');
      setState(() {
        mvelResult = "Expression: " +mvelExpression + "\nEvaluates:" + resultData.toString();
      });
      
      return resultData;
    } on PlatformException catch (e) {
      print(e.message);
    }
  }
}
