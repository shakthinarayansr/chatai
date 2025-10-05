import 'dart:async';

import 'package:chatai/models/each_poll_job.dart';
import 'package:chatai/providers/check_job_status.dart';
import 'package:flutter/foundation.dart';

import '../models/job_update.dart';

class PollingService {
  final Map<String, Timer> _activePollers = {};
  final void Function(JobUpdate)? onJobUpdate;

  Key key;

  PollingService({required this.key, this.onJobUpdate});

  void startPolling(EachPollJob job) {
    //Parallel processing
    final jobId = job.id.toString();

    if (_activePollers.containsKey(jobId)) return;

    _activePollers[jobId] = Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        print('Polling $jobId');

        JobUpdate jobUpdate = await checkJobStatus(job);
        if (jobUpdate.status == JobStatus.completed ||
            jobUpdate.status == JobStatus.failed) {
          timer.cancel();
          _activePollers.remove(jobId);
        }
        if (onJobUpdate != null) {
          onJobUpdate!(jobUpdate);
        }
      } catch (e) {
        if (onJobUpdate != null) {
          onJobUpdate!(
            JobUpdate(jobId: job, success: false, status: JobStatus.failed),
          );
        }
      }
    });
  }

  Future<JobUpdate> pollSingleJob(
    EachPollJob job, {
    Duration interval = const Duration(seconds: 2),
  }) async {
    //Sequential processing
    bool done = false;
    while (!done) {
      JobUpdate jobUpdate = await checkJobStatus(job);
      if (jobUpdate.status == JobStatus.completed ||
          jobUpdate.status == JobStatus.failed) {
        done = true;
        return jobUpdate;
      } else {
        await Future.delayed(interval);
      }
    }
    return JobUpdate(jobId: job, success: false, status: JobStatus.failed);
  }

  void stopAllPolling() {
    for (var timer in _activePollers.values) {
      timer.cancel();
    }
    _activePollers.clear();
  }
}
