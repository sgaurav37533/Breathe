import 'package:breathe/Classes/CustomCard.dart';
import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';

import 'Login.dart';

class LoginPageRoute extends MaterialPageRoute {
  LoginPageRoute({WidgetBuilder builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => Duration(milliseconds: 1000);
}

class LandingPage extends StatefulWidget {
  static String id = 'LandingPage';

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  Future<void> writeUser(String user) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    print(user);
    sf.setString('User', user);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(children: [
        Image.asset(
          "assets/images/bk.jpg",
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            margin: EdgeInsets.only(top : MediaQuery.of(context).size.height*0.35 ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 70,
                ),
                Hero(
                  tag: 'icon',
                  child: Container(
                      child: Image.asset('assets/images/icon.png'),
                      width: MediaQuery.of(context).size.width*0.54,),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Breathe',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.05,
                ),
                GestureDetector(
                  onPanDown: (var x) {
                    writeUser('Customer');
                    Navigator.push(
                        context, LoginPageRoute(builder: (_) => Login()));
                  },
                  child: CustomCard(
                    child: Text(
                      'Customer',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 60),
                    color:  Theme.of(context).accentColor,
                    radius: 30.0,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onPanDown: (var x) {
                    writeUser('Vendor');
                    Navigator.push(context,
                        LoginPageRoute(builder: (_) => Login()));
                  },
                  child: CustomCard(
                    child: Text(
                      'Vendor',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 60),
                    color:  Theme.of(context).accentColor.withBlue(200),
                    radius: 30.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
