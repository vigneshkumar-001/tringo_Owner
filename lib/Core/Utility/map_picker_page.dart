import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key, this.initialLatLng});

  final LatLng? initialLatLng;

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  GoogleMapController? _mapController;
  LatLng? _selected;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Initial position: passed value அல்லது current gps
    if (widget.initialLatLng != null) {
      _selected = widget.initialLatLng;
      setState(() => _loading = false);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _selected = LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      _selected = const LatLng(13.0827, 80.2707); // fallback (Chennai)
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _selected == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _selected);
            },
            child: const Text('OK'),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selected!,
              zoom: 16,
            ),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId('picked'),
                position: _selected!,
                draggable: true,
                onDragEnd: (latLng) => setState(() => _selected = latLng),
              ),
            },
            onTap: (latLng) => setState(() => _selected = latLng),
          ),


          // Optional: center hint text
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Lat: ${_selected!.latitude.toStringAsFixed(6)}   '
                      'Lng: ${_selected!.longitude.toStringAsFixed(6)}',
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
