import 'package:google_maps_flutter/google_maps_flutter.dart';

class Vendor {
  final String name;
  final String email;
  final int phno;
  final double price;
  final int quantity;
  final LatLng location;
  final String address;

  Vendor(
      {this.name,
      this.price,
      this.email,
      this.quantity,
      this.phno,
      this.location,
      this.address});
}
