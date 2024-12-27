import 'package:cached_network_image/cached_network_image.dart';
import 'package:fire_chat/core/api.dart';
import 'package:fire_chat/model/chat_message_model.dart';
import 'package:fire_chat/model/user_model.dart';
import 'package:fire_chat/screen/widget/message_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.userModel});

  final UserModel userModel;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> list = [];
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 221, 245, 255),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        elevation: 0.5,
        title: appBar(),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: Apis.getAllMessages(widget.userModel),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: SizedBox());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                } else if (snapshot.hasData && snapshot.data != null) {
                  list = snapshot.data!.docs
                          .map((e) => ChatMessage.fromMap(e.data()))
                          .toList() ??
                      [];

                  if (list.isNotEmpty) {
                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return MessageCardWidget(
                          chatMessage: list[index],
                        );
                      },
                    );
                  }
                }
                return Center(
                    child: Text(
                  'Say Hii! 👏',
                  style: TextStyle(fontSize: 20),
                ));
              },
            ),
          ),
          chatInput(),
        ],
      ),
    );
  }

  Widget chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Type Something...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                        size: 22,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.blueAccent,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 5),
          MaterialButton(
            minWidth: 0,
            padding: EdgeInsets.all(12),
            shape: CircleBorder(),
            color: Colors.green,
            onPressed: () async {
              if (messageController.text.isNotEmpty) {
                await Apis.sendMessage(
                    widget.userModel, messageController.text,Type.text);
                messageController.clear();
              }
            },
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget appBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
       BackButton(color: Colors.white,),
        CircleAvatar(
          radius: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: widget.userModel.image.toString(),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(
                CupertinoIcons.person_circle,
                color: Colors.black,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.userModel.name.toString(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Last seen not available',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
