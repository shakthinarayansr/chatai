import 'dart:async';

import 'package:chatai/common_functions.dart';
import 'package:chatai/models/chat_model.dart';
import 'package:chatai/models/job_update.dart';
import 'package:chatai/providers/get_process_provider.dart';
import 'package:chatai/providers/image_upload_provider.dart';
import 'package:chatai/providers/samba_ai_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';
import '../../models/each_poll_job.dart';
import '../../providers/polling_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final _collection = FirebaseFirestore.instance.collection('messages');
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  ChatBloc() : super(ChatInitial()) {
    on<LoadMessages>(_loadMessage);
    on<SendMessage>(_sendMessage);
    on<UploadImages>(_uploadImages);
    on<DeleteAllMessages>(_onDeleteAllMessages);
  }
  Future<void> _onDeleteAllMessages(
    DeleteAllMessages event,
    Emitter<void> emit,
  ) async {
    try {
      emit(DisplayLoadingWithText("Clearing chat"));

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Query all message documents
      final querySnapshot = await firestore.collection('messages').get();

      // Batch delete for efficiency and atomicity
      final batch = firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      emit(ChatCleared());
    } catch (e) {
      toastification.show(
        title: Text('Error deleting messages: $e'),
        autoCloseDuration: const Duration(seconds: 5),
        primaryColor: Colors.redAccent,
      );
      emit(ChatClearError());

      // Handle error or emit failure state if using states
    }
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
      toastification.show(
        title: Text(message),
        autoCloseDuration: const Duration(seconds: 5),
        primaryColor: Colors.redAccent,
      );
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

        if (emit.isDone) break;

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
    emit(MessageSent());

    if (event.role == 'assistant') return;
    emit(DisplayLoadingWithText("Processing your response"));

    Map processResponse = await ProcessProviders().callGetProcessApi(
      event.type.name,
    );

    if (processResponse.containsKey("dioErrorType")) {
      toastification.show(
        title: Text(processResponse["message"]),
        autoCloseDuration: const Duration(seconds: 5),
        primaryColor: Colors.redAccent,
      );
      emit(ProcessCompleted());
      return;
    }

    // based on result start the queue

    List<EachPollJob> jobs = [];
    if (processResponse.containsKey('pollIds')) {
      processResponse["pollIds"].forEach((job) {
        jobs.add(EachPollJob.fromJson(job));
      });
    }

    PollingService pollingService = PollingService(key: Key("1"));

    for (var job in jobs) {
      emit(ChatLoading());
      emit(DisplayLoadingWithText(job.name ?? ""));
      JobUpdate jobUpdate = await pollingService.pollSingleJob(job);
      if (jobUpdate.status == JobStatus.failed) {
        toastification.show(
          title: Text("${job.name ?? ""}failed"),
          autoCloseDuration: const Duration(seconds: 5),
          primaryColor: Colors.redAccent,
        );
        emit(ProcessCompleted());
        break;
      }
    }
    List<Map<String, dynamic>> message = [];
    List<Map<String, dynamic>> oldMessages = [];
    if (event.messages.isNotEmpty) {
      int i = 0;
      for (var eachMessage in event.messages.reversed) {
        oldMessages.add({
          "role": eachMessage.role,
          "content": [
            {
              "type": CommonFunctions.getAiType(eachMessage.type),
              CommonFunctions.getAiType(eachMessage.type): eachMessage.text,
            },
          ],
        });

        if (i >= 10) {
          break;
        } else {
          i++;
        }
      }
    }
    if (event.type == ChatType.imageGeneration) {
      String image64 =
          await ImageUploadProvider().imageUrlToBase64(event.text) ?? "";

      if (oldMessages.isEmpty) {
        oldMessages.add({
          "role": "user",
          "content": [
            {"type": "text", "text": "What do you see in this image"},
          ],
        });
      }

      message = [
        ...oldMessages.reversed,
        {
          "role": "user",
          "content": [
            {
              "type": "image_url",
              "image_url": {"url": "data:image/jpeg;base64,$image64"},
            },
          ],
        },
      ];
    } else if (event.type == ChatType.text) {
      message = [
        ...oldMessages.reversed,
        {
          "role": "user",
          "content": [
            {"type": "text", "text": event.text},
          ],
        },
      ];
    }
    String reply = '';
    if (message.isNotEmpty) {
      reply = await SambaCloudService().sendChatMessage(messages: message);
    } else {
      reply = "Your file is received";
    }

    emit(AiReplyReceived(reply));
    emit(ProcessCompleted());
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
