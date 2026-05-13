import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';


class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'SignAll';

  @override
  String get homeSubtitle => 'Live-Gebärdenspracherkennung';

  @override
  String get homeModelCard => 'DETR-Modell';

  @override
  String get homeModelCardSub => 'Neuestes Modell: 18April.pt';

  @override
  String get homeModelVersion => 'v2.0';

  @override
  String get statSigns => 'Gebärden';

  @override
  String get actionLiveCamera => 'Live-Kamera';

  @override
  String get actionStartDetecting => 'Erkennung starten';

  @override
  String get actionLearn => 'Lernen';

  @override
  String get cameraIdleTitle => 'Bereit zur Erkennung';

  @override
  String get cameraIdleSubtitle => 'Tippe auf „Start", um dich mit dem Server zu verbinden\nund deine Kamera zu aktivieren';

  @override
  String get cameraStartSession => 'Sitzung starten';

  @override
  String get cameraInitialising => 'Kamera wird initialisiert...';

  @override
  String get learnTitle => 'Lernzentrum';

  @override
  String get learnSearchHint => 'Gebärden suchen...';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguageSection => 'Sprache';

  @override
  String get settingsLanguageLabel => 'App-Sprache';

  @override
  String get settingsPrivacySection => 'Datenschutz & Sicherheit';

  @override
  String get settingsPrivacyTitle => 'Datenschutz';

  @override
  String get settingsPrivacyDetail => 'Von deiner Kamera erfasste Bilder werden ausschließlich zur Gebärdenerkennung direkt an unseren FastAPI-Server gesendet. Sie werden niemals gespeichert, protokolliert oder weitergegeben. Die Verarbeitung erfolgt in Echtzeit und das Bild wird unmittelbar nach der Inferenz verworfen.';

  @override
  String get settingsApiTitle => 'API-Verschlüsselung';

  @override
  String get settingsApiDetail => 'Der gesamte Datenverkehr zwischen der App und dem FastAPI-Backend verwendet TLS (HTTPS). Der Server wird auf Railway gehostet, das verschlüsselte Verbindungen und automatische Zertifikatsverwaltung erzwingt.';

  @override
  String get settingsAboutSection => 'Über';

  @override
  String get settingsVersion => 'App-Version';

  @override
  String get settingsModel => 'Erkennungsmodell';

  @override
  String get settingsTeam => 'Team';

  @override
  String get signDetailHowToSign => 'So wird es gebärdet';

  @override
  String get signDetailTranslations => 'Übersetzungen';

  @override
  String get signDetailColor => 'Erkennungsfarbe';

  @override
  String get signDetailTryLive => 'Im Live-Modus ausprobieren';

  @override
  String get signDetailPhotoSoon => 'Foto folgt bald';

  @override
  String get noSignDetected => 'Keine Gebärde erkannt...';

  @override
  String get showSignHint => 'Zeige der Kamera eine Gebärde';

  @override
  String get signThankYou => 'Danke';

  @override
  String get signNo => 'Nein';

  @override
  String get signHello => 'Hallo';

  @override
  String get signILY => 'Ich liebe dich';

  @override
  String get signPlease => 'Bitte';

  @override
  String get signSad => 'Traurig';

  @override
  String get statusConnected => 'VERBUNDEN';

  @override
  String get statusConnecting => 'VERBINDE...';

  @override
  String get statusSyncing => 'SYNC';

  @override
  String get statusOffline => 'OFFLINE';
}