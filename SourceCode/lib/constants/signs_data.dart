import '../models/sign.dart';
import 'theme.dart';

final List<Sign> kSigns = [
  Sign(
    modelLabel: 'Thank_You',       
    name: 'Thank you',
    translation: '🇫🇷 Merci',
    secondTranslation: '🇩🇪 Danke',
    color: kSignColors[0],
    imagePath: 'assets/signs/multumesc.PNG',
    emoji: '🙏',
    description:
        "Close the gaps between your fingers on your dominant hand, hold your hand flat, and touch your fingertips to your chin. Then gently move your hand away from your face at a slightly downward angle toward the person you're thanking.",
  ),
  Sign(
    modelLabel: 'No',
    name: 'No',
    translation: '🇫🇷 Non',
    secondTranslation: '🇩🇪 Nein',
    color: kSignColors[1],
    imagePath: 'assets/signs/nu.PNG',
    emoji: '🚫',
    description:
        'Use your index finger, middle finger, and thumb to mimic a mouth closing.',
  ),
  Sign(
    modelLabel: 'Hello',
    name: 'Hello',
    translation: '🇫🇷 Bonjour',
    secondTranslation: '🇩🇪 Hallo',
    color: kSignColors[2],
    imagePath: 'assets/signs/salut.PNG',
    emoji: '👋',
    description:
        'Touch the fingertips of your dominant hand (flat hand shape) to your temple or forehead, and move it outward and away, similar to a salute',
  ),
  Sign(
    modelLabel: 'I_Love_You',
    name: 'I love you',
    translation: "🇫🇷 Je t'aime",
    secondTranslation: "🇩🇪 Ich liebe dich",
    color: kSignColors[3],
    imagePath: 'assets/signs/teiubesc.PNG',
    emoji: '❤️',
    description:
        'Extend the thumb, index finger, and pinky finger while holding the middle and ring fingers down against the palm.',
  ),
  Sign(
    modelLabel: 'Please',
    name: 'Please',
    translation: "🇫🇷 S'il te plaît",
    secondTranslation: "🇩🇪 Bitte",
    color: kSignColors[4],
    imagePath: 'assets/signs/terog.PNG',
    emoji: '🤲',
    description:
        'Place your dominant flat hand (fingers together, thumb extended) on the center of your chest, palm facing inward.'
        'Move your hand in a circular motion.',
  ),
  Sign(
    modelLabel: 'Sad',
    name: 'Sad',
    translation: '🇫🇷 Triste',
    secondTranslation: '🇩🇪 Traurig',
    color: kSignColors[5],
    imagePath: 'assets/signs/trist.PNG',
    emoji: '😢',
    description:
        'Place open hands with palms facing inward in front of your face and move them downward while mimicking a sad, frowning facial expression',
  ),
];

Sign? signByName(String modelLabel) {
  try {
    return kSigns.firstWhere((s) => s.modelLabel == modelLabel);
  } catch (_) {
    return null;
  }
}