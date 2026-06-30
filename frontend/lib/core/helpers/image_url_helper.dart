import '../constants/api_constants.dart';

class ImageUrlHelper {
  const ImageUrlHelper._();

  static String? resolve(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return null;
    }

    final path = imagePath.trim();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final apiUri = Uri.parse(ApiConstants.baseUrl);
    final baseUri = apiUri.replace(path: '', query: '', fragment: '');
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    return baseUri.resolve(normalizedPath).toString();
  }
}
