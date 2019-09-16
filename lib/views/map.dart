import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:csse/views/qr_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/services.dart';

class MyMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyMapState();
  }
}

class _MyMapState extends State<MyMap> {

  //TODO add bus id
  final String busRef = "r1zQyo9NkcKj7cqkv91X";
  StreamSubscription<Position> _positionStreamSubscription;
  Position _position = Position();
  Placemark _placemark;
  String _address = '';

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  /// the internet connectivity status
  bool isOnline = true;

  GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  LatLng _latLng = LatLng(7.8731, 80.7718);

  @override
  void initState() {
    super.initState();
    _listening();
    initConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      await _updateConnectionStatus().then((bool isConnected) => setState(() {
            isOnline = isConnected;
            if (!isConnected) {
              Alert(
                context: context,
                title: "Whoops",
                desc:
                    "Slow or no internet connection. Please check internet connection",
                buttons: [
                  DialogButton(
                    child: Text(
                      "Ok",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      AppSettings.openWIFISettings();
                      Navigator.pop(context);
                    },
                    width: 120,
                  )
                ],
              ).show();
            }
          }));
    });
  }

  @override
  void didUpdateWidget(MyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _listening();
  }

  @override
  void dispose() {
    super.dispose();
    _positionStreamSubscription.cancel();
    _connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: displayLocation());
  }

  ///check permission and display map
  Widget displayLocation() {
    return FutureBuilder<GeolocationStatus>(
      future: Geolocator().checkGeolocationPermissionStatus(),
      builder:
          (BuildContext context, AsyncSnapshot<GeolocationStatus> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == GeolocationStatus.denied) {
          PermissionHandler()
              .shouldShowRequestPermissionRationale(PermissionGroup.location)
              .then((bool val) {
            if (!val) {
              Alert(
                context: context,
                title: "Access to location denied",
                desc:
                    "Allow access to the location services for this App using the device settings.After Enabling please restart the app",
                buttons: [
                  DialogButton(
                    child: Text(
                      "Ok",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () => PermissionHandler().openAppSettings(),
                    width: 120,
                  )
                ],
              ).show();
            }
          });

          return _permissionDenied('Access to location denied',
              'Allow access to the location services for this App using the device settings.');
        }
        return _displayMap();
      },
    );
  }

  ///show map
  Widget _displayMap() {
    if (_position.longitude != null) {
      return Container(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text("Show Landmarks"),
              color: Colors.green,
              onPressed: (){
                setState(() {
                  addMarker();
                });
              },
            ),
            Text(_address),
            Expanded(
                child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition:
                  CameraPosition(target: _latLng, zoom: 20.0),
              myLocationEnabled: true,
                  markers: Set<Marker>.of(markers.values),
            ))
          ],
        ),
      );
    }
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(child: CircularProgressIndicator()),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "Loading...",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      ],
    ));
  }

  ///get current location
  void _listening() {
    LocationOptions locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    final Stream<Position> positionStream =
        Geolocator().getPositionStream(locationOptions);
    _positionStreamSubscription =
        positionStream.listen((Position position) async {
      mapController?.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(_position.latitude, _position.longitude),
            zoom: 20.0),
      ));
      _position = position;
      getPlacemark();
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

  Widget _permissionDenied(String title, String text) {
    return Container(
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ),
            Container(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// initialize connectivity checking
  /// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    await _updateConnectionStatus().then((bool isConnected) => setState(() {
          isOnline = isConnected;
        }));
  }

  Future<bool> _updateConnectionStatus() async {
    bool isConnected;
    try {
      final List<InternetAddress> result =
          await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
      return false;
    }
    return isConnected;
  }

  void addMarker(){
//    MarkerId id = MarkerId("fsefse");
//    final Marker marker = Marker(
//        markerId: id,
//        position: _latLng,
//        infoWindow: InfoWindow(title: "Las"),
//        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));

    Firestore.instance
        .collection('turns')
        .where('bus', isEqualTo: busRef)
        .orderBy("startTime", descending: true)
        .limit(1)
        .snapshots().listen((QuerySnapshot snapshot) async {

          DocumentSnapshot documentSnapshot = snapshot.documents.last;

//          DocumentReference reference = documentSnapshot.data['passengers'];
          List<dynamic> array = documentSnapshot.data['passengers'];

          for(int i=0; i < array.length; i++){
            DocumentReference dRef =  array.elementAt(i);
            dRef.get().then((DocumentSnapshot dSnap){
              GeoPoint geoPoint = dSnap['endPointCoordinate'];
              MarkerId id = MarkerId(dSnap.documentID);
              final Marker marker = Marker(
                  markerId: id,
                  position: LatLng(geoPoint.latitude,geoPoint.longitude),
                  infoWindow: InfoWindow(title: dSnap['end_point']),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
              markers[id] = marker;
            });
          }

//          DocumentSnapshot data = await reference.get();
//          debugPrint(reference.last.toString());

    });

  }
}