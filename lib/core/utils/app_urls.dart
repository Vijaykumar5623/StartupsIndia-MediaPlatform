import 'package:url_launcher/url_launcher.dart';

class AppUrls {
  static final Uri events = Uri.parse('https://www.startupsindia.in/events');
  static final Uri programs = Uri.parse(
    'https://www.startupsindia.in/programs',
  );
  static final Uri privacy = Uri.parse('https://www.startupsindia.in/privacy');
  static final Uri deleteAccount = Uri.parse(
    'https://www.startupsindia.in/delete-account',
  );
  static final Uri terms = Uri.parse('https://www.startupsindia.in/terms');
}

/// Query marker appended to first-party links opened from the app. The website
/// reads `?ref=app` to detect app-referred visitors and show a "Back to app"
/// overlay. See docs/web-back-to-app-overlay.md for the web-side spec.
const String kAppRefKey = 'ref';
const String kAppRefValue = 'app';

/// Custom URL scheme the website's "Back to app" button uses to reopen the app.
/// Registered in AndroidManifest.xml and ios/Runner/Info.plist.
const String kAppReturnLink = 'startupsindia://open';

bool _isFirstParty(Uri uri) =>
    uri.host == 'startupsindia.in' || uri.host.endsWith('.startupsindia.in');

/// Adds the app-referral marker to first-party URLs; other hosts are unchanged.
Uri withAppReferral(Uri uri) {
  if (!_isFirstParty(uri)) return uri;
  return uri.replace(
    queryParameters: {...uri.queryParameters, kAppRefKey: kAppRefValue},
  );
}

Future<void> launchExternalUrl(Uri uri) async {
  await launchUrl(withAppReferral(uri), mode: LaunchMode.externalApplication);
}
