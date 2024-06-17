import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:projet_kosmos/pages/home_page.dart';
import 'package:projet_kosmos/services/flushbar_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _acceptTerms = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  bool _isStepOne = true;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  bool _isValidateEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  Future<void> _register() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Veuillez remplir tous les champs.', Colors.red);
      return;
    }

    if (!_isValidateEmail(_emailController.text.trim())) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Veuillez entrer une adresse email valide.', Colors.red);
      return;
    }

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Les mots de passe ne correspondent pas.', Colors.red);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'CGVU et politique de confidentialité',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: const Scrollbar(
                        thumbVisibility: true,
                        radius: Radius.circular(10),
                        child: SingleChildScrollView(
                          child: Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam facilisis ex ex, nec pretium ante mollis id. Nullam lorem magna, malesuada sit amet nisi ut, congue lobortis turpis. Nulla pellentesque libero vitae mollis facilisis. Nulla auctor diam posuere aliquam scelerisque. Curabitur id sodales diam. Aliquam ut bibendum mi. Proin id ipsum sed nisl commodo dapibus. Aliquam eleifend mollis ipsum, vel rhoncus mauris. In a neque a urna vulputate elementum non sed quam. Ut in faucibus ante.'
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam facilisis ex ex, nec pretium ante mollis id. Nullam lorem magna, malesuada sit amet nisi ut, congue lobortis turpis. Nulla pellentesque libero vitae mollis facilisis. Nulla auctor diam posuere aliquam scelerisque. Curabitur id sodales diam. Aliquam ut bibendum mi. Proin id ipsum sed nisl commodo dapibus. Aliquam eleifend mollis ipsum, vel rhoncus mauris. In a neque a urna vulputate elementum non sed quam. Ut in faucibus ante.'
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam facilisis ex ex, nec pretium ante mollis id. Nullam lorem magna, malesuada sit amet nisi ut, congue lobortis turpis. Nulla pellentesque libero vitae mollis facilisis. Nulla auctor diam posuere aliquam scelerisque. Curabitur id sodales diam. Aliquam ut bibendum mi. Proin id ipsum sed nisl commodo dapibus. Aliquam eleifend mollis ipsum, vel rhoncus mauris. In a neque a urna vulputate elementum non sed quam. Ut in faucibus ante.'
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam facilisis ex ex, nec pretium ante mollis id. Nullam lorem magna, malesuada sit amet nisi ut, congue lobortis turpis. Nulla pellentesque libero vitae mollis facilisis. Nulla auctor diam posuere aliquam scelerisque. Curabitur id sodales diam. Aliquam ut bibendum mi. Proin id ipsum sed nisl commodo dapibus. Aliquam eleifend mollis ipsum, vel rhoncus mauris. In a neque a urna vulputate elementum non sed quam. Ut in faucibus ante.',
                            style: TextStyle(color: Color(0x5A021943), fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value!;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            "J'accepte la politique de confidentialité et les conditions générales de ventes et d'utilisation.",
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _acceptTerms ? _proceedWithRegistration : null,
                      child: const Text('Continuer'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _proceedWithRegistration() async {
    Navigator.of(context).pop();

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await userCredential.user!.sendEmailVerification();
      _showVerificationDialog();
    } catch (e) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Erreur lors de la création du compte.', Colors.red);
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Vérifiez votre boîte mail'),
          content: Text('Un email de vérification vous a été envoyé à l\'adresse ${_emailController.text}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isStepOne = false;
                });
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? profileImageUrl;
      if (_profileImage != null) {
        final ref = FirebaseStorage.instance.ref().child('profile_images').child('${user.uid}.jpg');
        await ref.putFile(_profileImage!);
        profileImageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'profileImageUrl': profileImageUrl ?? 'https://via.placeholder.com/150',
      });

      // Navigate to the home page or other appropriate page
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: _isStepOne ? _buildStepOne() : _buildStepTwo(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepOne() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Créez un compte.',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Adresse email',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: 'john.doe@gmail.com',
          ),
        ),
        const SizedBox(height: 10),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Mot de passe',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: 'Mot de passe',
          ),
        ),
        const SizedBox(height: 10),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Confirmation mot de passe',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: 'Confirmation mot de passe',
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _register,
          child: const Text('Continuer'),
        ),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Créez votre profil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Nom*',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _lastNameController,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: 'Ex. Doe',
          ),
        ),
        const SizedBox(height: 10),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Prénom*',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _firstNameController,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: 'Ex. John',
          ),
        ),
        const SizedBox(height: 10),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Photo de profil*',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: 500,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,

              borderRadius: BorderRadius.circular(10),
            ),
            child: _profileImage != null
                ? ClipOval(
              child: Image.file(
                _profileImage!,
                fit: BoxFit.cover,
                width: 150,
                height: 150,
              ),
            )
                : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    color: Colors.black,
                    size: 50,
                  ),
                  Text(
                    'Appuyez pour choisir une photo',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _completeProfile,
          child: const Text('Terminer l\'inscription'),
        ),
      ],
    );
  }
}
