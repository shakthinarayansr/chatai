import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String text;
  final String role;
  const SendMessage(this.text, this.role);

  @override
  List<Object?> get props => [text, role];
}
