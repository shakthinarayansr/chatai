import 'package:chatai/bloc/chat_bloc/chat_bloc.dart';
import 'package:chatai/bloc/chat_bloc/chat_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

import '../bloc/chat_bloc/chat_state.dart';

class ChatScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  ChatScreen({super.key});
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(SendMessage(text, 'user'));
    // context.read<ChatBloc>().add(SendMessage("Assistant reply.", 'assistant'));
    _controller.clear();
  }

  Widget getUi(ChatState state) {
    if (state is ChatLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is ChatLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      return ListView.builder(
        padding: EdgeInsets.all(12),
        controller: _scrollController,

        itemCount: state.messages.length,
        itemBuilder: (context, idx) {
          final m = state.messages[idx];
          return BubbleSpecialOne(
            text: m.text,
            isSender: m.role == 'user',
            color: m.role == 'user' ? Colors.blueAccent : Colors.grey.shade200,
            textStyle: TextStyle(
              color: m.role == 'user' ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            tail: true,
            // margin: BubbleEdges.only(top: 8),
          );
        },
      );
    } else if (state is ChatError) {
      return Center(child: Text('Error: ${state.error}'));
    } else {
      return Center(child: Text('No messages.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc()..add(LoadMessages()),
      child: Scaffold(
        appBar: AppBar(title: Text('Chat assistant')),
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (buildContext, state) {
            return Column(
              children: [
                Expanded(child: getUi(state)),
                SafeArea(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(buildContext),
                          ),
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blueAccent,
                          child: IconButton(
                            icon: Icon(Icons.send, color: Colors.white),
                            onPressed: () => _sendMessage(buildContext),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
