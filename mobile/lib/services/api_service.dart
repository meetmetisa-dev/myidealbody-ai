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
    bool? demoMode,
  })
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? AppConfig.apiBaseUrl).replaceAll(RegExp(r'/$'), ''),
        _authTokenProvider = authTokenProvider ?? _noAuthToken,
        _authProviderConfigured = authTokenProvider != null,
        _demoMode = demoMode ?? AppConfig.demoMode;

  final http.Client _client;
  final String _baseUrl;
  final Future<String?> Function() _authTokenProvider;
  final bool _authProviderConfigured;
  final bool _demoMode;

  bool get isDemoMode => _demoMode;

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
    if (_demoMode) {
      return _localDemoAnalysis(locale);
    }
    final contentType = await _detectImageMediaType(imagePath);
    final imagePart = await http.MultipartFile.fromPath(
      'image',
      imagePath,
      filename: _safeUploadFilename(contentType),
      contentType: contentType,
    );
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

  String _safeUploadFilename(MediaType contentType) =>
      switch (contentType.subtype) {
        'jpeg' => 'meal-upload.jpg',
        'png' => 'meal-upload.png',
        'webp' => 'meal-upload.webp',
        _ => 'meal-upload.bin',
      };

  MealAnalysis _localDemoAnalysis(String locale) {
    final indonesian = locale.toLowerCase().startsWith('id');
    return MealAnalysis(
      analysisId: 'local-demo-fixed',
      calories: const NutrientRange(min: 388, max: 700, estimated: 544),
      protein: const NutrientRange(min: 24.3, max: 44.7, estimated: 34.5),
      carbs: const NutrientRange(min: 47.5, max: 82.8, estimated: 65.2),
      fat: const NutrientRange(min: 10.6, max: 20.1, estimated: 15.3),
      confidence: .72,
      foods: [
        FoodEstimate(
          id: 'nasi_putih',
          name: indonesian ? 'Nasi putih' : 'Cooked white rice',
          quantity: 180,
          unit: 'g',
          calories: const NutrientRange(min: 174, max: 294, estimated: 234),
          protein: const NutrientRange(min: 3.2, max: 5.4, estimated: 4.3),
          carbs: const NutrientRange(min: 37.8, max: 63.7, estimated: 50.8),
          fat: const NutrientRange(min: .4, max: .7, estimated: .5),
          confidence: .82,
        ),
        FoodEstimate(
          id: 'ayam_goreng',
          name: indonesian ? 'Ayam goreng' : 'Fried chicken',
          quantity: 100,
          unit: 'g',
          calories: const NutrientRange(min: 173, max: 319, estimated: 246),
          protein: const NutrientRange(min: 19, max: 35, estimated: 27),
          carbs: const NutrientRange(min: 5.6, max: 10.4, estimated: 8),
          fat: const NutrientRange(min: 8.4, max: 15.6, estimated: 12),
          confidence: .72,
        ),
        FoodEstimate(
          id: 'sayur_campur',
          name: indonesian ? 'Sayur campur tumis' : 'Stir-fried mixed vegetables',
          quantity: 80,
          unit: 'g',
          calories: const NutrientRange(min: 41, max: 87, estimated: 64),
          protein: const NutrientRange(min: 2.1, max: 4.3, estimated: 3.2),
          carbs: const NutrientRange(min: 4.1, max: 8.7, estimated: 6.4),
          fat: const NutrientRange(min: 1.8, max: 3.8, estimated: 2.8),
          confidence: .58,
        ),
      ],
      caveats: indonesian
          ? const [
              'Ini adalah perkiraan, bukan pengukuran medis.',
              'Minyak, santan, gula, dan bahan tersembunyi mungkin tidak terlihat di foto.',
              'Data gizi demo bersifat perkiraan; periksa makanan dan porsinya.',
            ]
          : const [
              'This is an estimate, not a medical measurement.',
              'Oil, coconut milk, sugar, and other hidden ingredients may not be visible.',
              'Demo nutrition data is approximate; review the foods and portions.',
            ],
      questions: [
        FollowUpQuestion(
          id: 'confirm_portion',
          type: 'portion_confirmation',
          prompt: indonesian
              ? 'Apakah perkiraan ukuran porsinya sudah benar?'
              : 'Does the estimated portion size look right?',
          options: [
            FollowUpOption(id: 'smaller', label: indonesian ? 'Lebih kecil' : 'Smaller'),
            FollowUpOption(id: 'correct', label: indonesian ? 'Sudah sesuai' : 'Looks right'),
            FollowUpOption(id: 'larger', label: indonesian ? 'Lebih besar' : 'Larger'),
          ],
        ),
        FollowUpQuestion(
          id: 'hidden_oil',
          type: 'single_choice',
          prompt: indonesian
              ? 'Berapa banyak minyak atau mentega tambahan yang digunakan?'
              : 'How much added oil or butter was used?',
          options: [
            FollowUpOption(id: 'none', label: indonesian ? 'Tidak ada' : 'None'),
            FollowUpOption(
              id: 'one_tsp',
              label: indonesian ? 'Sekitar 1 sendok teh' : 'About 1 teaspoon',
            ),
            FollowUpOption(
              id: 'one_tbsp',
              label: indonesian ? 'Sekitar 1 sendok makan' : 'About 1 tablespoon',
            ),
            FollowUpOption(id: 'unknown', label: indonesian ? 'Tidak yakin' : 'Not sure'),
          ],
        ),
      ],
      provider: 'mock_demo',
    );
  }
}
