class AppConfig {
  // 🔧 Base URL for Spring Boot backend

  // If testing on an emulator (Android Studio default), use 10.0.2.2:
  //static const String baseUrl = "http://10.42.0.1:8080";

  // If testing on real Android device with same Wi-Fi as PC, use your PC's local IP:
  //static const String baseUrl = "http://192.168.1.10:8080";

  // If testing on Linux desktop Flutter:
  static const String baseUrl = 'http://localhost:8080';
  //static const String baseUrl = 'http://172.20.10.6:8080'; // Uses real IP
}
