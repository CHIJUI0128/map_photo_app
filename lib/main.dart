import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: MapPhotoPage(),
        debugShowCheckedModeBanner: false,
      );
}

class MapPhotoPage extends StatefulWidget {
  @override
  State<MapPhotoPage> createState() => _MapPhotoPageState();
}

class _MapPhotoPageState extends State<MapPhotoPage> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getPermissionAndLocation();
  }

  Future<void> _getPermissionAndLocation() async {
    await Permission.location.request();
    if (await Geolocator.isLocationServiceEnabled()) {
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = LatLng(pos.latitude, pos.longitude));
    }
  }

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('請允許照片權限')),
      );
      return;
    }

    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('選擇了圖片: ${image.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 16,
              ),
              myLocationEnabled: true,
              onMapCreated: (controller) => _controller.complete(controller),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(Icons.photo),
      ),
    );
  }
}