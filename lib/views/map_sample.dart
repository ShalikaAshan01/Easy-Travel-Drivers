import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  final double latitude;
  final double longitude;
  MapSample(this.latitude, this.longitude);

  @override
  State<MapSample> createState() => MapSampleState(latitude,longitude);
}

class MapSampleState extends State<MapSample> {
  final double latitude;
  final  double longitude;

  MapSampleState(this.latitude, this.longitude);

  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(6.9103652, 79.9639318);
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  static MarkerId markerId = MarkerId("My Location");

  Marker marker = Marker(
      markerId: markerId,
    position: _center,
    infoWindow: InfoWindow(title: "Las"),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
  );

  @override
  Widget build(BuildContext context) {
    markers[markerId] = marker;
    return  GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
      markers: Set<Marker>.of(markers.values),
    );
  }
}