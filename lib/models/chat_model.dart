import 'package:equatable/equatable.dart';

enum ChatType { text, imageGeneration, dataProcessing }

class ChatMessage extends Equatable {
  final String text;
  final String role;
  final DateTime? timestamp;
  final ChatType type;

  const ChatMessage({
    required this.text,
    required this.role,
    this.timestamp,
    required this.type,
  });

  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      text: data['text'] ?? '',
      role: data['role'] ?? '',
      timestamp:
          data['timestamp'] != null || data['timestamp'].toString().isNotEmpty
          ? DateTime.tryParse(data['timestamp'].toString())
          : null,
      type: getType(data['type'] ?? ''),
    );
  }
  static ChatType getType(String text) {
    switch (text) {
      case 'text':
        return ChatType.text;
      case 'imageGeneration':
        return ChatType.imageGeneration;
      case 'dataProcessing':
        return ChatType.dataProcessing;
      default:
        return ChatType.text;
    }
  }

  Map<String, dynamic> toMap() => {
    'text': text,
    'role': role,
    'timestamp': timestamp?.toIso8601String(),
    "type": type,
  };

  @override
  List<Object?> get props => [text, role, timestamp, type];
}
