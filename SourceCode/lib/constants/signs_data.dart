import '../models/sign.dart';
import 'theme.dart';


final List<Sign> kSigns = [

  Sign(
    modelLabel: 'Thank_You',
    name:       'Thank you',
    emoji:      '🙏',
    color:      kSignColors[0],
    imagePath:  'assets/signs/multumesc.PNG',
    locales: {
      'en': const SignLocale(
        word: 'Thank you',
        description:
            "Close the gaps between your fingers on your dominant hand, "
            "hold your hand flat, and touch your fingertips to your chin. "
            "Then gently move your hand away from your face at a slightly "
            "downward angle toward the person you're thanking.",
      ),
      'fr': const SignLocale(
        word: 'Merci',
        description:
            "Fermez les espaces entre vos doigts de la main dominante, "
            "gardez la main à plat et touchez le bout de vos doigts à votre "
            "menton. Ensuite, éloignez doucement votre main de votre visage "
            "en diagonale vers le bas, en direction de la personne que vous "
            "remerciez.",
      ),
      'de': const SignLocale(
        word: 'Danke',
        description:
            "Schließen Sie die Lücken zwischen den Fingern Ihrer dominanten "
            "Hand, halten Sie die Hand flach und berühren Sie mit den "
            "Fingerspitzen Ihr Kinn. Bewegen Sie dann Ihre Hand sanft leicht "
            "nach unten von Ihrem Gesicht weg, in Richtung der Person, der "
            "Sie danken.",
      ),
    },
  ),

  Sign(
    modelLabel: 'No',
    name:       'No',
    emoji:      '🚫',
    color:      kSignColors[1],
    imagePath:  'assets/signs/nu.PNG',
    locales: {
      'en': const SignLocale(
        word: 'No',
        description:
              'Use your index finger, middle finger, and thumb to mimic a '
              'mouth closing — bring the two fingers down onto the thumb '
              'in a snapping motion.',
      ),
      'fr': const SignLocale(
        word: 'Non',
        description:
            "Utilisez votre index, votre majeur et votre pouce pour imiter "
            "une bouche qui se ferme — rapprochez les deux doigts vers le "
            "pouce d'un mouvement vif.",
      ),
      'de': const SignLocale(
        word: 'Nein',
        description:
            "Benutzen Sie Zeigefinger, Mittelfinger und Daumen, um einen "
            "sich schließenden Mund nachzuahmen — bewegen Sie die beiden "
            "Finger mit einer schnellen Bewegung auf den Daumen zu.",
      ),
    },
  ),

  Sign(
    modelLabel: 'Hello',
    name:       'Hello',
    emoji:      '👋',
    color:      kSignColors[2],
    imagePath:  'assets/signs/salut.PNG',
    locales: {
      'en': const SignLocale(
        word: 'Hello',
        description:
            'Touch the fingertips of your dominant hand (flat hand shape) '
            'to your temple or forehead, and move it outward and away, '
            'similar to a salute.',
      ),
      'fr': const SignLocale(
        word: 'Bonjour',
        description:
            "Touchez le bout des doigts de votre main dominante (main à "
            "plat) sur votre tempe ou votre front, puis déplacez-la vers "
            "l'extérieur, comme un salut militaire.",
      ),
      'de': const SignLocale(
        word: 'Hallo',
        description:
            "Berühren Sie mit den Fingerspitzen Ihrer dominanten Hand "
            "(flache Handform) Ihre Schläfe oder Stirn und bewegen Sie die "
            "Hand nach außen, ähnlich wie bei einem militärischen Gruß.",
      ),
    },
  ),

  Sign(
    modelLabel: 'I_Love_You',
    name:       'I love you',
    emoji:      '❤️',
    color:      kSignColors[3],
    imagePath:  'assets/signs/teiubesc.PNG',
    locales: {
      'en': const SignLocale(
        word: 'I love you',
        description:
            'Extend the thumb, index finger, and pinky finger while holding '
            'the middle and ring fingers down against the palm.',
      ),
      'fr': const SignLocale(
        word: "Je t'aime",
        description:
            "Étendez le pouce, l'index et l'auriculaire tout en maintenant "
            "le majeur et l'annulaire repliés contre la paume.",
      ),
      'de': const SignLocale(
        word: 'Ich liebe dich',
        description:
            "Strecken Sie Daumen, Zeigefinger und kleinen Finger aus, "
            "während Mittel- und Ringfinger gegen die Handfläche gedrückt "
            "bleiben.",
      ),
    },
  ),

  Sign(
    modelLabel: 'Please',
    name:       'Please',
    emoji:      '🤲',
    color:      kSignColors[4],
    imagePath:  'assets/signs/terog.PNG',
    locales: {
      'en': const SignLocale(
        word: 'Please',
        description:
            'Place your dominant flat hand (fingers together, thumb extended) '
            'on the center of your chest, palm facing inward. '
            'Move your hand in a circular motion.',
      ),
      'fr': const SignLocale(
        word: "S'il vous plaît",
        description:
            "Posez votre main dominante à plat (doigts joints, pouce tendu) "
            "au centre de votre poitrine, paume vers l'intérieur. "
            "Déplacez la main en mouvement circulaire.",
      ),
      'de': const SignLocale(
        word: 'Bitte',
        description:
            "Legen Sie Ihre dominante flache Hand (Finger zusammen, Daumen "
            "ausgestreckt) auf die Mitte Ihrer Brust, die Handfläche nach "
            "innen gerichtet. Bewegen Sie die Hand in einer kreisenden "
            "Bewegung.",
      ),
    },
  ),

  Sign(
    modelLabel: 'Sad',
    name:       'Sad',
    emoji:      '😢',
    color:      kSignColors[5],
    imagePath:  'assets/signs/trist.PNG',
    locales: {
      'en': const SignLocale(
        word: 'Sad',
        description:
            'Place open hands with palms facing inward in front of your face '
            'and move them downward while mimicking a sad, frowning facial '
            'expression.',
      ),
      'fr': const SignLocale(
        word: 'Triste',
        description:
            "Placez les mains ouvertes, paumes vers l'intérieur, devant "
            "votre visage, puis abaissez-les en adoptant une expression "
            "triste et renfrognée.",
      ),
      'de': const SignLocale(
        word: 'Traurig',
        description:
            "Halten Sie offene Hände mit den Handflächen nach innen vor Ihr "
            "Gesicht und bewegen Sie sie nach unten, während Sie einen "
            "traurigen Gesichtsausdruck nachahmen.",
      ),
    },
  ),

];

Sign? signByName(String modelLabel) {
  try {
    return kSigns.firstWhere((s) => s.modelLabel == modelLabel);
  } catch (_) {
    return null;
  }
}