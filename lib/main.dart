import 'package:flutter/material.dart';
import 'package:emergency_response_app/core/services/services.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.init();
  //await FireBaseService.init();    when Firebase is ready
  runApp(const MyApp());
}