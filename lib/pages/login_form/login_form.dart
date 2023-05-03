import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:login_test_flutter/pages/home/home.dart';
import 'package:login_test_flutter/pages/machine_detail/machine_detail.dart';
class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
TextEditingController _usernameController = TextEditingController();
TextEditingController _passwordController = TextEditingController();
MethodChannel channel = MethodChannel('com.flutter.dev/clientmanager.login');
class _LoginFormState extends State<LoginForm> {

  showSpinkit(){

      return Center(
        child: SpinKitFadingCircle(
          duration: Duration(seconds: 12),
          itemBuilder: (BuildContext context, int index) {
            return  DecoratedBox(
              decoration: BoxDecoration(
                color: index.isEven ? Colors.red : Colors.green,
              ),
            );
          },
        ),
      );

  }
  @override
  Widget build(BuildContext context) {
    double _mediaQueryHeight = MediaQuery.of(context).size.height;
    double _mediaQueryWidth = MediaQuery.of(context).size.width;
    return Scaffold(

        appBar: AppBar(

      backgroundColor: const Color(0xff6200EE),
      title: const Text("Registration Client"),
    ),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xffF2F6FF)

          ),
          height: _mediaQueryHeight,
          width: _mediaQueryWidth,
          padding: const EdgeInsets.all(18),
          child: Container(

            // width: _mediaQueryWidth/0.9,
            // height: _mediaQueryHeight/0.2,
            color: const Color(0xffFFFFFF),
            child: SingleChildScrollView(
              child: Column(

                children: [
                  SizedBox(height: _mediaQueryHeight/5,),
                  GestureDetector(
                    onLongPress: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MachineDetail()));
                    },
                    child: Center(
                      child: SizedBox(
                        height: _mediaQueryHeight/8,
                        width: _mediaQueryWidth/5.9,
                        child: ClipOval(
                          child: Image.asset("assets/images/mosip_logo.png")
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: _mediaQueryHeight/44,),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                      
                      children: [
                          TextFormField(
                            controller: _usernameController,
                            onChanged: (value){
                              if(value.isEmpty){
                                Fluttertoast.showToast(
                                    msg: 'Username is required',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white
                                );
                              }
                            },

                           decoration: const InputDecoration(
                                      hintText: 'username',

                                   suffixIcon: Icon(Icons.person)

                           ),
                            validator: (value){
                              if(value!.isEmpty){
                                return "Username is required";
                              }
                            },

                          ),
                          const SizedBox(),
                          TextFormField(
                            controller: _passwordController,
                            onChanged: (value){
                              if(value.isEmpty){
                                Fluttertoast.showToast(
                                    msg: 'Password is required',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white
                                );
                              }
                            },
                            decoration: const InputDecoration(
                                hintText: 'password',
                                suffixIcon: Icon(Icons.lock_outline)


                            ),
                            obscureText: true,


                            validator: (value){
                              if(value!.isEmpty ){
                                return "Password is required";
                              }
                              else if(value.length < 8){
                                return "Password length cannot be less than 8";
                              }
                            },

                          ),
                        SizedBox(height: _mediaQueryHeight/30,),

                        Container(
                          width: _mediaQueryWidth/4.9,
                          height: _mediaQueryHeight/15,
                          decoration: const BoxDecoration(

                          ),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                disabledBackgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xff6200EE)
                              ),
                              onPressed: (){
                                final FormState? form = _formKey.currentState;
                                if(form!.validate()){
                                  print("Validate");
                                  print("Channel method successfully invoked");
                                  String loginRespone = _login(_usernameController.text, _passwordController.text).toString();
                                 if (loginRespone.contains("Error")){
                                  Fluttertoast.showToast(
                                    msg: 'Unable to login\n' + loginRespone,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white
                                );
                                 }
                                 else{
                                  Fluttertoast.showToast(
                                    msg: 'Successful!\nToken: ' + loginRespone,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white
                                );
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home()));
                                 }
                                  // Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home()));
                                }
                              }, child: const Text("LOGIN")),
                        )
                      ],
                    )),
                  )
                ],
              ),
            ),
          ),
        ));
  }


  Future<Object?> _login(String username, String password) async {
    Map<String, dynamic>  data;
    try {
      data = await channel.invokeMethod("login", {'username': username, 'password': password});
      print("Login response on flutter side:" ); print(data);
      return data;
    } on PlatformException catch(e) {
      debugPrint("Login Error: ${e.message}");
      return e.message;
    }
  }



}
