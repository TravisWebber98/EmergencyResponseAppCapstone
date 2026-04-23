import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  static const String _cloudName = 'defjmkpmj';
  static const String _uploadPreset = 'emergency_app_preset';

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final jsonData = json.decode(String.fromCharCodes(responseData));

      if (response.statusCode == 200) {
        return jsonData['secure_url'] as String;
      } else {
        print('Cloudinary upload failed: ${jsonData['error']['message']}');
        return null;
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }

  static Future<List<String>> uploadImages(List<File> images) async {
    final urls = <String>[];
    for (final image in images) {
      final url = await uploadImage(image);
      if (url != null) urls.add(url);
    }
    return urls;
  }
}