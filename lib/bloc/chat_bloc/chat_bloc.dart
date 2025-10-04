import 'dart:async';

import 'package:chatai/models/chat_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final _collection = FirebaseFirestore.instance.collection('messages');
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  ChatBloc() : super(ChatInitial()) {
    on<LoadMessages>((event, emit) async {
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
    });

    on<SendMessage>((event, emit) async {
      try {
        await _collection.add({
          'text': event.text,
          'role': event.role,
          'timestamp': DateTime.now(),
        });
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
