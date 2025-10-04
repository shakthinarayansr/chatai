import 'dart:async';

import 'package:chatai/providers/check_job_status.dart';

import '../models/job_update.dart';

class PollingService {
  final Map<String, Timer> _activePollers = {};
  final void Function(JobUpdate) onJobUpdate;

  PollingService({required this.onJobUpdate});

  void startPolling(String id) {
    final jobId = id; // capture jobId locally per iteration

    if (_activePollers.containsKey(jobId)) return;

    _activePollers[jobId] = Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        print('Polling $jobId');

        JobUpdate jobUpdate = await checkJobStatus(jobId);
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

  void stopAllPolling() {
    for (var timer in _activePollers.values) {
      timer.cancel();
    }
    _activePollers.clear();
  }
}
