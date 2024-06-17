import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:projet_kosmos/services/flushbar_service.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  AddPostPageState createState() => AddPostPageState();
}

class AddPostPageState extends State<AddPostPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPreview = true;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_selectedImage == null || _descriptionController.text.trim().isEmpty) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Veuillez sélectionner une image et entrer une description.', Colors.red);
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        FlushbarService.instance.showFlushbar(context, 'Erreur', 'Veuillez vous connecter pour publier un post.', Colors.red);
        return;
      }

      final storageRef = FirebaseStorage.instance.ref().child('posts').child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': imageUrl,
        'description': _descriptionController.text.trim(),
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context, true);
      FlushbarService.instance.showFlushbar(context, 'Succès', 'Post publié avec succès', Colors.green);
    } catch (e) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Erreur lors de la publication du post', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Ajouter un post'),
      ),
      body: _selectedImage == null
          ? _buildImagePicker()
          : _isPreview
          ? _buildImagePreview()
          : _buildDescriptionInput(),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('Appuyez pour choisir une photo', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isPreview = false;
              });
            },
            child: const Text('Suivant'),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Décrivez votre post..',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0), // Ajoute du padding pour le texte
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _uploadPost,
            child: const Text('Publier'),
          ),
        ),
      ],
    );
  }
}
