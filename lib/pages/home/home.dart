import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MethodChannel channel =
      MethodChannel('com.flutter.dev/clientmanager.evaluate-mvel');
    String mvelResult = "Waiting...";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: 500,
                width: 500,
                child: Column(
                  children: [
                    Text(
                      "Home Screen",
                      style: TextStyle(fontSize: 30),
                    ),
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
                    )
                    // : Text("MVEL Response: " + _evaluateMvel()),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

   _evaluateMvel() async {
    Map<String, dynamic>  data = {"name": "Cherinet", "age": 44, "rightEyeAngle": 12.3, "leftEyeAngle": 11.7};
    String mvelExpression = "rightEyeAngle >= 10.8";
    try{ data = await channel.invokeMethod("evaluateMvel", {"dataContext": data, "mvelExpression": mvelExpression}).then(
          (result) => result.cast<String, dynamic>());
          print('Data received from platform: $data');
    return data;
    }
    on PlatformException catch (e) {
      print(e.message);
    }

  }
}
