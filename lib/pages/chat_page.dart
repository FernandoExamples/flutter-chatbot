import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:chat_bot_1/models/message.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final DialogFlowtter dialogFlowtter;
  final messageController = TextEditingController();
  final List<MessageModel> messages = [];

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    dialogFlowtter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Box')),
      body: Column(
        children: [
          Expanded(
            child: MessagesList(
              messages: messages,
            ),
          ),
          Divider(height: 3.0),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: MessageInput(
              controller: messageController,
              onSendMessage: (message) {
                if (message != null && message.isNotEmpty) {
                  setState(() {
                    messages.insert(0, MessageModel(type: MessageModel.USER, message: messageController.text));
                  });
                  response(messageController.text);
                  messageController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void response(String query) async {
    setState(() => messages.insert(0, MessageModel(type: MessageModel.BOT, message: '...')));
    try {
      final queryInput = QueryInput(text: TextInput(text: query));
      final response = await dialogFlowtter.detectIntent(queryInput: queryInput);
      setState(() => messages.removeAt(0));

      final messageList = response.queryResult?.fulfillmentMessages;
      if (messageList != null && messageList.isNotEmpty) {
        for (var element in messageList) {
          var message = element.text!.text!.first;
          message = message.isNotEmpty ? message : 'No tengo respuesta para eso';
          messages.insert(0, MessageModel(type: MessageModel.BOT, message: message));
        }
      }
      if (response.queryResult?.action == "agendar" && response.queryResult?.allRequiredParamsPresent == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cita agendada')));
      }
    } catch (e) {
      setState(() => messages.removeAt(0));
      messages.insert(0, MessageModel(type: MessageModel.BOT, message: 'Aún no sé responder a eso. Intentalo después'));
    }
    setState(() {});
  }

  initialize() async {
    dialogFlowtter = await DialogFlowtter.fromFile(path: 'assets/fluttervarios-330314-bf78a243fc2c.json');
  }
}

class MessageInput extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String? message)? onSendMessage;

  MessageInput({this.controller, this.onSendMessage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration.collapsed(
              hintText: 'Send a message...',
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          child: IconButton(
            icon: Icon(Icons.send),
            onPressed: () => onSendMessage?.call(controller?.text),
          ),
        )
      ],
    );
  }
}

class MessagesList extends StatelessWidget {
  final List<MessageModel> messages;

  MessagesList({
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: messages.length,
      padding: EdgeInsets.all(8.0),
      reverse: true,
      itemBuilder: (BuildContext context, int index) {
        final message = messages[index];
        return MessageWidget(message: message);
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 8);
      },
    );
  }
}

class MessageWidget extends StatelessWidget {
  final MessageModel message;

  MessageWidget({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[CircleAvatar(backgroundImage: AssetImage('assets/bot.png')), SizedBox(width: 5)],
        Container(
          padding: EdgeInsets.all(8),
          constraints: BoxConstraints(maxWidth: screen.width * 0.5),
          decoration: BoxDecoration(
            color: Colors.lightBlue[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            message.message,
            textAlign: isUser ? TextAlign.right : TextAlign.left,
          ),
        ),
        if (isUser) ...[SizedBox(width: 5), CircleAvatar(backgroundImage: AssetImage('assets/user.png'))],
      ],
    );
  }

  bool get isUser => message.type == MessageModel.USER;
}
