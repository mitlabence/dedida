import 'package:firebase_app_check/firebase_app_check.dart';
// Separate type for dev (debug) and main (release: app integrity token)
// As dev might mostly use debug, while release should only use playIntegrity.
AndroidProvider androidProviderToken = AndroidProvider.playIntegrity;