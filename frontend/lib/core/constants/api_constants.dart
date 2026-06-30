class ApiConstants {
  const ApiConstants._();

  // Android emulator: http://10.0.2.2:8000/api
  // Gercek telefon: bilgisayarinizin yerel IP adresini kullanin.
  // Ornek: http://192.168.1.X:8000/api
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static const String register = '/register';
  static const String login = '/login';
  static const String user = '/user';
  static const String logout = '/logout';
  static const String posts = '/posts';

  static String postById(int id) => '/posts/$id';
  static String postComments(int postId) => '/posts/$postId/comments';
  static String commentById(int id) => '/comments/$id';
  static String postLikes(int postId) => '/posts/$postId/likes';
}
