import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'bootstrap.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      Logger().e(
        'Flutter error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    runApp(const DeliveryBootstrap());
  }, (error, stack) {
    Logger().e('Uncaught error', error: error, stackTrace: stack);
  });
}
