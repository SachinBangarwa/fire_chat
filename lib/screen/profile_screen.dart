import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fire_chat/auth/login_screen.dart';
import 'package:fire_chat/core/api.dart';
import 'package:fire_chat/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userModel});

  final UserModel userModel;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController aboutController;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userModel.name);
    aboutController = TextEditingController(text: widget.userModel.about);
  }

  String? path;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        return FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: (){Navigator.pop(context);},icon: Icon(CupertinoIcons.back,),),
          elevation: 5,
          title: Text('Profile Screen'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.02),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    path!=null? ClipRRect(
                      borderRadius: BorderRadius.circular(75),
                      child: Image.file(
                        File(path!),
                        height: 130,
                        width: 130,
                        fit: BoxFit.cover,
                      ),
                    ):
                    ClipRRect(
                      borderRadius: BorderRadius.circular(75),
                      child: CachedNetworkImage(
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                        imageUrl: widget.userModel.image.toString(),
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(
                          CupertinoIcons.profile_circled,
                          color: Colors.blue,
                          size: 150,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 18,
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: () {
                            _showModalBottomSheet(context);
                          },
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  widget.userModel.name.toString(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.userModel.email.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    onSaved: (value) {
                      if (Apis.userModel != null) {
                        Apis.userModel!.name = value ?? '';
                      }
                    },
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Required field',
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    onSaved: (value) {
                      if (Apis.userModel != null) {
                        Apis.userModel!.about = value ?? '';
                      }
                    },
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Required field',
                    controller: aboutController,
                    decoration: InputDecoration(
                      labelText: 'About',
                      prefixIcon: Icon(Icons.info_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      await Apis.updateUserInfo();
                      FocusScope.of(context).unfocus();
                    }
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  label: Text(
                    ' Update ',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 13),
          child: SizedBox(
            height: 45,
            child: FloatingActionButton.extended(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: () async {
                GoogleSignIn googleSignIn = GoogleSignIn();
                await FirebaseAuth.instance.signOut().then((onValue) async{
                await  googleSignIn.signOut().then((onValue) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => LoginScreen()));
                  });
                });
              },
              backgroundColor: Colors.redAccent,
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              label: Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showModalBottomSheet(BuildContext context) async {
    Size size = MediaQuery.of(context).size;
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding:
              EdgeInsets.symmetric(vertical: size.width * .04, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pick Profile Picture',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      fixedSize: Size(size.width * .3, size.height * .14),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (image != null) {
                        path=image.path;
                        setState(() {});
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/image/add_image.png'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      fixedSize: Size(size.width * .3, size.height * .14),
                    ),
                    onPressed: () async{
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);

                      if (image != null) {
                        path=image.path;
                        setState(() {});
                        Navigator.pop(context);

                      }
                    },
                    child: Image.asset(
                      'assets/image/camera.png',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
