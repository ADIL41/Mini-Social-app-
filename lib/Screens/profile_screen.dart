import 'dart:convert';
import 'dart:typed_data';

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

  final userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> pickImage() async {
    final picture = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picture != null) {
      setState(() {
        image = picture;
      });
    }
  }

  Future<void> uploadImage() async {
    if (image == null) return;

    final bytes = await image!.readAsBytes();
    final base64String = base64Encode(bytes);

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'profileImageBase64': base64String,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 194, 54, 108),
        title: const Text('User Profile'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text('No profile data found'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          Uint8List? imageBytes;
          if (userData['profileImageBase64'] != null) {
            imageBytes = base64Decode(userData['profileImageBase64']);
          }

          return Column(
            children: [
              const SizedBox(height: 30),

              /// ✅ Profile Image
              Align(
                alignment: Alignment.center,
                child: imageBytes == null
                    ? CircleAvatar(
                        radius: 90,
                        child: InkWell(
                          onTap: pickImage,
                          child: const Icon(Icons.camera_alt_rounded, size: 40),
                        ),
                      )
                    : ClipOval(
                        child: Image.memory(
                          imageBytes,
                          height: 180,
                          width: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              //Name
              Text(
                userData['name'] ?? 'No Name',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // Email
              Text(
                userData['email'] ?? 'No Email',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 6),

              ///  Phone
              Text(
                userData['phone'] ?? 'No Phone',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 30),

              /// Upload Button
              ElevatedButton(
                onPressed: uploadImage,
                child: const Text('Upload Image'),
              ),
            ],
          );
        },
      ),
    );
  }
}
