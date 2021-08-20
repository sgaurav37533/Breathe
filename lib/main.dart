import 'dart:async';
import 'package:breathe/Screens/Dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/LandingPage.dart';
import 'Screens/Login.dart';
import 'Screens/Register.dart';
import 'Screens/MapView.dart';
import 'Screens/Search.dart';
import 'Screens/VendorDashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}

class LandingPageRoute extends MaterialPageRoute {
  LandingPageRoute({WidgetBuilder builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => Duration(milliseconds: 1100);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: {
          LandingPage.id: (context) => LandingPage(),
          Login.id: (context) => Login(),
          Register.id: (context) => Register(),
          Dashboard.id: (context) => Dashboard(),
          MapView.id : (context) => MapView(),
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Color(0xFF1F4F99),
        ),
        home: SplashScreen());
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool visible = true;
  String email;
  String user;

  navigateToDashboard(){
    user == "Customer" ? Navigator.pushAndRemoveUntil(
        context, LandingPageRoute(builder: (_) => Dashboard()), (r) => false) : Navigator.pushAndRemoveUntil(
        context, LandingPageRoute(builder: (_) => VendorDashboard()), (r) => false);
  }

  prefs() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('Email')??"";
    user = prefs.getString('User')??"";
  }

  @override
  void initState() {
    super.initState();
    prefs();
    Timer(const Duration(milliseconds: 100), () {
      setState(() {
        visible = false;
      });
    });

    Timer(const Duration(milliseconds: 2500), () {
      setState(() {
        email == "" ? Navigator.pushAndRemoveUntil(
            context, LandingPageRoute(builder: (_) => LandingPage()), (r) => false) : navigateToDashboard() ;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Image.asset(
        "assets/images/bk.jpg",
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedOpacity(
          opacity: visible ? 0.0 : 1.0,
          duration: Duration(milliseconds: 900),
          child: Container(
            color : Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFFDEDDDD)),
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(
                              MediaQuery.of(context).size.width, 250.0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'icon',
                          child: Container(
                              child: Image.asset('assets/images/icon.png'),
                              width: 130),
                        ),
                        Text(
                          'Breathe',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 42,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.transparent,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ]);
  }
}
