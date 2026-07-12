import 'package:flutter_test/flutter_test.dart';
import 'package:startups_india_media_platform/core/utils/app_urls.dart';

void main() {
  group('withAppReferral', () {
    test('adds ref=app to first-party links', () {
      final out = withAppReferral(
        Uri.parse('https://www.startupsindia.in/events'),
      );
      expect(out.queryParameters['ref'], 'app');
    });

    test('adds ref=app to the bare apex domain', () {
      final out = withAppReferral(Uri.parse('https://startupsindia.in/contact'));
      expect(out.queryParameters['ref'], 'app');
    });

    test('preserves existing query parameters', () {
      final out = withAppReferral(
        Uri.parse('https://www.startupsindia.in/p?id=7'),
      );
      expect(out.queryParameters['id'], '7');
      expect(out.queryParameters['ref'], 'app');
    });

    test('leaves third-party links untouched', () {
      final url = 'https://www.youtube.com/@startupsindiaofficial';
      expect(withAppReferral(Uri.parse(url)).toString(), url);
    });

    test('does not match look-alike domains', () {
      final url = 'https://startupsindia.in.evil.com/x';
      expect(withAppReferral(Uri.parse(url)).queryParameters.containsKey('ref'),
          isFalse);
    });
  });
}
