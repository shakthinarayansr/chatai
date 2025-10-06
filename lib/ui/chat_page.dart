import 'dart:io';

import 'package:chatai/bloc/chat_bloc/chat_bloc.dart';
import 'package:chatai/bloc/chat_bloc/chat_event.dart';
import 'package:chatai/common_functions.dart';
import 'package:chatai/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
    context.read<ChatBloc>().add(SendMessage(text, 'user', type, messages));
  }

  void _sendImageMessage(BuildContext context, List<String> message) {
    if (message.isEmpty) return;

    for (var imgUrl in message) {
      context.read<ChatBloc>().add(
        SendMessage(imgUrl, 'user', ChatType.imageGeneration, messages),
      );
    }
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
            // CircularProgressIndicator(),
            LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.blue,
              size: 30,
            ),
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
                      List<File> files = await CommonFunctions().pickFiles();
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
                        List<XFile> images = await CommonFunctions()
                            .pickImages();
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

  Future<bool?> showClearChatConfirmation(BuildContext confirmationContext) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat?'),
        content: Text('Are you sure you want to clear all chat messages?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              confirmationContext.read<ChatBloc>().add(DeleteAllMessages());
              Navigator.of(context).pop(false);
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc()..add(LoadMessages()),
      child: BlocListener<ChatBloc, ChatState>(
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
          } else if (state is ImageUploaded) {
            _sendImageMessage(listenerContext, state.urls);
          } else if (state is AiReplyReceived) {
            listenerContext.read<ChatBloc>().add(
              SendMessage(state.message, 'assistant', ChatType.text, messages),
            );
          }
        },
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (buildContext, state) {
            return Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    Text('Chat assistant'),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        showClearChatConfirmation(buildContext);
                      },
                      child: Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              body: getUi(state, buildContext),
            );
          },
        ),
      ),
    );
  }
}
