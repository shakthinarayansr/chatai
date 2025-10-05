import 'dart:async';

import 'package:chatai/models/each_poll_job.dart';
import 'package:chatai/providers/check_job_status.dart';
import 'package:flutter/foundation.dart';

import '../models/job_update.dart';

class PollingService {
  final Map<String, Timer> _activePollers = {};
  final void Function(JobUpdate) onJobUpdate;

  Key key;

  PollingService({required this.key, required this.onJobUpdate});

  void startPolling(EachPollJob id) {
    final jobId = id.id.toString(); // capture jobId locally per iteration

    if (_activePollers.containsKey(jobId)) return;

    _activePollers[jobId] = Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        print('Polling $jobId');

        JobUpdate jobUpdate = await checkJobStatus(id);
        if (jobUpdate.status == JobStatus.completed ||
            jobUpdate.status == JobStatus.failed) {
          timer.cancel();
          _activePollers.remove(jobId);
        }
        onJobUpdate(jobUpdate);
      } catch (e) {
        // Optionally handle error or retry
      }
    });
  }

  Future<void> pollSingleJob(
    EachPollJob job, {
    Duration interval = const Duration(seconds: 2),
  }) async {
    bool done = false;
    while (!done) {
      final jobUpdate = await checkJobStatus(job);
      onJobUpdate(jobUpdate);
      if (jobUpdate.status == JobStatus.completed ||
          jobUpdate.status == JobStatus.failed) {
        done = true;
      } else {
        await Future.delayed(interval);
      }
    }
  }

  void stopAllPolling() {
    for (var timer in _activePollers.values) {
      timer.cancel();
    }
    _activePollers.clear();
  }
}
