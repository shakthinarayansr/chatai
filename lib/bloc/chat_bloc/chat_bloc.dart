import 'dart:async';

import 'package:chatai/models/chat_model.dart';
import 'package:chatai/providers/image_upload_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final _collection = FirebaseFirestore.instance.collection('messages');
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  ChatBloc() : super(ChatInitial()) {
    on<LoadMessages>(_loadMessage);
    on<SendMessage>(_sendMessage);
    on<UploadImages>(_uploadImages);
  }

  Future<void> _uploadImages(UploadImages event, emit) async {
    emit(DisplayLoadingWithText("Uploading images..."));
    List<String> urls = [];
    String message = "";
    for (var element in event.images) {
      (String?, String?) res = await ImageUploadProvider().uploadToImgBB(
        element,
      );
      if (res.$1 != null && res.$1!.isNotEmpty) {
        urls.add(res.$1!);
      } else if (res.$2 != null && res.$2!.isNotEmpty) {
        message = res.$2 ?? "";
      }
    }
    if (urls.isNotEmpty) {
      emit(ImageUploaded(urls));
    } else {
      emit(ImageUploadFailed(message));
    }
  }

  Future<void> _loadMessage(LoadMessages event, emit) async {
    emit(ChatLoading());
    await _messagesSubscription?.cancel();
    try {
      await for (final snapshot
          in _collection.orderBy('timestamp').snapshots()) {
        final messages = snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc.data()))
            .toList();

        if (emit.isDone) break; // Avoid emit if handler finished

        emit(ChatLoaded(messages));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(ChatError(e.toString()));
      }
    }
  }

  Future<void> _sendMessage(SendMessage event, emit) async {
    try {
      await _collection.add({
        'text': event.text,
        'role': event.role,
        'timestamp': DateTime.now(),
        'type': event.type.name,
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
