import 'package:cached_network_image/cached_network_image.dart';
import 'package:fire_chat/model/user_model.dart';
import 'package:fire_chat/screen/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardChatUserWidget extends StatefulWidget {
  const CardChatUserWidget({super.key, required this.userModel});

  final UserModel userModel;

  @override
  State<CardChatUserWidget> createState() => _CardChatUserWidgetState();
}

class _CardChatUserWidgetState extends State<CardChatUserWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(userModel: widget.userModel)));
        },
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0.44,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: widget.userModel.image.toString(),
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(
                        CupertinoIcons.profile_circled,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.userModel.name ?? "Unknown",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.userModel.about ?? "Unknown",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              CircleAvatar(radius: 7,backgroundColor: Colors.greenAccent.shade400,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
