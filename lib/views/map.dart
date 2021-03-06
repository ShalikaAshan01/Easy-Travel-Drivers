import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csse/auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyMapState();
  }
}

class _MyMapState extends State<MyMap> {
  String _busRef="";
  StreamSubscription<Position> _positionStreamSubscription;
  Position _position = Position();
  String _address = '';
  GoogleMapController mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  LatLng _latLng = LatLng(7.8731, 80.7718);
  BaseAuth _auth = Auth();

  @override
  void initState() {
    super.initState();
    _auth.currentUser().then((FirebaseUser user){
      Firestore.instance.collection("inspectors").document(user.uid).get()
          .then((DocumentSnapshot documentSnapshot){
            if(mounted)
              setState(() {
                _busRef = documentSnapshot.data['bus'];
              });
            addMarker();
      });
    });
    _listening();
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
            Text(_address),
            Expanded(
                child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition:
                  CameraPosition(target: _latLng, zoom: 10.0),
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
      if(mounted)
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
                textAlign: TextAlign.center,
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

  void addMarker(){

    Firestore.instance.collection('buses').document(_busRef).get()
        .then((DocumentSnapshot snapshot){
       String _routeNo = snapshot.data['route'];
       
       Firestore.instance.collection('routes').document(_routeNo)
           .collection('points').getDocuments()
       .then((QuerySnapshot querySnapshot){
         List<DocumentSnapshot> documents = querySnapshot.documents;
         for(int i=0; i<documents.length; i++){
           DocumentSnapshot doc = documents[i];
           GeoPoint geoPoint = doc.data["location"];
           MarkerId markerId = MarkerId(doc.data['name']);
           final Marker marker = Marker(
                      markerId: markerId,
                      position: LatLng(geoPoint.latitude,geoPoint.longitude),
                      infoWindow: InfoWindow(title: doc.data['name']),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
                  markers[markerId] = marker;
                }

         
       });
       
    });

//    Firestore.instance
//        .collection('turns')
//        .where('bus', isEqualTo: _busRef)
//        .where('status',isEqualTo: 'ongoing')
//        .limit(1)
//        .snapshots().listen((QuerySnapshot snapshot) async {
//
//          if(snapshot.documents.length != 0){
//            DocumentSnapshot documentSnapshot = snapshot.documents.last;
//
//            List<dynamic> array = documentSnapshot.data['passengers'];
//
//            for(int i=0; i < array.length; i++){
//              DocumentReference dRef =  array.elementAt(i);
//              dRef.get().then((DocumentSnapshot dSnap){
//                if(dSnap.data['status']=="ongoing" && dSnap.data['endPointCoordinate'] != null){
//                  GeoPoint geoPoint = dSnap.data['endPointCoordinate'];
//                  MarkerId id = MarkerId(dSnap.documentID);
//                  final Marker marker = Marker(
//                      markerId: id,
//                      position: LatLng(geoPoint.latitude,geoPoint.longitude),
//                      infoWindow: InfoWindow(title: dSnap['end_point']),
//                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
//                  markers[id] = marker;
//                }
//              });
//            }
//          }
//    });

  }
}