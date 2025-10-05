import 'dart:convert';

import 'package:chatai/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class SambaCloudService {
  Future<String> sendChatMessage({
    required List<Map<String, dynamic>> messages,
  }) async {
    var headers = {
      'Authorization': 'Bearer ${Constants.sambaApiKey}',
      'Content-Type': 'application/json',
    };
    var data = json.encode({
      "stream": false,
      "model": "Llama-4-Maverick-17B-128E-Instruct",
      "messages": [
        {"role": "user", "content": messages},
      ],
    });
    var dio = Dio();
    var response = await dio.request(
      '${Constants.sambaEndPoint}/chat/completions',
      options: Options(method: 'POST', headers: headers),
      data: data,
    );

    if (response.statusCode == 200) {
      Map data = response.data;
      final content = data['choices'][0]['message']['content'] as String;
      return content;
    } else {
      toastification.show(
        title: Text("Try again later!"),
        autoCloseDuration: const Duration(seconds: 5),
        primaryColor: Colors.redAccent,
      );
      return "I was not able to parse that";
    }
  }
}
