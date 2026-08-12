import 'package:flutter_test/flutter_test.dart';

import 'package:dishflow_delivery/core/config/app_config.dart';

void main() {
  test('AppConfig defaults are set', () {
    expect(AppConfig.brandId, isNotEmpty);
    expect(AppConfig.apiPrefix, '/v1');
    expect(AppConfig.gpsInterval.inSeconds, 5);
  });
}
