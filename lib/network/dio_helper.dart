import 'package:dio/dio.dart';

class DioHelper {
  static late Dio dio;
  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://10.0.2.56/compny_app/public/api/",
        headers: {'Content-Type': 'application/json'},
        receiveDataWhenStatusError: true,
      ),
    );
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    String? name,
    String? token,
  }) async {
    return await dio.get(url, queryParameters: query);
  }

  static Future<Response> postData(String url,
      {Map<String, dynamic>? data}) async {
    dynamic formData = FormData.fromMap(data!);
    final response = await dio.post(url, data: formData);

    return response;
  }
}
