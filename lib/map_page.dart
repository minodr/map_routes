import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_routes/api.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  final LatLng source;
  final LatLng destination;

  const MapPage({
    super.key,
    required this.source,
    required this.destination,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<LatLng> points = [];

  void getCoordinates() async {
    final response = await http.get(
      getRouteURL(widget.source, widget.destination),
    );

    setState(() {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coordinates =
            data['features'][0]['geometry']['coordinates'] as List;

        points = coordinates
            .map((e) => LatLng(e[1].toDouble(), e[0].toDouble()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: widget.source,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: widget.source,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              Marker(
                point: widget.destination,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 30,
                ),
              ),
            ],
          ),
          PolylineLayer(
            polylineCulling: false,
            polylines: [
              Polyline(
                points: points,
                color: Colors.blue,
                strokeWidth: 5,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getCoordinates();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
