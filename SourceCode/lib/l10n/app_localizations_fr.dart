import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';


class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SignAll';

  @override
  String get homeSubtitle => 'Détection de langue des signes en direct';

  @override
  String get homeModelCard => 'Modèle DETR Transformer';

  @override
  String get homeModelCardSub => 'Dernier modèle : 18April.pt';

  @override
  String get homeModelVersion => 'v2.0';

  @override
  String get statSigns => 'Signes';

  @override
  String get actionLiveCamera => 'Caméra en direct';

  @override
  String get actionStartDetecting => 'Commencer';

  @override
  String get actionLearn => 'Apprendre';

  @override
  String get cameraIdleTitle => 'Prêt à détecter';

  @override
  String get cameraIdleSubtitle => 'Appuyez sur Démarrer pour vous connecter\nau serveur et activer la caméra';

  @override
  String get cameraStartSession => 'Démarrer la session';

  @override
  String get cameraInitialising => 'Initialisation de la caméra...';

  @override
  String get learnTitle => 'Centre d\'apprentissage';

  @override
  String get learnSearchHint => 'Rechercher des signes...';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguageSection => 'Langue';

  @override
  String get settingsLanguageLabel => 'Langue de l\'application';

  @override
  String get settingsPrivacySection => 'Confidentialité et sécurité';

  @override
  String get settingsPrivacyTitle => 'Confidentialité des données';

  @override
  String get settingsPrivacyDetail => 'Les images capturées par votre caméra sont envoyées directement à notre serveur FastAPI uniquement pour la détection des signes. Elles ne sont jamais stockées, enregistrées ni partagées. Le traitement se fait en temps réel et l\'image est supprimée immédiatement après l\'inférence.';

  @override
  String get settingsApiTitle => 'Chiffrement de l\'API';

  @override
  String get settingsApiDetail => 'Tout le trafic entre l\'application et le backend FastAPI utilise TLS (HTTPS). Le serveur est hébergé sur Railway, qui impose des connexions chiffrées et une gestion automatique des certificats.';

  @override
  String get settingsAboutSection => 'À propos';

  @override
  String get settingsVersion => 'Version de l\'application';

  @override
  String get settingsModel => 'Modèle de détection';

  @override
  String get settingsTeam => 'Équipe';

  @override
  String get signDetailHowToSign => 'Comment signer';

  @override
  String get signDetailTranslations => 'Traductions';

  @override
  String get signDetailColor => 'Couleur de détection';

  @override
  String get signDetailTryLive => 'Essayer en direct';

  @override
  String get signDetailPhotoSoon => 'Photo bientôt disponible';

  @override
  String get noSignDetected => 'Aucun signe détecté...';

  @override
  String get showSignHint => 'Montrez un signe à la caméra';

  @override
  String get signThankYou => 'Merci';

  @override
  String get signNo => 'Non';

  @override
  String get signHello => 'Bonjour';

  @override
  String get signILY => 'Je t\'aime';

  @override
  String get signPlease => 'S\'il vous plaît';

  @override
  String get signSad => 'Triste';

  @override
  String get statusConnected => 'CONNECTÉ';

  @override
  String get statusConnecting => 'CONNEXION...';

  @override
  String get statusSyncing => 'SYNC';

  @override
  String get statusOffline => 'HORS LIGNE';
}