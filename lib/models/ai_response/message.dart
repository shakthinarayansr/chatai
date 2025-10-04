class Message {
  String? content;
  String? role;

  Message({this.content, this.role});

  @override
  String toString() => 'Message(content: $content, role: $role)';

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    content: json['content'] as String?,
    role: json['role'] as String?,
  );

  Map<String, dynamic> toJson() => {'content': content, 'role': role};

  Message copyWith({String? content, String? role}) {
    return Message(content: content ?? this.content, role: role ?? this.role);
  }
}
