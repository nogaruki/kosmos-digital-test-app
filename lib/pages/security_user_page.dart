import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_kosmos/pages/email_modification_page.dart';
import 'package:projet_kosmos/pages/password_modification_page.dart';

class SecurityUserPage extends StatefulWidget {
  const SecurityUserPage({super.key});

  @override
  _SecurityUserPageState createState() => _SecurityUserPageState();
}

class _SecurityUserPageState extends State<SecurityUserPage> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Sécurité'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: const Text('Adresse email'),
                  subtitle: const Text("marie.doe@gmail.com"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailModificationPage(userId: user.uid),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: const Text('Mot de passe'),
                  subtitle: const Text("Dernière modification : il y a 3j"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PasswordModificationPage(userId: user.uid),
                      ),
                    );
                  },
                ),
              ),
              // Ajout d'autres sections et boutons selon les besoins
            ],
          ),
        ),
      ),
    );
  }
}
