import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:projet_kosmos/services/flushbar_service.dart';

class EmailModificationPage extends StatefulWidget {
  final String userId;

  const EmailModificationPage({super.key, required this.userId});

  @override
  _EmailModificationPageState createState() => _EmailModificationPageState();
}

class _EmailModificationPageState extends State<EmailModificationPage> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (userDoc.exists) {
      _emailController.text = userDoc.get('email') ?? '';
    }
  }

  Future<void> _updateEmail() async {
    final newEmail = _emailController.text.trim();
    if (newEmail.isEmpty) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Veuillez entrer une adresse email.', Colors.red);
      return;
    }

    try {
      // Update email in Firebase Auth
      final user = _auth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
        await user.sendEmailVerification();

        // Update email in Firestore
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'email': newEmail,
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmez votre adresse email'),
              content: Text('Vous venez de recevoir un email de vérification sur ${_obscureEmail(newEmail)}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Fermer'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Erreur lors de la mise à jour de l\'adresse email.', Colors.red);
    }
  }

  String _obscureEmail(String email) {
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];

    final obscuredName = name.replaceRange(2, name.length - 2, '*' * (name.length - 4));
    final obscuredDomain = domain.replaceRange(1, domain.indexOf('.'), '*' * (domain.indexOf('.') - 1));

    return '$obscuredName@$obscuredDomain';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adresse email'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Adresse email*',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateEmail,
              child: const Text('Modifier'),
            ),
            const SizedBox(height: 10),
            const Text(
              '*les champs sont obligatoires',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
