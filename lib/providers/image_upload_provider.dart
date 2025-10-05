import 'dart:convert';

import 'package:chatai/common_functions.dart';
import 'package:chatai/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadProvider {
  Future<(String?, String?)> uploadToImgBB(XFile imageFile) async {
    String url =
        'https://api.imgbb.com/1/upload?key=${Constants.imageBBApiKey}';

    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData;
      if (kIsWeb) {
        Uint8List fileBytes = await imageFile.readAsBytes();
        formData = FormData.fromMap({
          "image": MultipartFile.fromBytes(fileBytes, filename: fileName),
        });
      } else {
        formData = FormData.fromMap({
          "image": await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
          ),
        });
      }
      var dio = Dio();
      var response = await dio.request(
        url,
        options: Options(method: 'POST'),
        data: formData,
      );

      if (response.statusCode == 200) {
        final jsonResp = response.data;
        return (jsonResp['data']['url']?.toString(), "");
      } else {
        return (null, "Try again later");
      }
    } on DioException catch (e) {
      Map error = CommonFunctions.handleDioError(e);
      return (null, error["message"].toString());
    }
  }

  Future<String?> imageUrlToBase64(String imageUrl) async {
    try {
      final dio = Dio();
      // Get image bytes from URL

      final response = await dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        final bytes = response.data!;
        // Convert bytes to base64 string
        final base64String = base64Encode(bytes);
        return base64String;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
