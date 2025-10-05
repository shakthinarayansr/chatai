import 'package:chatai/models/each_poll_job.dart';

class JobUpdate {
  final EachPollJob jobId;
  final bool success;
  final dynamic data;
  final JobStatus status;

  JobUpdate({
    required this.jobId,
    required this.success,
    this.data,
    required this.status,
  });
}

enum JobStatus { running, completed, failed }
