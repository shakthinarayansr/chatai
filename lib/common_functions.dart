import 'package:dio/dio.dart';

class CommonFunctions {
  static Map<String, dynamic> handleDioError(DioException e) {
    String message;

    switch (e.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with API server";
        break;
      case DioExceptionType.unknown:
        message = "Connection to API server failed due to internet connection";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with API server";
        break;
      // case DioErrorType.RESPONSE:
      //   message = _handleError(
      //       dioError.response.statusCode, dioError.response.data);
      //   break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      case DioExceptionType.badResponse:
        // message = "Bad response from API server";

        message = "Something went wrong. Try again later!";

        break;
      default:
        message = "Something went wrong. Try again later!";
        break;
    }
    Map<String, dynamic> errorMap = {
      "error": true,
      "message":
          (e.response != null &&
              e.response!.data != null &&
              e.response!.data.runtimeType != List &&
              e.response!.data.runtimeType != String)
          ? (getMessage(e.response!.data) ?? message)
          : (e.response != null &&
                e.response!.data != null &&
                e.response!.data.runtimeType == String)
          ? e.response!.data
          : message,
      "dioErrorType": e.response != null
          ? e.response?.statusCode.toString()
          : "",
    };

    return errorMap;
  }

  static String? getMessage(Map data) {
    if (data.containsKey("message")) {
      return data["message"];
    } else if (data.containsKey("msg")) {
      return data["msg"];
    } else if (data.containsKey("Msg")) {
      return data["Msg"];
    } else if (data.containsKey("MSG")) {
      return data["MSG"];
    } else if (data.containsKey("MESSAGE")) {
      return data["MESSAGE"];
    } else if (data.containsKey("Message")) {
      return data["Message"];
    } else if (data.containsKey("reason")) {
      return data["reason"];
    } else if (data.containsKey("Reason")) {
      return data["Reason"];
    } else {
      return null;
    }
  }
}
