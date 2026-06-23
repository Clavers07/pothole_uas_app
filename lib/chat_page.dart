import 'package:flutter/material.dart';
import 'api_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _messages = [];

  bool _isTyping = false;

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String userMsg = _controller.text.trim();

    setState(() {
      _messages.add({
        "text": userMsg,
        "isUser": true,
      });

      _isTyping = true;
    });

    _controller.clear();

    String botRes = await ApiService().askChatbot(userMsg);

    setState(() {
      _messages.add({
        "text": botRes,
        "isUser": false,
      });

      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Asisten Jalan Berlubang",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),

      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade200,
            child: const Text(
              "Tanyakan informasi seputar jalan berlubang, tingkat kerusakan jalan, dan pelaporan kerusakan jalan.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {

                final msg = _messages[index];

                return Align(
                  alignment: msg['isUser']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: msg['isUser']
                          ? Colors.orange.shade100
                          : Colors.grey.shade200,

                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Text(
                      msg['text'],
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isTyping)
            const LinearProgressIndicator(
              color: Colors.orange,
            ),

          Padding(
            padding: const EdgeInsets.all(8),

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _controller,

                    decoration: InputDecoration(
                      hintText:
                          "Tanyakan tentang jalan berlubang...",

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(25),
                      ),

                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                FloatingActionButton(
                  mini: true,

                  backgroundColor: Colors.grey,

                  onPressed: _sendMessage,

                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}