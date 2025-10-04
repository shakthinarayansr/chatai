class JobUpdate {
  final String jobId;
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
