import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:emergency_response_app/models/models.dart';

class IsarService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open(
      [
        CommunitySchema,
        AccountSchema,
        // add more schemas here later
      ],
      directory: dir.path,
    );
  }
}