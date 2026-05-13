import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';


abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();


  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr')
  ];

  
  String get appTitle;

  
  String get homeSubtitle;

  
  String get homeModelCard;

 
  String get homeModelCardSub;

 
  String get homeModelVersion;

 
  String get statSigns;

  
  String get actionLiveCamera;

  
  String get actionStartDetecting;

  
  String get actionLearn;

  
  String get cameraIdleTitle;

  
  String get cameraIdleSubtitle;

 
  String get cameraStartSession;

  
  String get cameraInitialising;

  
  String get learnTitle;

  
  String get learnSearchHint;

 
  String get settingsTitle;

 
  String get settingsLanguageSection;

 
  String get settingsLanguageLabel;

 
  String get settingsPrivacySection;

  
  String get settingsPrivacyTitle;

  
  String get settingsPrivacyDetail;

  
  String get settingsApiTitle;

  
  String get settingsApiDetail;

  
  String get settingsAboutSection;

 
  String get settingsVersion;

  
  String get settingsModel;

  
  String get settingsTeam;

  
  String get signDetailHowToSign;

  String get signDetailTranslations;

  
  String get signDetailColor;

  
  String get signDetailTryLive;

  
  String get signDetailPhotoSoon;

  
  String get noSignDetected;

  
  String get showSignHint;

  String get signThankYou;

  
  String get signNo;

 
  String get signHello;

  
  String get signILY;

  
  String get signPlease;

 
  String get signSad;

  String get statusConnected;

  String get statusConnecting;

  String get statusSyncing;

  String get statusOffline;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}