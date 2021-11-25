class MessageModel {
  static const BOT = 'bot';
  static const USER = 'user';

  final String type;
  final String message;

  MessageModel({required this.type, required this.message});
}
