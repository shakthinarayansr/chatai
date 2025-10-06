import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/chat_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String text;
  final String role;
  final ChatType type;
  const SendMessage(this.text, this.role, this.type);

  @override
  List<Object?> get props => [text, role, type];
}

class DeleteAllMessages extends ChatEvent {}

class UploadImages extends ChatEvent {
  final List<XFile> images;

  const UploadImages(this.images);

  @override
  List<Object?> get props => [images];
}
