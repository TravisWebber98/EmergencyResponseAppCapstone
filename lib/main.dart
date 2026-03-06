import 'package:flutter/material.dart';
import 'package:emergency_response_app/core/services/services.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Local cache
  await IsarService.init();
  //Firebase (must be initialized before any Firestore/Auth usage
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Quick Firestore smoke test (won’t crash app if blocked)
  if(kDebugMode) {
    try {
      await FirebaseFirestore.instance.collection('debug').add({
        'ok': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint("Firestore write OK");
    } catch (e) {
      debugPrint("Firestore write FAILED: $e");
    }
  }
  runApp(const MyApp());
}