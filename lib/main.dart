import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const FriendlyChatApp(),
  );
}

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
);

final ThemeData kDefaultTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
      .copyWith(secondary: Colors.orangeAccent[400]),
);

String _name = 'Your Name';

class FriendlyChatApp extends StatelessWidget {
  const FriendlyChatApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Friendly Chat',
      theme: defaultTargetPlatform == TargetPlatform.android
          ? kDefaultTheme
          : kIOSTheme,
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final List<ChatMessage> _message = [];
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  Widget _buildTextCompoer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onChanged: (text) {
                  setState(
                    () {
                      _isComposing = text.isNotEmpty;
                    },
                  );
                },
                onSubmitted: _isComposing ? _handleSubmitted : null,
                decoration:
                    const InputDecoration.collapsed(hintText: 'Send message'),
                focusNode: _focusNode,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  onPressed: () => _isComposing
                      ? _handleSubmitted(_textController.text)
                      : null,
                  icon: const Icon(Icons.send)),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var message in _message) {
      message.animationController.dispose();
    }
    super.dispose();
  }

  void _handleSubmitted(String text) {
    _textController.clear;
    setState(() {
      _isComposing = false;
      _textController.clear;
    });
    var message = ChatMessage(
      text: text,
      animationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    setState(() {
      _message.insert(0, message);
      _textController.clear;
    });
    _focusNode.requestFocus();
    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friendly Chat'),
        elevation:
            Theme.of(context).platform == TargetPlatform.android ? 0.0 : 4.0,
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, index) => _message[index],
              itemCount: _message.length,
            ),
          ),
          const Divider(
            height: 1.0,
          ),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextCompoer(),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    Key? key,
    required this.text,
    required this.animationController,
  }) : super(key: key);

  final String text;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                child: Text(_name[0]),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_name, style: Theme.of(context).textTheme.headline4),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Text(text),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
