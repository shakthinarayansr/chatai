import 'package:chatai/models/each_poll_job.dart';
import 'package:dio/dio.dart';
import '../models/job_update.dart';

// class JobStatusProvider {
Future<JobUpdate> checkJobStatus(EachPollJob job) async {
  final Dio dio = Dio();

  // final url = 'https://chatai.free.beeceptor.com/job/$jobId';

  final url =
      'https://b91b1769-22fa-4230-b610-b2cc51351e9b.mock.pstmn.io/job/${job.id}';
  final response = await dio.get(url);

  if (response.statusCode == 200) {
    List data = response.data;
    // Sample parsing logic based on data structure
    final status = data.first;
    JobStatus jobStatus = JobStatus.running;
    if (status == 1) {
      jobStatus = JobStatus.completed;
    } else if (status == 0) {
      jobStatus = JobStatus.failed;
    }

    return JobUpdate(jobId: job, status: jobStatus, data: data, success: true);
  } else {
    return JobUpdate(
      jobId: job,
      status: JobStatus.failed,
      data: null,
      success: false,
    );
  }
}

// }
