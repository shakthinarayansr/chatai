import 'package:dio/dio.dart';

import '../models/job_update.dart';

// class JobStatusProvider {
Future<JobUpdate> checkJobStatus(String jobId) async {
  final Dio dio = Dio();

  // final url = 'https://chatai.free.beeceptor.com/job/$jobId';
  final url =
      'https://b91b1769-22fa-4230-b610-b2cc51351e9b.mock.pstmn.io/job/$jobId';
  final response = await dio.get(url);
  print(url);
  print(response.data);

  if (response.statusCode == 200) {
    List data = response.data;
    // Sample parsing logic based on data structure
    final status = data.first;
    JobStatus jobStatus = JobStatus.running;
    if (status == 1) {
      print("completed");
      jobStatus = JobStatus.completed;
    } else if (status == 0) {
      jobStatus = JobStatus.failed;
    }

    return JobUpdate(
      jobId: jobId,
      status: jobStatus,
      data: data,
      success: true,
    );
  } else {
    return JobUpdate(
      jobId: jobId,
      status: JobStatus.failed,
      data: null,
      success: false,
    );
  }
}

// }
