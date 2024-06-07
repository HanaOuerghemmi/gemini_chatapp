import 'dart:convert';
import 'package:gemini_chatapp/respository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  ChatUser myself = ChatUser(id: "1", firstName: "Hana");
  ChatUser bot = ChatUser(id: "2", firstName: "Gemini");
  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 400,
        maxWidth: 400,
      );

      if (pickedFile != null) {
        sendMessageWithImage(pickedFile);
        print('Image selected: ${pickedFile.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void sendMessageWithImage(XFile imageFile) {
    final ChatMessage imageMessage = ChatMessage(
      text:'give me the name of the medicine from the picture',
      // 'write the text that wrote in the picture', // You can change the prompt text as needed
      user: myself,
      createdAt: DateTime.now(),
      medias: [
        ChatMedia(
          url: imageFile.path, // Provide the file path or URL of the image
          fileName: imageFile.name,
          type: MediaType.image,
        ),
      ],
    );

    setState(() {
      allMessages.add(imageMessage);
    });

    // Simulate sending image to bot
    getData(imageMessage);
  }

  Future<void> getData(ChatMessage m) async {
    typing.add(bot);
    setState(() {
      allMessages.insert(0, m);
    });

    var data = {"contents": [{"parts": [{"text": m.text}]}]};

    try {
      final response = await http.post(
        Uri.parse(ourUrl), // Ensure this URL is correct
        headers: header, // Ensure headers are correctly set
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result["candidates"][0]["content"]["parts"][0]["text"]);
        ChatMessage botMessage = ChatMessage(
          user: bot,
          createdAt: DateTime.now(),
          text: result["candidates"][0]["content"]["parts"][0]["text"],
        );
        setState(() {
          allMessages.insert(0, botMessage);
        });
      } else {
        print("Error occurred: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      typing.remove(bot);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatBot'),
      ),
      body: DashChat(
        currentUser: myself,
        inputOptions: InputOptions(
          trailing: [
            IconButton(
              icon: Icon(Icons.photo),
              onPressed: pickImage,
            ),
          ],
        ),
        onSend: (ChatMessage m) {
          typing.add(bot);
          getData(m);
          typing.remove(bot);

        },
        messages: allMessages,
        typingUsers: typing,
      ),
    );
  }
}
