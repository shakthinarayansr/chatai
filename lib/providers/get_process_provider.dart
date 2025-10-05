import 'package:dio/dio.dart';

class ProcessProviders {
  Future<Map<String, dynamic>> callGetProcessApi(String inputData) async {
    final dio = Dio();
    final url =
        'https://mp08e61c4d1feb9d244f.free.beeceptor.com/chat/$inputData';
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Image generation API failed: ${response.statusCode}');
    }
  }
}
