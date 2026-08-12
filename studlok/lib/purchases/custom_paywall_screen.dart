import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../theme/studlok_theme.dart';

/// Hand-rolled paywall, built to diagnose Error 23 independently of
/// RevenueCat's hosted Paywall UI — this calls the same getOfferings() /
/// purchase() SDK methods directly, so if the underlying product still
/// can't be fetched (Missing Metadata in App Store Connect), this will show
/// exactly that instead of RevenueCat's opaque error dialog.
class CustomPaywallScreen extends StatefulWidget {
  const CustomPaywallScreen({super.key});

  @override
  State<CustomPaywallScreen> createState() => _CustomPaywallScreenState();
}

class _CustomPaywallScreenState extends State<CustomPaywallScreen> {
  bool _loading = true;
  String? _loadError;
  Offering? _offering;
  Package? _purchasing;
  String? _purchaseError;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final offerings = await Purchases.getOfferings();
      setState(() {
        _offering = offerings.current;
        _loading = false;
        if (_offering == null) {
          _loadError = 'No current offering found (Offerings.current is null).';
        } else if (_offering!.availablePackages.isEmpty) {
          _loadError = 'Offering "${_offering!.identifier}" has no packages with a fetchable product.';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _loadError = 'getOfferings() failed: $e';
      });
    }
  }

  Future<void> _subscribe(Package package) async {
    setState(() {
      _purchasing = package;
      _purchaseError = null;
    });
    try {
      await Purchases.purchase(PurchaseParams.package(package));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _purchaseError = 'Purchase failed: $e');
    } finally {
      if (mounted) setState(() => _purchasing = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UPGRADE')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.workspace_premium_outlined, size: 64, color: StudlokColors.accent),
                    const SizedBox(height: 16),
                    const Text(
                      'STUDLOK PRO',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: StudlokColors.white, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Unlimited Deep Work and Quiz sessions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: StudlokColors.dimWhite),
                    ),
                    const SizedBox(height: 24),
                    if (_loadError != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: StudlokColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_loadError!, style: const TextStyle(color: Colors.redAccent)),
                      ),
                    if (_offering != null)
                      for (final package in _offering!.availablePackages) ...[
                        ElevatedButton(
                          onPressed: _purchasing != null ? null : () => _subscribe(package),
                          child: _purchasing == package
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : Text(
                                  '${package.storeProduct.title} — ${package.storeProduct.priceString}',
                                ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    if (_purchaseError != null) ...[
                      const SizedBox(height: 8),
                      Text(_purchaseError!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                    ],
                    const SizedBox(height: 8),
                    TextButton(onPressed: _loadOfferings, child: const Text('RETRY')),
                  ],
                ),
        ),
      ),
    );
  }
}
