import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

//The result of a successful location capture: raw coordinates plus a
//readable label like "Houston, TX". Label may be empty if reverse
//geocoding fails — the coordinates are always present.
class LocationResult {
  final double latitude;
  final double longitude;
  final String label;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.label,
  });
}

//What went wrong if [LocationService.getCurrentLocation] returns null.
//the caller can show a meaningful message rather than a generic failure.
enum LocationFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  unknown,
}

class LocationException implements Exception {
  final LocationFailure failure;
  final String message;
  LocationException(this.failure, this.message);
  @override
  String toString() => 'LocationException($failure): $message';
}

//Thin wrapper around `geolocator` and `geocoding` that handles the
//permission flow and returns a single [LocationResult] callers can store.
class LocationService {
  //Get the device's current location, requesting permission if needed.
  //Throws [LocationException] on failure so the UI can react.
  static Future<LocationResult> getCurrentLocation({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    //1. Make sure the OS-level location service is on. If not, the user
    //has to enable it in system settings, we can't do anything else.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
        LocationFailure.serviceDisabled,
        'Location services are turned off. Enable them in your device '
        'settings to attach a location.',
      );
    }

    //2. Check current permission, then prompt if we don't have it yet.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        LocationFailure.permissionDeniedForever,
        'Location permission is permanently denied. Enable it in app '
        'settings to attach a location.',
      );
    }
    if (permission == LocationPermission.denied) {
      throw LocationException(
        LocationFailure.permissionDenied,
        'Location permission was not granted.',
      );
    }

    //3. Read the current position. Geolocator's timeout fires a
    // TimeoutException, which we wrap so the UI sees a single type.
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
    } catch (e) {
      throw LocationException(
        LocationFailure.timeout,
        'Could not get a location fix in time. Try again outdoors or '
        'with a clearer view of the sky.',
      );
    }

    //4. Reverse-geocode to a friendly label. This is best-effort —
    //if the geocoder is rate-limited or doesn't recognize the spot,
    //we still return the coordinates with an empty label.
    String label = '';
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        label = _formatLabel(placemarks.first);
      }
    } catch (_) {
      //Silently ignore, coordinates alone are still useful.
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      label: label,
    );
  }

  //Build a "City, State" style label from a Placemark, falling back
  //to whatever component is available.
  static String _formatLabel(Placemark p) {
    final parts = <String>[];
    final locality = (p.locality ?? '').trim();
    final subAdmin = (p.subAdministrativeArea ?? '').trim();
    final admin = (p.administrativeArea ?? '').trim();

    // Prefer city; if missing, fall back to county-level.
    if (locality.isNotEmpty) {
      parts.add(locality);
    } else if (subAdmin.isNotEmpty) {
      parts.add(subAdmin);
    }
    if (admin.isNotEmpty) parts.add(admin);
    return parts.join(', ');
  }
}
