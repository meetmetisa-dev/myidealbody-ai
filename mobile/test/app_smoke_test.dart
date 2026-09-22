import 'package:flutter_test/flutter_test.dart';
import 'package:myidealbody_ai/app.dart';
import 'package:myidealbody_ai/services/api_service.dart';
import 'package:myidealbody_ai/state/app_controller.dart';
import 'package:myidealbody_ai/state/app_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows English onboarding on a fresh install', (tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'en'});
    final controller = await AppController.load(
      api: ApiService(baseUrl: 'https://example.invalid'),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      AppScope(controller: controller, child: const MyIdealBodyApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Know your meal in one photo'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  test('billing verification is disabled without a user auth provider', () async {
    final api = ApiService(baseUrl: 'https://example.invalid');
    expect(await api.canVerifyPurchases(), isFalse);
  });
}
