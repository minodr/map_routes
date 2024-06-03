import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_routes/map_page.dart';
import 'package:map_routes/search_repo.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController pickupLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();
  List pickupSuggestions = [];
  List destinationSuggestions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(padding: EdgeInsets.all(10)),
          SizedBox(
            height: 60,
            width: 300,
            child: TextField(
              controller: pickupLocationController,
              decoration: const InputDecoration(
                labelText: 'Select pickup location',
                contentPadding: EdgeInsets.all(16.0),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                if (value.isEmpty) {
                  pickupSuggestions = [];
                } else {
                  pickupSuggestions = await searchPlaces(value);
                }
                setState(() {});
              },
            ),
          ),
          SizedBox(
            height: 60,
            width: 300,
            child: TextField(
              controller: destinationLocationController,
              decoration: const InputDecoration(
                labelText: 'Select destination location',
                contentPadding: EdgeInsets.all(16.0),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                if (value.isEmpty) {
                  destinationSuggestions = [];
                } else {
                  destinationSuggestions = await searchPlaces(value);
                }
                setState(() {});
              },
            ),
          ),
          SizedBox(
            height: 100,
            width: 400,
            child: Expanded(
              child: ListView.builder(
                itemCount: pickupSuggestions.length,
                itemBuilder: (context, index) {
                  final place = pickupSuggestions[index];
                  return GestureDetector(
                    onTap: () {
                      pickupLocationController.text = place['display_name'];
                      pickupSuggestions = [];
                      setState(() {});
                    },
                    child: ListTile(
                      title: LocationCard(
                        placeName:
                            parseLocation(place['display_name'])['placeName']!,
                        address:
                            parseLocation(place['display_name'])['address']!,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 100,
            width: 400,
            child: Expanded(
              child: ListView.builder(
                itemCount: destinationSuggestions.length,
                itemBuilder: (context, index) {
                  final place = destinationSuggestions[index];
                  return GestureDetector(
                    onTap: () {
                      destinationLocationController.text =
                          place['display_name'];
                      destinationSuggestions = [];
                      setState(() {});
                    },
                    child: ListTile(
                      title: LocationCard(
                        placeName:
                            parseLocation(place['display_name'])['placeName']!,
                        address:
                            parseLocation(place['display_name'])['address']!,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          LatLng source = await getLocation(pickupLocationController.text);
          LatLng destination =
              await getLocation(destinationLocationController.text);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                return MapPage(source: source, destination: destination);
              },
            ),
          );
        },
        child: const Center(
            child: Text(
          'Get Route',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        )),
      ),
    );
  }
}

Future<LatLng> getLocation(String location) async {
  String baseURL =
      "https://nominatim.openstreetmap.org/search?format=json&q=$location";

  final response = await http.get(Uri.parse(baseURL));

  final loc = jsonDecode(response.body)[0];

  final latitude = loc['lat'];
  final longitude = loc['lon'];

  return LatLng(double.parse(latitude), double.parse(longitude));
}

Map<String, String> parseLocation(String locationString) {
  final parts = locationString.split(',');
  if (parts.length < 3) {
    return {'placeName': locationString, 'address': ''};
  }

  final placeName = parts.sublist(0, 3).join(', ');
  final address = parts.skip(3).join(', ');

  return {'placeName': placeName, 'address': address};
}

class LocationCard extends StatelessWidget {
  final String placeName;
  final String address;

  const LocationCard({
    super.key,
    required this.placeName,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              placeName,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              address,
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
