import 'dart:io' show exit;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'core/dev/firebase_project_picker_page.dart';
import 'core/dev/firebase_project_selector.dart';
import 'core/di/injection.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'firebase_options.dart';

/// Boots Firebase (with debug project picker) then mounts the real app.
class DeliveryBootstrap extends StatefulWidget {
  const DeliveryBootstrap({super.key});

  @override
  State<DeliveryBootstrap> createState() => _DeliveryBootstrapState();
}

class _DeliveryBootstrapState extends State<DeliveryBootstrap> {
  bool _ready = false;
  bool _loading = true;
  String? _clientId;
  String? _error;
  bool _diConfigured = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (kReleaseMode) {
        await initializeFirebaseForOptions(
          DefaultFirebaseOptions.currentPlatform,
        );
        await _ensureDi();
        if (!mounted) return;
        setState(() {
          _ready = true;
          _loading = false;
          _clientId = 'release';
        });
        return;
      }

      final stored = await getStoredFirebaseClient();
      if (stored == null || stored.isEmpty) {
        if (!mounted) return;
        setState(() {
          _ready = false;
          _loading = false;
          _clientId = null;
        });
        return;
      }

      final options = firebaseOptionsForClient(stored);
      if (options == null) {
        if (!mounted) return;
        setState(() {
          _ready = false;
          _loading = false;
          _error = 'Unknown Firebase client: $stored';
          _clientId = stored;
        });
        return;
      }

      await initializeFirebaseForOptions(options);
      await _ensureDi();
      debugPrint('[DEV] Firebase project: $stored (${options.projectId})');
      if (!mounted) return;
      setState(() {
        _ready = true;
        _loading = false;
        _clientId = stored;
      });
    } catch (e, st) {
      Logger().e('Bootstrap failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
        _ready = false;
      });
    }
  }

  Future<void> _ensureDi() async {
    if (_diConfigured) return;
    await configureDependencies();
    _diConfigured = true;
  }

  Future<void> _resetDi() async {
    if (!_diConfigured) return;
    await GetIt.instance.reset(dispose: true);
    _diConfigured = false;
  }

  Future<void> _onProjectSelected(String clientId) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final options = firebaseOptionsForClient(clientId);
      if (options == null) {
        setState(() {
          _loading = false;
          _error = 'Unknown client: $clientId';
        });
        return;
      }

      await saveFirebaseClient(clientId);

      // Same Firebase project already active — just resume the app.
      if (Firebase.apps.isNotEmpty &&
          Firebase.app().options.projectId == options.projectId) {
        await _ensureDi();
        if (!mounted) return;
        setState(() {
          _clientId = clientId;
          _ready = true;
          _loading = false;
        });
        return;
      }

      final result = await initializeFirebaseForOptions(options);
      if (result == FirebaseInitResult.restartRequired) {
        // Android cannot delete the default Firebase app — cold restart.
        if (mounted) {
          setState(() {
            _loading = false;
            _error =
                'جاري إعادة تشغيل التطبيق لتغيير الفرع…\nRestarting to switch branch…';
          });
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await SystemNavigator.pop();
        exit(0);
      }

      await _resetDi();
      await _ensureDi();
      debugPrint('[DEV] Firebase project: $clientId (${options.projectId})');
      if (!mounted) return;
      setState(() {
        _clientId = clientId;
        _ready = true;
        _loading = false;
      });
    } catch (e, st) {
      Logger().e('Project switch failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
        _ready = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null && !_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _error = null);
                      _boot();
                    },
                    child: const Text('Retry'),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _error = null;
                      _ready = false;
                      _clientId = null;
                    }),
                    child: const Text('Choose project'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brandPrimary),
          useMaterial3: true,
        ),
        home: FirebaseProjectPickerPage(
          currentClientId: _clientId,
          onSelected: _onProjectSelected,
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DishFlowDeliveryApp(),
          if (!kReleaseMode)
            Positioned(
              right: 12,
              bottom: 12,
              child: _DevFirebaseBadge(
                clientId: _clientId ?? '?',
                onTap: () {
                  setState(() {
                    _ready = false;
                    _error = null;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DevFirebaseBadge extends StatelessWidget {
  const _DevFirebaseBadge({
    required this.clientId,
    required this.onTap,
  });

  final String clientId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = kDevFirebaseClients[clientId] ?? clientId;
    return Material(
      color: Colors.orange.shade800,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: AppTextStyles.bodySm(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
