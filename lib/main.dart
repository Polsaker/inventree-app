import 'dart:async';
import 'dart:io';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:InvenTree/widget/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dsn.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

bool isInDebugMode() {
  bool inDebugMode = false;

  assert(inDebugMode = true);

  return inDebugMode;
}

Future<void> _reportError(dynamic error, dynamic stackTrace) async {

  print('Caught error: $error');

  // Errors thrown in development mode are unlikely to be interesting. You can
  // check if you are running in dev mode using an assertion and omit sending
  // the report.
  if (isInDebugMode()) {
    print(stackTrace);
    print('In dev mode. Not sending report to Sentry.io.');
    return;
  }

  print('Reporting to Sentry.io...');

  // Extract some platform information
  if (Platform.isIOS) {

  } else if (Platform.isAndroid) {

  }

  Sentry.captureException(error, stackTrace: stackTrace).catchError((error) {
    print("Error uploading information to Sentry.io:");
    print(error);
  }).then((response) {
    print("Uploaded information to Sentry.io : ${response.toString()}");
  });
}

void main() async {


  await Sentry.init((options) {
      options.dsn = SENTRY_DSN_KEY;
    },
    //appRunner: () => runApp(InvenTreeApp())
  );

  await runZonedGuarded<Future<void>>(() async {

  WidgetsFlutterBinding.ensureInitialized();

  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isInDebugMode()) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  runApp(InvenTreeApp());

  }, (Object error, StackTrace stackTrace) {
    _reportError(error, stackTrace);
  });

}

class InvenTreeApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      onGenerateTitle: (BuildContext context) => I18N.of(context).appTitle,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        secondaryHeaderColor: Colors.blueGrey,
      ),
      home: InvenTreeHomePage(),
      localizationsDelegates: [
        I18N.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English, no country code
        const Locale('de', ''),
        const Locale('fr', ''),
        const Locale('it', ''),
      ],
    );
  }
}