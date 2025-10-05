import 'package:chatai/common_functions.dart';
import 'package:chatai/constants.dart';
import 'package:chatai/models/each_poll_job.dart';
import 'package:dio/dio.dart';
import '../models/job_update.dart';

Future<JobUpdate> checkJobStatus(EachPollJob job) async {
  final Dio dio = Dio();

  final url = '${Constants.jobEndPoint}job/${job.id}';

  Response response;

  try {
    response = await dio.get(url);
  } on DioException catch (e) {
    return JobUpdate(
      jobId: job,
      status: JobStatus.failed,
      data: CommonFunctions.handleDioError(e),
      success: false,
    );
  }
  if (response.statusCode == 200) {
    List data = response.data;
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
