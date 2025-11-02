import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends GetxService {
  Future<List<Map<String, dynamic>>> findNearestStations(
      List<Map<String, dynamic>> allStations, int count) async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Izin lokasi ditolak oleh pengguna.");
      }

      Position userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      List<Map<String, dynamic>> stationsWithDistance = [];
      for (var station in allStations) {
        
        double stationLat = station['lat'] as double;
        double stationLon = station['lon'] as double;

        double distanceInMeters = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          stationLat,
          stationLon,
        );

        var stationCopy = Map<String, dynamic>.from(station);
        stationCopy['distance_m'] = distanceInMeters;
        stationCopy['distance_km'] = (distanceInMeters / 1000).toStringAsFixed(1);
        stationsWithDistance.add(stationCopy);
      }

      stationsWithDistance.sort((a, b) => 
        a['distance_m'].compareTo(b['distance_m'])
      );

      return stationsWithDistance.take(count).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}