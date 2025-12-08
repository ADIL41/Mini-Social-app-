import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  XFile? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 194, 54, 108),
        title: Text('User Profile'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 40),
          Align(
            alignment: Alignment.center,
            child: image == null
                ? CircleAvatar(
                    radius: 100,
                    child: InkWell(
                      onTap: () async {
                        final picture = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );

                        image = picture;
                        setState(() {});
                      },
                      child: Icon(Icons.camera_alt_rounded, size: 50),
                    ),
                  )
                : ClipOval(
                    child: Image.file(
                      File(image!.path),
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          SizedBox(height: 20),

          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () async {
              if (image == null) {
                return;
              }
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) {
                // ignore: avoid_print
                print('no user loged in');
                return;
              }
              final userId = currentUser.uid;

              // Convert image to bytes then to base64 string
              final bytes = await image!.readAsBytes();
              final base64String = base64Encode(bytes);

              // Save to Firestore - use your user document ID
              final userRef = FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId); // Replace with your user ID

              await userRef.set({
                'profileImageBase64':
                    base64String, // Store image as base64 string
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            },
            child: Text('Upload image'),
          ),
        ],
      ),
    );
  }
}
