import 'package:chatai/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../common_functions.dart';

class FetchCommentsProvider {
  Future<Map> fetchComments() async {
    final dio = Dio();
    const url = Constants.commentsEndPoint;

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200 || response.statusCode == 304) {
        return response.data;
      } else {
        toastification.show(
          title: Text("Try again later!"),
          autoCloseDuration: const Duration(seconds: 5),
          primaryColor: Colors.redAccent,
        );
        return {};
      }
    } on DioException catch (e) {
      toastification.show(
        title: Text(CommonFunctions.handleDioError(e)["message"].toString()),
        autoCloseDuration: const Duration(seconds: 5),
        primaryColor: Colors.redAccent,
      );
      return {};
    }
  }
}
