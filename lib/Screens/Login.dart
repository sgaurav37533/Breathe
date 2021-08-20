import 'package:breathe/Classes/CustomCard.dart';
import 'package:breathe/Constants/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Dashboard.dart';
import 'Register.dart';
import 'VendorDashboard.dart';

class RegisterPageRoute extends MaterialPageRoute {
  RegisterPageRoute({WidgetBuilder builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => Duration(milliseconds: 800);
}

class DashboardRoute extends MaterialPageRoute {
  DashboardRoute({WidgetBuilder builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => Duration(milliseconds: 1100);
}

class Login extends StatefulWidget {
  static String id = 'Login';

  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String errorText = ' ';
  String email;
  String password;
  bool spinner = false;
  bool state = true;
  bool absorb = false;

  FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  void login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('User');
    if (_formKey.currentState.validate()) {
      setState(() {
        spinner = true;
      });
      try {
        var authUser = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        await FirebaseFirestore.instance
            .collection('$user')
            .where('Email', isEqualTo: email)
            .get()
            .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.length == 0) {
            print("Not a $user");
            throw Exception("Not a $user");
          }
        });

        prefs.setString('Email', email);
        if (authUser != null) {
          user == "Customer"
              ? Navigator.pushAndRemoveUntil(context,
                  DashboardRoute(builder: (_) => Dashboard()), (r) => false)
              : Navigator.pushAndRemoveUntil(
                  context,
                  DashboardRoute(builder: (_) => VendorDashboard()),
                  (r) => false);
        }
      } on Exception {
        setState(() {
          spinner = false;
          errorText = "Wrong Email/Password";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Image.asset(
        "assets/images/bk.jpg",
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
      ),
      ModalProgressHUD(
        progressIndicator: SpinKitChasingDots(
          color: Theme.of(context).accentColor,
          size: 30.0,
        ),
        inAsyncCall: spinner,
        child: Scaffold(
          //resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Container(
            height: MediaQuery.of(context).size.height,
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                    ),
                    Hero(
                      tag: 'icon',
                      child: Container(
                          child: Image.asset('assets/images/icon.png'),
                          width: MediaQuery.of(context).size.height * 0.25),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Text(
                      'Breathe',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          //color: Color(0xFFD2D2D2),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: TextFormField(
                          onChanged: (value) {
                            email = value.trim();
                          },
                          cursorColor: Theme.of(context).accentColor,
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            fillColor: Color(0xFFD2D2D2),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            filled: true,
                            hintText: "Email",
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                          ),
                          validator: emailChecker,
                        ),
                      ),
                    ),
                    //SizedBox(height: 10),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            child: TextFormField(
                              onChanged: (value) {
                                password = value.trim();
                              },
                              obscureText: state,
                              cursorColor: Theme.of(context).accentColor,
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                fillColor: Color(0xFFD2D2D2),
                                filled: true,
                                hintText: "Password",
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                              ),
                              validator: passwordValidator,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 20,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (state == false) {
                                      setState(() {
                                        state = true;
                                      });
                                    } else if (state == true) {
                                      setState(() {
                                        state = false;
                                      });
                                    }
                                  });
                                },
                                child: Icon(Icons.remove_red_eye)),
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        errorText,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    GestureDetector(
                      onPanDown: (var x) {
                        login();
                      },
                      child: CustomCard(
                        child: Text(
                          'Log In',
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: 80,
                        ),
                        color: Theme.of(context).accentColor,
                        radius: 30.0,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    signUpRichText(
                      title: "Sign Up!",
                      onTap: () {
                        Navigator.push(context,
                            RegisterPageRoute(builder: (_) => Register()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
