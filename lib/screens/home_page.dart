import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MapType typeMap = MapType.normal;
  Completer<GoogleMapController> mController = Completer<GoogleMapController>();

  List<MapType> list = [
    MapType.satellite,
    MapType.hybrid,
    MapType.normal,
    MapType.terrain,
  ];

  Set<Marker> marker = {
    /*Marker(
      markerId: const MarkerId("Marker 1"),
      position: const LatLng(26.3978, 74.0180),
      infoWindow: InfoWindow(
        title: "Mehrangarh Fort",
        snippet: "Jodhpur",
        onTap: () {},
      ),
    ),*/
  };

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    if (await checkIfGetCurrLoc()) {
      var currPos = await Geolocator.getCurrentPosition();
      var currentPosition = CameraPosition(
        target: LatLng(currPos.latitude, currPos.longitude),
      );

      var mapController = await mController.future;
      mapController
          .animateCamera(CameraUpdate.newCameraPosition(currentPosition));
    } else {
      print(
          "Due to location service error, we are unable to get your location");
    }
  }

  Future<bool> checkIfGetCurrLoc() async {
    bool serviceEnable;
    LocationPermission permission;

    serviceEnable = await Geolocator.isLocationServiceEnabled();

    if (serviceEnable) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        } else if (permission == LocationPermission.deniedForever) {
          return false;
        } else {
          return true;
        }
      } else {
        return true;
      }
    } else {
      print("Location Service disabled");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Google Map",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton(
              dropdownColor: Colors.blue.shade400,
              value: typeMap,
              onChanged: (value) {
                setState(() {
                  typeMap = value as MapType;
                });
              },
              items: list.map((MapType type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: GoogleMap(
        mapType: typeMap,
        markers: marker,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (loadedController) {
          mController.complete(loadedController);
          setState(() {});
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(26.3978, 74.0180),
          tilt: 85,
          zoom: 1,
        ),
        onTap: (location) {
          marker.add(Marker(
            markerId: const MarkerId("New"),
            position: location,
          ));
          setState(() {});
        },
      ),
    );
  }
}
