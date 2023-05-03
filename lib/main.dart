import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_test_flutter/pages/login_form/login_form.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('com.flutter.dev/app-component');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _callAppComponent();
    });
  }
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginForm());
  }

  Future<void> _callAppComponent() async {
    await platform.invokeMethod("callComponent");
  }
}





