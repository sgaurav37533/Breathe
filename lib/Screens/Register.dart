import 'package:breathe/Classes/CustomCard.dart';
import 'package:breathe/Constants/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Dashboard.dart';
import 'VendorDashboard.dart';

class Register extends StatefulWidget {
  static String id = 'Register';

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String errorText;
  String name;
  String email;
  String password;
  String phno;
  bool spinner = false;
  bool state = true;
  bool absorb = false;

  FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  Future<void> signUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('User');

    if (_formKey.currentState.validate()) {
      setState(() {
        spinner = true;
      });
      var newuser = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await auth.currentUser.updateDisplayName(name);

      if ( user=='Customer' )
        FirebaseFirestore.instance.collection('$user').add({
          'Name': name,
          "Email": email,
          "PhoneNumber": phno,
        });
      else
        FirebaseFirestore.instance.collection('$user').add({
          'Name': name,
          "Email": email,
          "PhoneNumber": phno,
          "Price": 0,
          "Location": "null",
          "Quantity": 0,
          "Address1" : '',
          "Address2" : '',
        });
      prefs.setString('Email', '$email');

      setState(() {
        spinner = false;
      });

      if (newuser != null) {
        if ( user=='Customer' )
        Navigator.pushAndRemoveUntil(
            context, CustomRoute(builder: (_) => Dashboard()), (r) => false);
        else
          Navigator.pushAndRemoveUntil(
              context, CustomRoute(builder: (_) => VendorDashboard()), (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: SpinKitChasingDots(
        color: Theme.of(context).accentColor,
        size: 30.0,
      ),
      inAsyncCall: spinner,
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              //padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome to",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Breathe",
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: TextFormField(
                            onChanged: (value) {
                              name = value.trim();
                            },
                            cursorColor: Theme.of(context).accentColor,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              fillColor: Color(0xFFD2D2D2),
                              filled: true,
                              hintText: "Full Name",
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                            ),
                            validator: nameValidator,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: TextFormField(
                            onChanged: (value) {
                              email = value.trim();
                            },
                            cursorColor: Theme.of(context).accentColor,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              fillColor: Color(0xFFD2D2D2),
                              filled: true,
                              hintText: "Your Email",
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                            ),
                            validator: emailChecker,
                          ),
                        ),
                      ],
                    ),
                  ),
                  //SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Password",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Stack(
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
                                  hintText: "Create a Password",
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Phone Number",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: TextFormField(
                            onChanged: (value) {
                              phno = value.toString().trim();
                            },
                            cursorColor: Theme.of(context).accentColor,
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              fillColor: Color(0xFFD2D2D2),
                              filled: true,
                              prefixText: "+91 ",
                              prefixStyle: TextStyle(color: Colors.black),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                            ),
                            validator: phoneNumberChecker,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                  ),
                  GestureDetector(
                    onPanDown: (var x) {
                      signUp();
                    },
                    child: CustomCard(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: 80,
                      ),
                      color: Color(0xFF1F4F99),
                      radius: 30.0,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
