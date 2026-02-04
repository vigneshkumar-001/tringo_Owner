import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tringo_owner/Core/Const/app_logger.dart';

class LocationHelper {
  static final String _apiKey = 'AIzaSyBjUSlWYV4spl2CeZ3ym32HqGROHwEACxk';

  static Future<List<Map<String, dynamic>>> searchPlaces(
      String query, {
        int radiusMeters = 10000, // ✅ 10km by default
        String? sessionToken, // ✅ recommended
      }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (e) {
      AppLogger.log.e('Location error: $e');
    }

    final params = <String, String>{
      'input': q,
      'key': _apiKey,
      'language': 'en',
      'components': 'country:in',
    };

    if (sessionToken != null) {
      params['sessiontoken'] = sessionToken;
    }

    if (position != null) {
      params['location'] = '${position.latitude},${position.longitude}';
      params['radius'] = radiusMeters.toString(); // ✅ nearby preference
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      params,
    );

    final response = await http.get(uri);
    final data = json.decode(response.body);
    AppLogger.log.i('Autocomplete API response: $data');

    if (response.statusCode == 200 && data['status'] == 'OK') {
      final List predictions = data['predictions'];

      final futures = predictions.map<Future<Map<String, dynamic>?>>((p) async {
        final placeId = p['place_id'] as String;

        // ✅ Place details: only need geometry+name+formatted_address
        final detailUri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/place/details/json',
          {
            'place_id': placeId,
            'key': _apiKey,
            if (sessionToken != null) 'sessiontoken': sessionToken,
            'fields': 'name,formatted_address,geometry/location',
          },
        );

        final detailRes = await http.get(detailUri);
        final detailData = json.decode(detailRes.body);

        if (detailRes.statusCode == 200 && detailData['status'] == 'OK') {
          final location = detailData['result']['geometry']['location'];
          final lat = (location['lat'] as num).toDouble();
          final lng = (location['lng'] as num).toDouble();

          double? distanceMeters;
          if (position != null) {
            distanceMeters = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              lat,
              lng,
            );
          }

          return {
            'placeId': placeId,
            'description': (p['description'] ?? '').toString(),
            'name': (detailData['result']['name'] ?? '').toString(),
            'address': (detailData['result']['formatted_address'] ?? '').toString(),
            'lat': lat,
            'lng': lng,
            'distanceMeters': distanceMeters,
          };
        }
        return null;
      }).toList();

      final detailedResults = await Future.wait(futures);
      final results = detailedResults.whereType<Map<String, dynamic>>().toList();

      // ✅ sort: nearest first (if distance available)
      results.sort((a, b) {
        final da = (a['distanceMeters'] as double?) ?? double.infinity;
        final db = (b['distanceMeters'] as double?) ?? double.infinity;
        return da.compareTo(db);
      });

      return results;
    }

    return [];
  }
}

// import 'package:geolocator/geolocator.dart';
//
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import 'package:tringo_owner/Core/Const/app_logger.dart';
//
// class LocationHelper {
//   static final String _apiKey = 'AIzaSyBjUSlWYV4spl2CeZ3ym32HqGROHwEACxk';
//   // String apiKey =  ApiConsents.googleMapApiKey;
//
//   static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
//     final position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.medium,
//     );
//
//     final url =
//         'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query'
//         '&location=${position.latitude},${position.longitude}'
//         '&radius=50000'
//         '&key=$_apiKey';
//
//     final response = await http.get(Uri.parse(url));
//     final data = json.decode(response.body);
//     AppLogger.log.i('Autocomplete API response: $data');
//     if (response.statusCode == 200 && data['status'] == 'OK') {
//       final List predictions = data['predictions'];
//
//       // ✅ Create explicit list of Future<Map<String, dynamic>?>
//       final List<Future<Map<String, dynamic>?>> futures = predictions.map((
//         prediction,
//       ) async {
//         final placeId = prediction['place_id'];
//         final detailUrl =
//             'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey';
//
//         final detailRes = await http.get(Uri.parse(detailUrl));
//         final detailData = json.decode(detailRes.body);
//
//         if (detailRes.statusCode == 200 && detailData['status'] == 'OK') {
//           final location = detailData['result']['geometry']['location'];
//           final lat = location['lat'];
//           final lng = location['lng'];
//
//           final distance = Geolocator.distanceBetween(
//             position.latitude,
//             position.longitude,
//             lat,
//             lng,
//           );
//
//           return {
//             'placeId': placeId,
//             'description': prediction['description'],
//             'lat': lat,
//             'lng': lng,
//             'distance': '${(distance / 1000).round()} km',
//           };
//         }
//         return null;
//       }).toList(); // ✅ Now this is List<Future<Map<String, dynamic>?>>
//
//       final detailedResults = await Future.wait(futures);
//       return detailedResults
//           .whereType<Map<String, dynamic>>()
//           .toList(); // ✅ filter nulls
//     }
//
//     return [];
//   }
// }
