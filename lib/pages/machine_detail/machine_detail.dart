import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';



class MachineDetail extends StatefulWidget {
  const MachineDetail({Key? key}) : super(key: key);

  @override
  State<MachineDetail> createState() => _MachineDetailState();
}

class _MachineDetailState extends State<MachineDetail> {
  MethodChannel channel = MethodChannel('com.flutter.dev/keymanager.test-machine');
  List<dynamic> _machineDetails = [];
  String machineDetail = "Waiting...";
  
  @override
  void initState() {
    super.initState();
    // Call the readJson method when the app starts
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon: Icon(Icons.arrow_back)),
        backgroundColor: Colors.transparent,
        title: const Text("About Client"),
      ),
      body:  Column(
        children: [
          machineDetail == "Waiting..." ? Text(" ") : IconButton(onPressed: (){
              if(_write(machineDetail)){
                print('Successfully downloaded machine details!');
                Fluttertoast.showToast(
                                    msg: 'Successfully downloaded machine details!',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white
                                );
              }
              else{
                print('Error occurred while downloading machine details');
                Fluttertoast.showToast(
                                    msg: 'Error occurred while downloading machine details',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white
                                );
              }

          }, icon: Icon(Icons.download)),
          SizedBox(height: 40,),
          machineDetail == "Waiting..." ? TextButton(onPressed: _testMachine, child: Text("Get machine details")): SelectableText(machineDetail)
        ],
      ),

    );



  }
  Future<void> _testMachine() async {
    String resultText;
    try {
      resultText = await channel.invokeMethod('testMachine');
      Map<String, dynamic> machineMap = jsonDecode(resultText);
      debugPrint("Machine Map $machineMap");
    } on PlatformException catch (e) {
      resultText = "Failed to get platform version: '${e.message}'.";
    }
    debugPrint(resultText);
    setState(() {
      machineDetail = resultText;
    });
  }
  _write(String text) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/machineDetail.txt');
  print(" Directory: " + directory.toString());
  await file.writeAsString(text);
  return true;
}

Future<String> _read() async {
  String? text;
  try {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/machineDetail.txt');
    text = await file.readAsString();
  } catch (e) {
    print("Couldn't read file");
  }
  return text!;
}
}
