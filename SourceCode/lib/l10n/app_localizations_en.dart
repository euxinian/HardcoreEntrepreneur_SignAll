import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SignAll';

  @override
  String get homeSubtitle => 'Live sign language detection';

  @override
  String get homeModelCard => 'DETR Model';

  @override
  String get homeModelCardSub => 'Latest Model: 18April.pt';

  @override
  String get homeModelVersion => 'v2.0';

  @override
  String get statSigns => 'Signs';

  @override
  String get actionLiveCamera => 'Live Camera';

  @override
  String get actionStartDetecting => 'Start detecting';

  @override
  String get actionLearn => 'Learn';

  @override
  String get cameraIdleTitle => 'Ready to detect';

  @override
  String get cameraIdleSubtitle => 'Tap start to connect to the server\nand enable your camera';

  @override
  String get cameraStartSession => 'Start Session';

  @override
  String get cameraInitialising => 'Initialising camera...';

  @override
  String get learnTitle => 'Learning Center';

  @override
  String get learnSearchHint => 'Search signs...';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageLabel => 'App Language';

  @override
  String get settingsPrivacySection => 'Privacy & Security';

  @override
  String get settingsPrivacyTitle => 'Data Privacy';

  @override
  String get settingsPrivacyDetail => 'Images captured by your camera are sent directly to our FastAPI server for sign detection only. They are never stored, logged, or shared. Processing happens in real-time and the image is discarded immediately after inference.';

  @override
  String get settingsApiTitle => 'API Encryption';

  @override
  String get settingsApiDetail => 'All traffic between the app and the FastAPI backend uses TLS (HTTPS). The server is hosted on Railway, which enforces encrypted connections and automatic certificate management.';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsVersion => 'App Version';

  @override
  String get settingsModel => 'Detection Model';

  @override
  String get settingsTeam => 'Team';

  @override
  String get signDetailHowToSign => 'How to sign it';

  @override
  String get signDetailTranslations => 'Translations';

  @override
  String get signDetailColor => 'Detection Colour';

  @override
  String get signDetailTryLive => 'Try in live mode';

  @override
  String get signDetailPhotoSoon => 'Photo coming soon';

  @override
  String get noSignDetected => 'No sign detected...';

  @override
  String get showSignHint => 'Show a sign to the camera';

  @override
  String get signThankYou => 'Thank You';

  @override
  String get signNo => 'No';

  @override
  String get signHello => 'Hello';

  @override
  String get signILY => 'I Love You';

  @override
  String get signPlease => 'Please';

  @override
  String get signSad => 'Sad';

  @override
  String get statusConnected => 'CONNECTED';

  @override
  String get statusConnecting => 'CONNECTING...';

  @override
  String get statusSyncing => 'SYNCING';

  @override
  String get statusOffline => 'OFFLINE';
}