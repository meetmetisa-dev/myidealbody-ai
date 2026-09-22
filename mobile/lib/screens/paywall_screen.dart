import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_config.dart';
import '../l10n/l10n.dart';
import '../services/subscription_service.dart';
import '../state/app_scope.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _selected = AppConfig.annualProductId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = AppScope.of(context).subscriptions;
      if (service.state == BillingState.loading) service.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final service = controller.subscriptions;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: l10n.close,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: AnimatedBuilder(
        animation: service,
        builder: (context, _) {
          if (controller.isPro || service.state == BillingState.active) {
            return _ActiveProView(onManage: _manageSubscription);
          }
          final selectedProduct = _selected == AppConfig.monthlyProductId
              ? service.monthly
              : service.annual;
          final purchasing = service.state == BillingState.purchasing;

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 46,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                l10n.proTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.proSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              _Feature(icon: Icons.all_inclusive_rounded, text: l10n.proFeatureUnlimited),
              _Feature(icon: Icons.stacked_line_chart_rounded, text: l10n.proFeatureRanges),
              _Feature(icon: Icons.rice_bowl_rounded, text: l10n.proFeatureLocal),
              const SizedBox(height: 22),
              _PlanCard(
                title: l10n.monthly,
                price: service.monthly?.price ?? l10n.monthlyPreviewPrice,
                selected: _selected == AppConfig.monthlyProductId,
                isPreview: service.monthly == null,
                onTap: () => setState(() => _selected = AppConfig.monthlyProductId),
              ),
              const SizedBox(height: 10),
              _PlanCard(
                title: l10n.annual,
                badge: l10n.bestValue,
                price: service.annual?.price ?? l10n.annualPreviewPrice,
                selected: _selected == AppConfig.annualProductId,
                isPreview: service.annual == null,
                onTap: () => setState(() => _selected = AppConfig.annualProductId),
              ),
              if (service.products.isEmpty || !service.verificationReady) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              service.products.isEmpty
                                  ? l10n.billingUnavailable
                                  : l10n.billingVerificationUnavailable,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.billingPreview,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
              if (service.state == BillingState.error) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.purchaseVerificationFailed,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: purchasing ||
                        selectedProduct == null ||
                        !service.verificationReady
                    ? null
                    : () => service.purchase(selectedProduct),
                child: purchasing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 10),
                          Text(l10n.purchasePending),
                        ],
                      )
                    : Text(l10n.subscribe),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: purchasing || !service.verificationReady
                    ? null
                    : service.restore,
                child: Text(l10n.restorePurchases),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.continueFree),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.renewsAutomatically,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _manageSubscription() async {
    final uri = Uri.https(
      'play.google.com',
      '/store/account/subscriptions',
      {'package': AppConfig.androidPackageName},
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 21, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
      );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.selected,
    required this.isPreview,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final String? badge;
  final bool selected;
  final bool isPreview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: '$title, $price',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected ? colors.primaryContainer.withValues(alpha: .5) : colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: Theme.of(context).textTheme.titleMedium),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                color: colors.onPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      price,
                      style: TextStyle(
                        color: isPreview ? colors.onSurfaceVariant : colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveProView extends StatelessWidget {
  const _ActiveProView({required this.onManage});

  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 72,
              ),
              const SizedBox(height: 16),
              Text(context.l10n.proActive, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onManage,
                child: Text(context.l10n.manageSubscription),
              ),
            ],
          ),
        ),
      );
}
