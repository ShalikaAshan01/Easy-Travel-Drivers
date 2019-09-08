import 'dart:async';

import 'package:csse/views/qr_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _Home();
  }
}

class _Home extends State<Home> {
  StreamSubscription<Position> _positionStreamSubscription;
  Position _position = Position();
  Placemark _placemark;
  String _address = '';


  @override
  void initState() {
    super.initState();
    _toggleListening();
  }
  @override
  void didUpdateWidget(Home oldWidget) {
    super.didUpdateWidget(oldWidget);
    _toggleListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Easy Travel Drivers"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => QrScanner()));
        },
        label: Text("Scan"),
        icon: Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container
        (child: displayLocation()),
    );
  }
  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription.cancel();
      _positionStreamSubscription = null;
    }

    super.dispose();
  }

  Widget displayLocation(){
    return FutureBuilder<GeolocationStatus>(
      future: Geolocator().checkGeolocationPermissionStatus(),
      builder: (BuildContext context, AsyncSnapshot<GeolocationStatus> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == GeolocationStatus.denied) {
//          return _permissionDenied('Access to location denied',
//              'Allow access to the location services for this App using the device settings.');
        return Text("permision denied");
        }
//        debugPrint(_positions.last.toString());
        return _displayLocationDetails();
      },
    );
  }
  Widget _displayLocationDetails(){
    if(_position.longitude != null){
      return Container(
        child: Column(
          children: <Widget>[
            Text(_position.toString()),
            Text(_position.timestamp.toIso8601String()),
            Text(_address)
          ],
        ),
      );
    }
    return Center(child: CircularProgressIndicator());
}

  void _toggleListening() {
    LocationOptions locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    final Stream<Position> positionStream =
    Geolocator().getPositionStream(locationOptions);
    _positionStreamSubscription = positionStream.listen((Position position) {
      setState(() {
        _position = position;
        getPlacemark();
      });
    });
  }

  Future<void> getPlacemark() async {
    String address = 'unknown';
    final List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(_position.latitude, _position.longitude);

    if (placemarks != null && placemarks.isNotEmpty) {
      address = _buildAddressString(placemarks.first);
    }

    setState(() {
      _address = '$address';
    });
  }
  static String _buildAddressString(Placemark placemark) {
    final String name = placemark.name ?? '';
    final String city = placemark.locality ?? '';
    final String state = placemark.administrativeArea ?? '';
    final String country = placemark.country ?? '';

    return '$name, $city, $state, $country';
  }


  Widget _permissionDenied(String title,String text){
    return Container(
      child: Card(
        child: Column(
          children: <Widget>[
            Container(child: Text(title),),
            Container(child: Text(text),),
          ],
        ),
      ),
    );
  }
}
