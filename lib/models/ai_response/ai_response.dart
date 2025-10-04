import 'choice.dart';
import 'usage.dart';

class AiResponse {
  List<Choice>? choices;
  double? created;
  String? id;
  String? model;
  String? object;
  String? systemFingerprint;
  Usage? usage;

  AiResponse({
    this.choices,
    this.created,
    this.id,
    this.model,
    this.object,
    this.systemFingerprint,
    this.usage,
  });

  @override
  String toString() {
    return 'AiResponse(choices: $choices, created: $created, id: $id, model: $model, object: $object, systemFingerprint: $systemFingerprint, usage: $usage)';
  }

  factory AiResponse.fromJson(Map<String, dynamic> json) => AiResponse(
    choices: (json['choices'] as List<dynamic>?)
        ?.map((e) => Choice.fromJson(e as Map<String, dynamic>))
        .toList(),
    created: (json['created'] as num?)?.toDouble(),
    id: json['id'] as String?,
    model: json['model'] as String?,
    object: json['object'] as String?,
    systemFingerprint: json['system_fingerprint'] as String?,
    usage: json['usage'] == null
        ? null
        : Usage.fromJson(json['usage'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'choices': choices?.map((e) => e.toJson()).toList(),
    'created': created,
    'id': id,
    'model': model,
    'object': object,
    'system_fingerprint': systemFingerprint,
    'usage': usage?.toJson(),
  };

  AiResponse copyWith({
    List<Choice>? choices,
    double? created,
    String? id,
    String? model,
    String? object,
    String? systemFingerprint,
    Usage? usage,
  }) {
    return AiResponse(
      choices: choices ?? this.choices,
      created: created ?? this.created,
      id: id ?? this.id,
      model: model ?? this.model,
      object: object ?? this.object,
      systemFingerprint: systemFingerprint ?? this.systemFingerprint,
      usage: usage ?? this.usage,
    );
  }
}
