import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/flushbar_service.dart';

class PersonalInfoPage extends StatefulWidget {
  final String userId;

  const PersonalInfoPage({Key? key, required this.userId}) : super(key: key);

  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (userDoc.exists) {
      _firstNameController.text = userDoc.get('firstName') ?? '';
      _lastNameController.text = userDoc.get('lastName') ?? '';
    }
  }

  Future<void> _updateUserInfo() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
      });
      Navigator.pop(context); // Fermer la page après la mise à jour
      FlushbarService.instance.showFlushbar(context, 'Succès', 'Informations mises à jour avec succès', Colors.green);
    } catch (e) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Erreur lors de la mise à jour des informations', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infos personnelles'),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              style: const TextStyle(color: Colors.black), // Couleur du texte noir
              decoration: const InputDecoration(
                hintText: 'John',
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nom*',
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextField(
              controller: _lastNameController,
              style: const TextStyle(color: Colors.black), // Couleur du texte noir
              decoration: const InputDecoration(
                hintText: 'Doe',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateUserInfo,

                child: const Text('Enregistrer'),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '*les champs sont obligatoires',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
