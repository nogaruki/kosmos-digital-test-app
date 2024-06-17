import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projet_kosmos/services/flushbar_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:projet_kosmos/pages/edit_user_page.dart';
import 'package:projet_kosmos/pages/security_user_page.dart';

import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _userInfoFuture;
  bool _notificationsEnabled = true; // Initialiser selon vos besoins
  File? _imageFile;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _userInfoFuture = _getUserInfo(widget.userId);
  }

  Future<Map<String, dynamic>> _getUserInfo(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      setState(() {
        _profileImageUrl = userDoc.get('profileImageUrl') ?? 'https://via.placeholder.com/150';
      });
      return {
        'profileImageUrl': _profileImageUrl,
        'fullName': '${userDoc.get('firstName') ?? ''} ${userDoc.get('lastName') ?? ''}',
        'email': userDoc.get('email') ?? '',
      };
    } else {
      return {
        'profileImageUrl': 'https://via.placeholder.com/150',
        'fullName': 'Utilisateur',
        'email': '',
      };
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImageToFirebase();
    }
  }

  Future<void> _uploadImageToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child('profile_images').child(fileName);

      await storageRef.putFile(_imageFile!);
      final downloadUrl = await storageRef.getDownloadURL();

      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profileImageUrl': downloadUrl,
      });

      setState(() {
        _profileImageUrl = downloadUrl;
      });
      FlushbarService.instance.showFlushbar(context, 'Succès', 'Photo de profil mise à jour avec succès', Colors.green);
    } catch (e) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Erreur lors de la mise à jour de la photo de profil', Colors.red);
    }
  }

  Future<void> _deleteProfile(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

      await user.delete();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
      );
      FlushbarService.instance.showFlushbar(context, 'Succès', 'Profil supprimé avec succès', Colors.green);
    } catch (e) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Erreur lors de la suppression du profil', Colors.red);
    }
  }
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer mon compte'),
          content: const Text('Souhaitez-vous vraiment supprimer votre compte ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteProfile(context);
              },
              child: const Text('Oui', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        title: Text(
                          'Que souhaitez-vous faire ?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ListTile(
                        title: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                                (Route<dynamic> route) => false,
                          );

                        },
                      ),
                      ListTile(
                        title: const Text('Supprimer mon profil', style: TextStyle(color: Colors.red)),
                        onTap: () async {
                          _showDeleteConfirmationDialog(context);
                        },
                      ),
                      ListTile(
                        title: const Text('Annuler'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(11.0),
              child: Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur de chargement des informations utilisateur: ${snapshot.error}'),
            );
          }

          final user = snapshot.data ?? {
            'profileImageUrl': 'https://via.placeholder.com/150',
            'fullName': 'Utilisateur',
            'email': '',
          };

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(user['profileImageUrl']!),
                              radius: 50,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 35,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 15),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ListTile(
                                            leading: const Icon(Icons.photo_library),
                                            title: const Text('Choisir une photo'),
                                            onTap: () {
                                              _pickImage(ImageSource.gallery);
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.photo_camera),
                                            title: const Text('Prendre une photo'),
                                            onTap: () {
                                              _pickImage(ImageSource.camera);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user['fullName']!,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user['email']!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 40, thickness: 1),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Mon compte',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user['profileImageUrl']!),
                      ),
                      title: Text(user['fullName']!),
                      subtitle: Text(user['email']!),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditUserPage()),
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
                      leading: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFF02132B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Colors.white,
                        ),
                      ),
                      title: const Text('Sécurité'),
                      subtitle: const Text('Mot de passe, email..'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SecurityUserPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Paramètres',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFF02132B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      ),
                      title: const Text('Notifications push'),
                      subtitle: Text(_notificationsEnabled ? 'Activées' : 'Désactivées'),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        activeColor: const Color(0xFFFFFFFF),
                        activeTrackColor: const Color(0xFF02132B),
                        onChanged: (bool value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Autres',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFF02132B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.question_mark_rounded,
                          color: Colors.white,
                        ),
                      ),
                      title: const Text('Aide'),
                      subtitle: const Text('Contactez-nous par email'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'contact@kosmos-digital.com',
                          query: encodeQueryParameters(<String, String>{
                            'subject': 'Besoin d\'aide',
                          }),
                        );
                        launchUrl(emailLaunchUri);
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
                      leading: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFF02132B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                      ),
                      title: const Text('Partager l\'app'),
                      subtitle: const Text('Soutenez-nous en partageant l’app'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'contact@kosmos-digital.com',
                          query: encodeQueryParameters(<String, String>{
                            'subject': 'Besoin d\'aide',
                          }),
                        );
                        launchUrl(emailLaunchUri);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Liens',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: const Text('Politique de confidentialité'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Action à définir pour ouvrir la politique de confidentialité
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
                      title: const Text('Conditions générales de ventes et d\'utilisation'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                     // Action à définir pour ouvrir les conditions générales
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
                      title: const Text('Mentions légales'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Action à définir pour accéder aux mentions légales
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
                      title: const Text('À propos'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                       // Action à définir pour accéder à la page "À propos"
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Réseaux sociaux',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSocialMediaButton(
                    icon: Icons.facebook,
                    color: const Color(0xFF3b5998),
                    text: 'Notre page Facebook',
                    onTap: () => _launchURL(Uri.parse('https://www.facebook.com')),
                  ),
                  _buildSocialMediaButton(
                    icon: Icons.camera_alt,
                    color: const Color(0xFFE1306C),
                    text: 'Notre Instagram',
                    onTap: () => _launchURL(Uri.parse('https://www.instagram.com')),
                  ),
                  _buildSocialMediaButton(
                    icon: Icons.message,
                    color: const Color(0xFF1DA1F2),
                    text: 'Notre Twitter',
                    onTap: () => _launchURL(Uri.parse('https://www.twitter.com')),
                  ),
                  _buildSocialMediaButton(
                    icon: Icons.snapchat,
                    color: const Color(0xFFFFFC00),
                    text: 'Notre Snapchat',
                    onTap: () => _launchURL(Uri.parse('https://www.snapchat.com')),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => _launchURL(Uri.parse('https://kosmos-digital.com')),
                      child: RichText(

                        text: const TextSpan(
                          text: 'Edité par ',
                          style: TextStyle(color: Color(0xFF02132B), fontSize: 16),
                          children: [
                            TextSpan(
                              text: 'Kosmos Digital',
                              style: TextStyle(color: Color(0xFF02132B), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSocialMediaButton({required IconData icon, required Color color, required String text, required Function onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => onTap(),
      ),
    );
  }

  void _launchURL(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
