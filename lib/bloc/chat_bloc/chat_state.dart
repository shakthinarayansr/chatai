import 'package:chatai/models/chat_model.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class MessageSent extends ChatState {}

class ProcessCompleted extends ChatState {}

class ChatCleared extends ChatState {}

class ChatClearError extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  const ChatLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ImageUploaded extends ChatState {
  final List<String> urls;
  const ImageUploaded(this.urls);

  @override
  List<Object?> get props => [urls];
}

class ImageUploadFailed extends ChatState {
  final String message;
  const ImageUploadFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class DisplayLoadingWithText extends ChatState {
  final String message;
  const DisplayLoadingWithText(this.message);

  @override
  List<Object?> get props => [message];
}

class AiReplyReceived extends ChatState {
  final String message;
  const AiReplyReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatError extends ChatState {
  final String error;
  const ChatError(this.error);

  @override
  List<Object?> get props => [error];
}
