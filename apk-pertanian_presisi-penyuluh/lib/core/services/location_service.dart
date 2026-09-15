import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isSuccess;
  final String? errorMessage;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.accuracy = 0.0,
    required this.isSuccess,
    this.errorMessage,
  });

  factory LocationResult.failure(String message) {
    return LocationResult(
      latitude: 0.0,
      longitude: 0.0,
      isSuccess: false,
      errorMessage: message,
    );
  }
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Gets high-accuracy GPS coordinates with a 10-second timeout and fallback mechanism.
  Future<LocationResult> getCurrentLocation() async {
    try {
      // 1. Verify if location services are enabled on the device
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.failure("Harap aktifkan GPS / Layanan Lokasi di HP Anda.");
      }

      // 2. Check & Request Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.failure("Izin akses lokasi ditolak oleh pengguna.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.failure("Izin lokasi ditolak permanen. Silakan aktifkan via Pengaturan HP.");
      }

      // 3. Attempt to fetch current position with a 10-second timeout
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } on TimeoutException {
        // Fallback to last known position on timeout
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        return LocationResult(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          isSuccess: true,
        );
      } else {
        return LocationResult.failure("Gagal mendapatkan koordinat GPS. Coba lagi di tempat terbuka.");
      }
    } catch (e) {
      return LocationResult.failure("Terjadi kesalahan saat membaca GPS: $e");
    }
  }
}
