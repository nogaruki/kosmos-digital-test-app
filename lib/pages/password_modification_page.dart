import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_kosmos/services/flushbar_service.dart';

class PasswordModificationPage extends StatefulWidget {
  final String userId;

  const PasswordModificationPage({Key? key, required this.userId}) : super(key: key);

  @override
  _PasswordModificationPageState createState() => _PasswordModificationPageState();
}

class _PasswordModificationPageState extends State<PasswordModificationPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmNewPasswordVisible = false;

  Future<void> _updatePassword() async {
    if (_newPasswordController.text.trim() != _confirmNewPasswordController.text.trim()) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Erreur lors de la mise à jour du mot de passe.', Colors.red);
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        AuthCredential credential = EmailAuthProvider.credential(email: email, password: _currentPasswordController.text.trim());

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text.trim());

        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'password': _newPasswordController.text.trim(), // Never store passwords like this.
        });
        // return an alert dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Vérifiez votre boîte mail'),
              content: const Text('Vos nouveaux identifiants vous ont été envoyés par email !'),
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
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Erreur lors de la mise à jour du mot de passe.', Colors.red);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mot de passe actuel*',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _currentPasswordController,
              obscureText: !_currentPasswordVisible,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _currentPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentPasswordVisible = !_currentPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nouveau mot de passe*',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _newPasswordController,
              obscureText: !_newPasswordVisible,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _newPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _newPasswordVisible = !_newPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Confirmez nouveau mot de passe*',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _confirmNewPasswordController,
              obscureText: !_confirmNewPasswordVisible,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmNewPasswordVisible = !_confirmNewPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF02132B),
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                textStyle: const TextStyle(color: Colors.white),
              ),
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
