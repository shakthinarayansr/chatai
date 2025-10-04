import 'message.dart';

class Choice {
  String? finishReason;
  int? index;
  dynamic logprobs;
  Message? message;

  Choice({this.finishReason, this.index, this.logprobs, this.message});

  @override
  String toString() {
    return 'Choice(finishReason: $finishReason, index: $index, logprobs: $logprobs, message: $message)';
  }

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
    finishReason: json['finish_reason'] as String?,
    index: json['index'] as int?,
    logprobs: json['logprobs'] as dynamic,
    message: json['message'] == null
        ? null
        : Message.fromJson(json['message'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'finish_reason': finishReason,
    'index': index,
    'logprobs': logprobs,
    'message': message?.toJson(),
  };

  Choice copyWith({
    String? finishReason,
    int? index,
    dynamic logprobs,
    Message? message,
  }) {
    return Choice(
      finishReason: finishReason ?? this.finishReason,
      index: index ?? this.index,
      logprobs: logprobs ?? this.logprobs,
      message: message ?? this.message,
    );
  }
}
