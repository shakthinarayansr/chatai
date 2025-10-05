import 'dart:io';

import 'package:chatai/bloc/chat_bloc/chat_bloc.dart';
import 'package:chatai/bloc/chat_bloc/chat_event.dart';
import 'package:chatai/models/chat_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/chat_bloc/chat_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  final ScrollController _scrollController = ScrollController();
  void _sendMessage(BuildContext context, ChatType type, String message) {
    String text = message.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(SendMessage(text, 'user', type));
    // context.read<ChatBloc>().add(SendMessage("Assistant reply.", 'assistant'));
  }

  void _sendImageMessage(BuildContext context, List<String> message) {
    if (message.isEmpty) return;

    for (var imgUrl in message) {
      context.read<ChatBloc>().add(
        SendMessage(imgUrl, 'user', ChatType.imageGeneration),
      );
    }
    // context.read<ChatBloc>().add(SendMessage("Assistant reply.", 'assistant'));
  }

  Future<List<File>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      return result.files.map((file) => File(file.path!)).toList();
    }
    return [];
  }

  Future<List<XFile>> pickImages() async {
    final ImagePicker picker = ImagePicker();
    List<XFile>? images = await picker.pickMultiImage();

    return images;
  }

  Widget getUi(ChatState state, BuildContext buildContext) {
    if (state is ChatLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is DisplayLoadingWithText) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            SizedBox(width: 20),
            CircularProgressIndicator(),
          ],
        ),
      );
    } else if (state is ChatError) {
      return Center(child: Text('Error: ${state.error}'));
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              controller: _scrollController,

              itemCount: messages.length,
              itemBuilder: (context, idx) {
                ChatMessage m = messages[idx];
                switch (m.type) {
                  case ChatType.text:
                    return BubbleSpecialOne(
                      text: m.text,
                      isSender: m.role == 'user',
                      color: m.role == 'user'
                          ? Colors.blueAccent
                          : Colors.grey.shade200,
                      textStyle: TextStyle(
                        color: m.role == 'user' ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                      tail: true,
                    );
                  case ChatType.imageGeneration:
                    return BubbleNormalImage(
                      isSender: m.role == 'user',
                      color: m.role == 'user'
                          ? Colors.blueAccent
                          : Colors.grey.shade200,
                      tail: true,
                      id: '',
                      image: Image.network(m.text),
                    );
                  case ChatType.dataProcessing:
                    return GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse(m.text));
                      },
                      child: BubbleSpecialOne(
                        text: 'File',
                        isSender: m.role == 'user',
                        color: m.role == 'user'
                            ? Colors.blueAccent
                            : Colors.grey.shade200,
                        textStyle: TextStyle(
                          color: m.role == 'user'
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 16,
                        ),
                        tail: true,
                      ),
                    );
                }
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: MessageBar(
                onSend: (text) =>
                    _sendMessage(buildContext, ChatType.text, text),
                actions: [
                  InkWell(
                    child: Icon(Icons.add, color: Colors.black, size: 24),
                    onTap: () async {
                      List<File> files = await pickFiles();
                      if (buildContext.mounted && files.isNotEmpty) {
                        _sendMessage(
                          buildContext,
                          ChatType.dataProcessing,
                          "File",
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    child: InkWell(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.green,
                        size: 24,
                      ),
                      onTap: () async {
                        List<XFile> images = await pickImages();
                        if (images.isNotEmpty && buildContext.mounted) {
                          buildContext.read<ChatBloc>().add(
                            UploadImages(images),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc()..add(LoadMessages()),
      child: Scaffold(
        appBar: AppBar(title: Text('Chat assistant')),
        body: BlocListener<ChatBloc, ChatState>(
          listener: (listenerContext, state) {
            if (state is ChatLoaded) {
              messages = state.messages;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            } else if (state is ImageUploadFailed) {
            } else if (state is ImageUploaded) {
              _sendImageMessage(listenerContext, state.urls);
            } else if (state is ProcessCompleted) {
            } else if (state is AiReplyReceived) {
              listenerContext.read<ChatBloc>().add(
                SendMessage(state.message, 'assistant', ChatType.text),
              );
            }
          },
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (buildContext, state) {
              return getUi(state, buildContext);
            },
          ),
        ),
      ),
    );
  }
}
