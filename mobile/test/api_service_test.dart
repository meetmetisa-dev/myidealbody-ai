import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myidealbody_ai/services/api_service.dart';

void main() {
  test('uploads a JPEG with an explicit image content type', () async {
    final directory = await Directory.systemTemp.createTemp('myidealbody-api-test');
    addTearDown(() => directory.delete(recursive: true));
    final image = File('${directory.path}/meal-without-extension');
    await image.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(32, 0)]);

    final client = MockClient((request) async {
      final multipartBody = latin1.decode(request.bodyBytes);
      expect(multipartBody.toLowerCase(), contains('content-type: image/jpeg'));
      expect(multipartBody, contains('filename="meal-upload.jpg"'));
      expect(multipartBody, isNot(contains('meal-without-extension')));
      expect(multipartBody, contains('name="locale"'));
      expect(multipartBody, contains('en'));
      return http.Response(
        jsonEncode({
          'analysis_id': 'test-1',
          'total': {
            'calories': {'min': 100, 'max': 120, 'estimated': 110},
            'protein_g': {'min': 8, 'max': 10, 'estimated': 9},
            'carbs_g': {'min': 12, 'max': 14, 'estimated': 13},
            'fat_g': {'min': 3, 'max': 5, 'estimated': 4},
          },
          'confidence': .7,
          'foods': [],
          'caveats': [],
          'follow_up_questions': [],
          'provider': 'mock',
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final service = ApiService(
      client: client,
      baseUrl: 'https://example.test',
      demoMode: false,
    );
    final result = await service.analyzeMeal(
      imagePath: image.path,
      locale: 'en',
      source: 'camera',
    );
    expect(result.analysisId, 'test-1');
  });

  test('rejects an unsupported image before upload', () async {
    final directory = await Directory.systemTemp.createTemp('myidealbody-api-test');
    addTearDown(() => directory.delete(recursive: true));
    final image = File('${directory.path}/meal.txt');
    await image.writeAsString('not an image');

    final service = ApiService(
      baseUrl: 'https://example.test',
      demoMode: false,
    );
    expect(
      () => service.analyzeMeal(
        imagePath: image.path,
        locale: 'en',
        source: 'gallery',
      ),
      throwsA(isA<ApiException>()),
    );
  });
}
