import 'package:latlong2/latlong.dart';

const String apiKey =
    "5b3ce3597851110001cf6248420adc5893254ce39caebf313f1403ce";
const String baseURL =
    "https://api.openrouteservice.org/v2/directions/driving-car";

getRouteURL(LatLng startPoint, LatLng endPoint) {
  final startLat = startPoint.latitude.toString();
  final startLong = startPoint.longitude.toString();
  final endLat = endPoint.latitude.toString();
  final endLong = endPoint.longitude.toString();

  return Uri.parse(
      '$baseURL?api_key=$apiKey&start=$startLong,$startLat&end=$endLong,$endLat');
}
