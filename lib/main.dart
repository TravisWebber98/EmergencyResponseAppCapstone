import 'package:flutter/material.dart';
import 'core/services/isar/isar_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.init();
  //await FireBaseService.init();    when Firebase is ready
  runApp(const MyApp());
}