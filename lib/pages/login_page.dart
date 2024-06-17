import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_kosmos/pages/register_page.dart';
import 'package:projet_kosmos/pages/home_page.dart';
import 'package:projet_kosmos/services/flushbar_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future<void> login() async {
      if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
        FlushbarService.instance.showFlushbar(context, 'Erreur', 'Veuillez entrer une adresse email et un mot de passe.', Colors.red);
        return;
      }

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          if(userCredential.user?.emailVerified == false){
           FlushbarService.instance.showFlushbar(context, 'Erreur', 'Veuillez vérifier votre adresse email.', Colors.red);
            return;
          }
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        FlushbarService.instance.showFlushbar(context, 'Erreur', 'Erreur lors de la connexion.', Colors.red);
      }
    }
    // go to login page

    void showResetPasswordSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (context) {
          final TextEditingController resetEmailController = TextEditingController();

          Future<void> resetPassword() async {
            if (resetEmailController.text.trim().isEmpty) {
              FlushbarService.instance.showFlushbar(context, 'Erreur', 'Veuillez entrer une adresse email.', Colors.red);
              return;
            }

            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: resetEmailController.text.trim(),
              );
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Vérifiez votre boîte mail'),
                    content: const Text('Vous avez reçu un email afin de réinitialiser votre mot de passe.'),
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
            } catch (e) {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Une erreur est survenue'),
                    content: Text(e.toString()),
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
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
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
                      'Réinitialiser mot de passe',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Entrez l\'adresse email associée à votre compte. Nous vous enverrons un email de réinitialisation sur celle-ci.',
                    style: TextStyle(fontSize: 16),
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
                  TextField(
                    controller: resetEmailController,
                    decoration: const InputDecoration(
                      hintText: 'john.doe@gmail.com',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: resetPassword,
                    child: const Text('Réinitialiser'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Connectez-vous ou créez un compte.',
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
                  controller: emailController,
                  style: const TextStyle(color: Colors.black), // Couleur du texte noir
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
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Mot de passe',
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      text: 'Mot de passe oublié ? ',
                      style: const TextStyle(color: Colors.black), // Couleur du texte non cliquable
                      children: [
                        TextSpan(
                          text: 'Réinitialiser',
                          style: const TextStyle(color: Color(0xFF02132B), decoration: TextDecoration.underline), // Couleur du texte cliquable
                          recognizer: TapGestureRecognizer()
                            ..onTap = showResetPasswordSheet,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: login,

                  child: const Text('Connexion'),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      text: 'Pas de compte ? ',
                      style: const TextStyle(color: Colors.black), // Couleur du texte non cliquable
                      children: [
                        TextSpan(
                          text: 'Créer maintenant',
                          style: const TextStyle(color: Color(0xFF02132B), decoration: TextDecoration.underline), // Couleur du texte cliquable
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
