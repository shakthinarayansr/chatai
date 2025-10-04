import 'package:chatai/common_functions.dart';
import 'package:chatai/constants.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadProvider {
  Future<(String?, String?)> uploadToImgBB(XFile imageFile) async {
    String url =
        'https://api.imgbb.com/1/upload?key=${Constants.imageBBApiKey}';

    try {
      String fileName = imageFile.path.split('/').last;

      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });
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
}
