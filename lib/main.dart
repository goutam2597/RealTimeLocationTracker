import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<Marker> _markers = {};
  final List<LatLng> _polylineCoordinates = [const LatLng(37.42235769874641, -122.08476707421134)];
  late GoogleMapController _mapController;
  late LatLng _userLocation = const LatLng(0, 0);
  late Timer _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _locationUpdateTimer.cancel();
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _polylineCoordinates.add(_userLocation); // Add current location to polyline
      });
      _markers.clear();

      _markers.add(Marker(
        markerId: const MarkerId('userLocation'),
        position: _userLocation,
        infoWindow: InfoWindow(
          title: 'My Current Location',
          snippet: 'Lat: ${position.latitude}, Long: ${position.longitude}',
        ),
      ));

      _animateToUserLocation();
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _animateToUserLocation() {
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(_userLocation, 17.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
      ),
      body: GoogleMap(
        markers: _markers,
        polylines: {
          Polyline(
            polylineId: const PolylineId('userRoute'),
            color: Colors.blue,
            points: _polylineCoordinates,
            width: 5,
          ),
        },
        onMapCreated: (controller) {
          _mapController = controller;
        },
        zoomControlsEnabled: false,
        initialCameraPosition: CameraPosition(
          zoom: 18,
          target: _userLocation,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _animateToUserLocation,
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}
