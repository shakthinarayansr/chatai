import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String text;
  final String role;
  final DateTime? timestamp;

  const ChatMessage({required this.text, required this.role, this.timestamp});

  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      text: data['text'] ?? '',
      role: data['role'] ?? '',
      timestamp:
          data['timestamp'] != null || data['timestamp'].toString().isNotEmpty
          ? DateTime.tryParse(data['timestamp'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'text': text,
    'role': role,
    'timestamp': timestamp?.toIso8601String(),
  };

  @override
  List<Object?> get props => [text, role, timestamp];
}
