import 'package:flutter_test/flutter_test.dart';
import 'package:myidealbody_ai/services/api_service.dart';
import 'package:myidealbody_ai/services/subscription_service.dart';

void main() {
  test('local demo disables billing without initializing Play Billing', () async {
    final service = SubscriptionService(
      api: ApiService(
        baseUrl: 'not-required-in-local-demo',
        demoMode: true,
      ),
      onEntitlementChanged: (_) async {},
    );
    addTearDown(service.dispose);

    await service.initialize();

    expect(service.state, BillingState.unavailable);
    expect(service.products, isEmpty);
    expect(service.verificationReady, isFalse);
    expect(service.errorMessage, isNull);
  });
}
