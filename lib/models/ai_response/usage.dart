class Usage {
  int? completionTokens;
  double? completionTokensAfterFirstPerSec;
  double? completionTokensAfterFirstPerSecFirstTen;
  double? completionTokensAfterFirstPerSecGraph;
  double? completionTokensPerSec;
  double? endTime;
  bool? isLastResponse;
  int? promptTokens;
  String? stopReason;
  double? timeToFirstToken;
  double? totalLatency;
  int? totalTokens;
  double? totalTokensPerSec;

  Usage({
    this.completionTokens,
    this.completionTokensAfterFirstPerSec,
    this.completionTokensAfterFirstPerSecFirstTen,
    this.completionTokensAfterFirstPerSecGraph,
    this.completionTokensPerSec,
    this.endTime,
    this.isLastResponse,
    this.promptTokens,
    this.stopReason,
    this.timeToFirstToken,
    this.totalLatency,
    this.totalTokens,
    this.totalTokensPerSec,
  });

  @override
  String toString() {
    return 'Usage(completionTokens: $completionTokens, completionTokensAfterFirstPerSec: $completionTokensAfterFirstPerSec, completionTokensAfterFirstPerSecFirstTen: $completionTokensAfterFirstPerSecFirstTen, completionTokensAfterFirstPerSecGraph: $completionTokensAfterFirstPerSecGraph, completionTokensPerSec: $completionTokensPerSec, endTime: $endTime, isLastResponse: $isLastResponse, promptTokens: $promptTokens, stopReason: $stopReason, timeToFirstToken: $timeToFirstToken, totalLatency: $totalLatency, totalTokens: $totalTokens, totalTokensPerSec: $totalTokensPerSec)';
  }

  factory Usage.fromJson(Map<String, dynamic> json) => Usage(
    completionTokens: json['completion_tokens'] as int?,
    completionTokensAfterFirstPerSec:
        (json['completion_tokens_after_first_per_sec'] as num?)?.toDouble(),
    completionTokensAfterFirstPerSecFirstTen:
        (json['completion_tokens_after_first_per_sec_first_ten'] as num?)
            ?.toDouble(),
    completionTokensAfterFirstPerSecGraph:
        (json['completion_tokens_after_first_per_sec_graph'] as num?)
            ?.toDouble(),
    completionTokensPerSec: (json['completion_tokens_per_sec'] as num?)
        ?.toDouble(),
    endTime: (json['end_time'] as num?)?.toDouble(),
    isLastResponse: json['is_last_response'] as bool?,
    promptTokens: json['prompt_tokens'] as int?,
    stopReason: json['stop_reason'] as String?,
    timeToFirstToken: (json['time_to_first_token'] as num?)?.toDouble(),
    totalLatency: (json['total_latency'] as num?)?.toDouble(),
    totalTokens: json['total_tokens'] as int?,
    totalTokensPerSec: (json['total_tokens_per_sec'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'completion_tokens': completionTokens,
    'completion_tokens_after_first_per_sec': completionTokensAfterFirstPerSec,
    'completion_tokens_after_first_per_sec_first_ten':
        completionTokensAfterFirstPerSecFirstTen,
    'completion_tokens_after_first_per_sec_graph':
        completionTokensAfterFirstPerSecGraph,
    'completion_tokens_per_sec': completionTokensPerSec,
    'end_time': endTime,
    'is_last_response': isLastResponse,
    'prompt_tokens': promptTokens,
    'stop_reason': stopReason,
    'time_to_first_token': timeToFirstToken,
    'total_latency': totalLatency,
    'total_tokens': totalTokens,
    'total_tokens_per_sec': totalTokensPerSec,
  };

  Usage copyWith({
    int? completionTokens,
    double? completionTokensAfterFirstPerSec,
    double? completionTokensAfterFirstPerSecFirstTen,
    double? completionTokensAfterFirstPerSecGraph,
    double? completionTokensPerSec,
    double? endTime,
    bool? isLastResponse,
    int? promptTokens,
    String? stopReason,
    double? timeToFirstToken,
    double? totalLatency,
    int? totalTokens,
    double? totalTokensPerSec,
  }) {
    return Usage(
      completionTokens: completionTokens ?? this.completionTokens,
      completionTokensAfterFirstPerSec:
          completionTokensAfterFirstPerSec ??
          this.completionTokensAfterFirstPerSec,
      completionTokensAfterFirstPerSecFirstTen:
          completionTokensAfterFirstPerSecFirstTen ??
          this.completionTokensAfterFirstPerSecFirstTen,
      completionTokensAfterFirstPerSecGraph:
          completionTokensAfterFirstPerSecGraph ??
          this.completionTokensAfterFirstPerSecGraph,
      completionTokensPerSec:
          completionTokensPerSec ?? this.completionTokensPerSec,
      endTime: endTime ?? this.endTime,
      isLastResponse: isLastResponse ?? this.isLastResponse,
      promptTokens: promptTokens ?? this.promptTokens,
      stopReason: stopReason ?? this.stopReason,
      timeToFirstToken: timeToFirstToken ?? this.timeToFirstToken,
      totalLatency: totalLatency ?? this.totalLatency,
      totalTokens: totalTokens ?? this.totalTokens,
      totalTokensPerSec: totalTokensPerSec ?? this.totalTokensPerSec,
    );
  }
}
