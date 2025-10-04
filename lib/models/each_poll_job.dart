class EachPollJob {
  int? id;
  String? name;

  EachPollJob({this.id, this.name});

  @override
  String toString() => 'EachPollJob(id: $id, name: $name)';

  factory EachPollJob.fromJson(Map<String, dynamic> json) =>
      EachPollJob(id: json['id'] as int?, name: json['name'] as String?);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  EachPollJob copyWith({int? id, String? name}) {
    return EachPollJob(id: id ?? this.id, name: name ?? this.name);
  }
}
