import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/app_config.dart';
import '../models/nutrition_models.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({
    http.Client? client,
    String? baseUrl,
    Future<String?> Function()? authTokenProvider,
  })
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? AppConfig.apiBaseUrl).replaceAll(RegExp(r'/$'), ''),
        _authTokenProvider = authTokenProvider ?? _noAuthToken,
        _authProviderConfigured = authTokenProvider != null;

  final http.Client _client;
  final String _baseUrl;
  final Future<String?> Function() _authTokenProvider;
  final bool _authProviderConfigured;

  static Future<String?> _noAuthToken() async => null;

  Future<bool> canVerifyPurchases() async {
    if (!_authProviderConfigured) return false;
    final token = await _authTokenProvider();
    return token != null && token.isNotEmpty;
  }

  Future<MealAnalysis> analyzeMeal({
    required String imagePath,
    required String locale,
    required String source,
  }) async {
    late final http.MultipartFile imagePart;
    if (AppConfig.demoMode) {
      imagePart = http.MultipartFile.fromBytes(
        'image',
        base64Decode(_demoPlaceholderPng),
        filename: 'demo-placeholder.png',
        contentType: MediaType('image', 'png'),
      );
    } else {
      final contentType = await _detectImageMediaType(imagePath);
      imagePart = await http.MultipartFile.fromPath(
        'image',
        imagePath,
        contentType: contentType,
      );
    }
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/v1/analyze'),
    )
      ..fields['locale'] = locale
      ..fields['source'] = source
      ..files.add(imagePart);

    late http.StreamedResponse streamed;
    try {
      streamed = await _client.send(request).timeout(const Duration(seconds: 45));
    } on Exception catch (error) {
      throw ApiException('Unable to reach the analysis service: $error');
    }

    final response = await http.Response.fromStream(streamed);
    final body = _decodeObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final nestedError = _map(body['error']);
      throw ApiException(
        (nestedError?['message'] ??
                body['detail'] ??
                body['message'] ??
                'Analysis failed')
            .toString(),
        statusCode: response.statusCode,
      );
    }

    try {
      return MealAnalysis.fromJson(body);
    } on Exception catch (error) {
      throw ApiException('The analysis response was not valid: $error');
    }
  }

  Future<bool> verifyGooglePurchase({
    required String productId,
    required String purchaseToken,
  }) async {
    // Fail closed until the app has real user authentication. Never put the
    // backend's internal billing secret in a mobile build.
    final authToken = await _authTokenProvider();
    if (authToken == null || authToken.isEmpty) return false;
    late http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$_baseUrl/v1/billing/google/verify'),
            headers: {
              'content-type': 'application/json',
              'authorization': 'Bearer $authToken',
            },
            body: jsonEncode({
              'product_id': productId,
              'purchase_token': purchaseToken,
            }),
          )
          .timeout(const Duration(seconds: 25));
    } on Exception {
      return false;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) return false;
    return _decodeObject(response.body)['entitlement_active'] == true;
  }

  Map<String, dynamic> _decodeObject(String raw) {
    if (raw.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value));
      }
      return const {};
    } on FormatException {
      return const {};
    }
  }

  Map<String, dynamic>? _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry('$key', item));
    }
    return null;
  }

  Future<MediaType> _detectImageMediaType(String path) async {
    final file = File(path);
    late List<int> bytes;
    try {
      final handle = await file.open();
      try {
        bytes = await handle.read(16);
      } finally {
        await handle.close();
      }
    } on FileSystemException catch (error) {
      throw ApiException('The selected image could not be read: ${error.message}');
    }

    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return MediaType('image', 'jpeg');
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return MediaType('image', 'png');
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return MediaType('image', 'webp');
    }
    throw const ApiException('Choose a JPEG, PNG, or WebP image.');
  }
}

// 64 × 64 neutral PNG used only in the default fixed-result demo mode.
const _demoPlaceholderPng =
    'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAAAT0lEQVR42u3PQQkAAAgE'
    'sOtfVT82MIJvYbACS0+9FgEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEB'
    'AQEBAQEBAQEBAQGBywIrYYKVXSP0LAAAAABJRU5ErkJggg==';
