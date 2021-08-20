import 'dart:async';

import 'package:breathe/Classes/CustomCard.dart';
import 'package:breathe/Constants/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LandingPage.dart';
import 'Search.dart';

class Dashboard extends StatefulWidget {
  static String id = 'Dashboard';

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<dynamic> list = [];
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future getData() async {
    List<String> ve = [];
    List<String> ce = [];
    List<double> p = [];
    List<String> date = [];
    List<String> vn = [];
    List<String> cn = [];

    await FirebaseFirestore.instance
        .collection('DealsHistory')
        .orderBy('DateTime')
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.size == 0) return;
      querySnapshot.docs.forEach((doc) {
        ve.add(doc['VendorEmail']);
        ce.add(doc['CustomerEmail']);
        p.add(doc['Price'] * 1.00);
        date.add(doc['DateTime']);
      });
    });

    for (int i = 0; i < ve.length; i++) {
      await FirebaseFirestore.instance
          .collection('Vendor')
          .where('Email', isEqualTo: ve[i])
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          vn.add(doc['Name']);
        });
      });

      await FirebaseFirestore.instance
          .collection('Customer')
          .where('Email', isEqualTo: ce[i])
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          cn.add(doc['Name']);
        });
      });

      list.add({"VN": vn[i], "CN": cn[i], "Price": p[i], "DateTime": date[i]});
    }
    while (list.length > 10) list.removeLast();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Breathe",
            style: TextStyle(
              fontFamily: 'Barlow',
              letterSpacing: 8,
              fontSize: 29,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Theme.of(context).accentColor,
          centerTitle: true,
          actions: [
            PopupMenuButton<int>(
                itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                      PopupMenuItem<int>(value: 1, child: Text('Sign Out')),
                    ],
                onSelected: (int value) async {
                  await _auth.signOut();
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('Email');
                  prefs.remove('User');
                  Navigator.pushAndRemoveUntil(context,
                      CustomRoute(builder: (_) => LandingPage()), (r) => false);
                }),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
                context, CustomRoute(builder: (_) => Search()), (r) => false);
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  spreadRadius: 0.01,
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 15,
                )
              ],
            ),
            child: Container(
              width: 120,
              child: Hero(
                tag: 'icon',
                child: Image.asset('assets/images/icon.png'),
              ),
            ),
          ),
        ),
        body: FutureBuilder(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(child: Text("Loading"));
              case ConnectionState.waiting:
                return Center(
                    child: Text("Loading..",
                        style:
                            TextStyle(color: Color(0xFF1F4F99), fontSize: 19)));
              case ConnectionState.active:
                return Center(child: Text("Loading"));
              case ConnectionState.done:
                return Container(
                  margin: EdgeInsets.only(top: 20, left: 20, right: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text("Recent Oxygen Supplies",
                            style: TextStyle(
                                color: Color(0xFF1F4F99), fontSize: 19)),
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int index) {
                            return CustomCard(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(children: [
                                    Text(
                                      list[index]["VN"],
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      'to',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      list[index]["CN"],
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    )
                                  ]),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomCard(
                                        shadow: false,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 7),
                                        color: Color(0xff253199),
                                        child: Text(
                                            '\u{20B9} ${list[index]["Price"].toInt().toString()}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                            )),
                                        radius: 15,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 15),
                              margin: EdgeInsets.symmetric(vertical: 10),
                              radius: 20.0,
                              color: Color(0xFF3847bf),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              default:
                return Center(child: Text("Loading3"));
            }
            ;
          },
        ),
      ),
    );
  }
}
