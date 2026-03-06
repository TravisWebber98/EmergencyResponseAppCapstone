import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/isar/isar_service.dart';
import 'package:emergency_response_app/app.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
