import 'package:chatai/common_functions.dart';
import 'package:chatai/constants.dart';
import 'package:dio/dio.dart';

class ProcessProviders {
  Future<Map<String, dynamic>> callGetProcessApi(String inputData) async {
    final dio = Dio();
    final url = '${Constants.endPoint}chat/$inputData';
    Response? response;
    try {
      response = await dio.get(url);
    } on DioException catch (e) {
      return CommonFunctions.handleDioError(e);
    }
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Image generation API failed: ${response.statusCode}');
    }
  }
}
