import 'dart:async';

import 'package:breathe/Classes/CustomCard.dart';
import 'package:breathe/Constants/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_icons/animate_icons.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Dashboard.dart';
import 'Login.dart';

class MapView extends StatefulWidget {
  static String id = 'MapViewView';

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();
  AnimateIconController ic;
  bool infovis = false;
  int selIndex;
  double ratio = 0.87;
  bool spinner = false;
  bool booked = false;

  @override
  void initState() {
    super.initState();
    ic = AnimateIconController();
  }

  void assignMarker() {
    setState(() {});
  }

  void _onMapViewCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void activeIndex(int index) {
    setState(() {
      setState(() {
        infovis = true;
        selIndex = index;
        ratio = 0.35;
      });
    });
  }

  List<Marker> makeSet() {
    List<Marker> list = [
      Marker(
        markerId: MarkerId('You'),
        onTap: () {
          setState(() {
            infovis = false;
            ratio = 0.87;
          });
        },
        position: userLoc,
        infoWindow: InfoWindow(
          title: 'You',
        ),
      ),
    ];
    for (int i = 0; i < vendorList.length; i++) {
      list.add(Marker(
        markerId: MarkerId('V$i'),
        onTap: () {
          activeIndex(i);
        },
        position: vendorList[i].location,
        infoWindow: InfoWindow(
            title: vendorList[i].name,
            snippet: "${vendorList[i].quantity} remaining"),
      ));
    }
    return list;
  }

  Widget cancelButton() {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    return cancelButton;
  }

  showCancelAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
            context, CustomRoute(builder: (_) => Dashboard()), (r) => false);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Cancel Search?"),
      actions: [okButton, cancelButton()],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showConfirmationAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () async {
        Navigator.of(context).pop();
        setState(() {
          spinner = true;
        });

        String ve;
        double price;
        int qu;
        String id;

        SharedPreferences prefs = await SharedPreferences.getInstance();

        await FirebaseFirestore.instance
            .collection('Vendor')
            .where('Name', isEqualTo: vendorList[selIndex].name)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            id = doc.id;
            ve = doc['Email'];
            price = doc['Price'] * 1.00;
            qu = doc['Quantity'];
          });
        });

        await FirebaseFirestore.instance
            .collection('Vendor')
            .doc(id)
            .update({'Quantity': --qu}).catchError(
                (error) => print("Failed to update user: $error"));

        await FirebaseFirestore.instance.collection('DealsHistory').add({
          'VendorEmail': ve,
          'CustomerEmail': prefs.get('Email'),
          'Price': price,
          'DateTime' : DateTime.now().toString(),
        });

        setState(() {
          spinner = false;
          booked = true;
        });

        Timer(const Duration(milliseconds: 200), () {
          setState(() {
            ic.animateToEnd();
          });
        });

        Timer(const Duration(milliseconds: 1500), () {
          Navigator.pushAndRemoveUntil(context,
              CustomRoute(builder: (_) => Dashboard()), (r) => false);
        });
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title:
          Text("Book Oxygen Cylinder with ${vendorList[selIndex].name.split(' ')[0]} ?"),
      actions: [okButton, cancelButton()],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size query = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        if (infovis)
          setState(() {
            infovis = false;
            ratio = 0.87;
          });
        else
          showCancelAlertDialog(context);
        return false;
      },
      child: ModalProgressHUD(
        progressIndicator: SpinKitChasingDots(
          color: Theme.of(context).accentColor,
          size: 30.0,
        ),
        inAsyncCall: spinner,
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: query.height * (1 - ratio)),
                child: GoogleMap(
                  onMapCreated: _onMapViewCreated,
                  markers: makeSet().toSet(),
                  initialCameraPosition: CameraPosition(
                    target: userLoc,
                    zoom: 13.0,
                  ),
                ),
              ),
              Container(
                width: query.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.all(Radius.circular(!infovis ? 0 : 40.0)),
                ),
                margin: EdgeInsets.only(
                    top: query.height * (infovis ? ratio - 0.01 : ratio)),
                padding: EdgeInsets.only(top: infovis ? 20 : 0),
                child: Center(
                  child: !infovis
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Oxygen Supplies near you",
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "Tap on a vendor to know more",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  vendorList[selIndex].name,
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 35,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  vendorList[selIndex].address,
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "${calculateDistance(vendorList[selIndex].location, userLoc).toStringAsFixed(2)} km",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            CustomCard(
                              margin: EdgeInsets.symmetric(horizontal: 30),
                              child: Container(
                                padding: EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    Text(
                                      vendorList[selIndex].quantity.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 40,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Text(
                                      "Cylinders Available",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Text(
                                      "Rs ${vendorList[selIndex].price.toString()}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 25,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              color: Theme.of(context).accentColor,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:12),
                                  child: Text(
                                    "Call ${vendorList[selIndex].name.split(' ')[0]}",
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    launch('tel:${vendorList[selIndex].phno}');
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context).accentColor,
                                        ),
                                        child: Icon(
                                          Icons.phone_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        vendorList[selIndex].phno.toString(),
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Theme.of(context).accentColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 25,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                                height: query.height * 0.08,
                                width: query.width,
                                color: Theme.of(context).accentColor,
                                child: GestureDetector(
                                  onTap: () {
                                    showConfirmationAlertDialog(context);
                                  },
                                  child: Center(
                                    child: Text(
                                      "Book Now",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 25,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                ),
              ),
              booked
                  ? Container(
                      width: query.width,
                      height: query.height,
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(30))
                          ),
                          width: query.height * 0.2,
                          height: query.height * 0.2,
                          child: Center(
                            child: AnimateIcons(
                              startIcon: Icons.search,
                              endIcon: Icons.done,
                              size: 100.0,
                              controller: ic,
                              // add this tooltip for the start icon
                              startTooltip: 'Icons.add_circle',
                              // add this tooltip for the end icon
                              endTooltip: 'Icons.add_circle_outline',
                              onStartIconPress: () {
                                print("Clicked on Add Icon");
                                return true;
                              },
                              onEndIconPress: () {
                                print("Clicked on Close Icon");
                                return true;
                              },
                              duration: Duration(milliseconds: 600),
                              startIconColor: Theme.of(context).accentColor,
                              endIconColor: Colors.green,
                              clockwise: false,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(height: 0)
            ],
          ),
        ),
      ),
    );
  }
}