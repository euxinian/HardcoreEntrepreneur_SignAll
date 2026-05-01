const String kApiKey = String.fromEnvironment(
  'SIGNALL_API_KEY',
  defaultValue: '',
);

const String kServerBase = String.fromEnvironment(
  'SERVER_URL',
  defaultValue: '',
);

const Duration kCaptureInterval = Duration(milliseconds: 200);

const Duration kRequestTimeout = Duration(seconds: 5);

const Duration kStartupPingTimeout = Duration(seconds: 90);