import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_chat/model/chat_message_model.dart';
import 'package:fire_chat/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Apis {
  static const String collectionPath = 'users';

  static UserModel? userModel;

  static Future<bool> userExists() async {
    return (await FirebaseFirestore.instance
            .collection(collectionPath)
            .doc(user.uid)
            .get())
        .exists;
  }

  static Future createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final userModel = UserModel(
      id: user.uid,
      name: user.displayName,
      image: user.photoURL,
      email: user.email,
      about: 'Hey, I am using we Chat!',
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(
          user.uid,
        )
        .set(userModel.toFireStore());
  }


  static Future getSelfInfo() async {
    FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(user.uid)
        .get()
        .then((onValue) async {
      if (onValue.exists) {
        userModel = UserModel.fromFireStore(onValue);
      } else {
        await createUser().then((onValue) => getSelfInfo());
      }
    });
  }

  static String getConvertedId(String id) =>
      Apis.user.uid.hashCode <= id.hashCode
          ? '${Apis.user.uid}_$id'
          : '${id}_${Apis.user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      UserModel userModel) {
    return FirebaseFirestore.instance
        .collection(
            'chats/${getConvertedId(userModel.id.toString())}/messages/')
        .snapshots();
  }

  static Future sendMessage(UserModel userModel, String msg, Type type) async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();

      ChatMessage chatMessage = ChatMessage(
        toId: userModel.id.toString(),
        msg: msg,
        read: 'unread',
        type: type,
        fromId: Apis.user.uid,
        sent: time,
      );

      final docId = Apis.getConvertedId(userModel.id.toString());

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(docId)
          .collection('messages')
          .doc(time)
          .set(chatMessage.toMap());

      print("Message sent successfully");
    } catch (e) {
      print("Error  message: $e");
    }
  }

  static Stream<List<UserModel>> getAllUser() {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .where('id', isNotEqualTo: user.uid)
        .snapshots()
        .map((snapshots) {
      return snapshots.docs
          .map((doc) => UserModel.fromFireStore(doc))
          .toList();
    });
  }


  static final jsonData = {
    'name': userModel?.name ?? '',
    'about': userModel?.about ?? ''
  };

  static Future updateUserInfo() async {
    await FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(user.uid)
        .update(jsonData);
  }

  static User user = FirebaseAuth.instance.currentUser!;
}
