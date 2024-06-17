import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_kosmos/models/post_model.dart';
import 'package:projet_kosmos/pages/add_post_page.dart';
import 'package:projet_kosmos/pages/login_page.dart';
import 'package:projet_kosmos/pages/post_detail_page.dart';
import 'package:projet_kosmos/pages/profil_page.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:projet_kosmos/services/flushbar_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Future<Map<String, dynamic>> _getUserInfo(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return {
        'firstName': userDoc.get('firstName') ?? '',
        'lastName': userDoc.get('lastName') ?? '',
        'fullName': '${userDoc.get('firstName') ?? ''} ${userDoc.get('lastName') ?? ''}',
        'profileImageUrl': userDoc.get('profileImageUrl') ?? 'https://via.placeholder.com/150',
      };
    } else {
      await FirebaseAuth.instance.signOut();
      return {};
    }
  }

  Future<void> deletePost(BuildContext context, Post post) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(post.uid).delete();
      Navigator.of(context).pop(); // Close the bottom sheet
      FlushbarService.instance.showFlushbar(context, 'Succès', 'Post supprimé avec succès', Colors.green);
      _refreshPosts(); // Refresh the posts after deletion
    } catch (e) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Erreur lors de la suppression du post', Colors.red);
    }
  }

  Future<List<Post>> getPosts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('posts').get();
    return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }

  void _refreshPosts() {
    setState(() {});
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfilePage(userId: user.uid),
          ),
        );
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
        );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserInfo(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur de chargement des informations utilisateur: ${snapshot.error}'),
            );
          }

          final userInfo = snapshot.data ?? {};
          final userName = userInfo['firstName'] ?? 'Utilisateur';
          final userProfileImage = userInfo['profileImageUrl'] ?? 'https://via.placeholder.com/150';

          return FutureBuilder<List<Post>>(
            future: getPosts(),
            builder: (context, postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (postSnapshot.hasError) {
                return const Center(child: Text('Erreur de chargement des posts.'));
              }

              final posts = postSnapshot.data ?? [];

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 38.0), // Ajouter un padding en haut
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bonjour, $userName 👋',
                                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  const Text(
                                    'Fil d\'actualités',
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(userId: user.uid),  // Naviguer vers la page de profil
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(userProfileImage),
                                  radius: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.grey, indent: 30, endIndent: 30),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Récents',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (posts.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Pas encore de photo publiée.'),
                            ),
                          )
                        else
                          ...posts.map((post) {
                            return FutureBuilder<Map<String, dynamic>>(
                              future: _getUserInfo(post.userId),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (userSnapshot.hasError) {
                                  return const Center(child: Text('Erreur de chargement des informations utilisateur.'));
                                }

                                final postUserInfo = userSnapshot.data ?? {};
                                final postUserName = postUserInfo['fullName'] ?? 'Utilisateur';
                                final postUserProfileImage = postUserInfo['profileImageUrl'] ?? 'https://via.placeholder.com/150';

                                return _buildPostCard(context, post, postUserName, postUserProfileImage, user.uid);
                              },
                            );
                          }).toList(),
                        const SizedBox(height: 80), // Espace pour le bouton flottant
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: MediaQuery.of(context).size.width / 2 - 30,
                    child: FloatingActionButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddPostPage()));
                        if (result == true) {
                          _refreshPosts();
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Post post, String userName, String profileImageUrl, String currentUserId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostDetailPage(
                post: post,
                userName: userName,
                currentUserId: currentUserId,
                profileImageUrl: profileImageUrl,
              ),
            ),
          );
          if (result == true) {
            _refreshPosts();
          }
        },
        child: Stack(
          children: [
            Image.network(
              post.imageUrl,
              width: double.infinity,
              height: 375,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
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
                          if (post.userId == currentUserId)
                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text('Supprimer'),
                              onTap: () {
                                deletePost(context, post);
                                Navigator.pop(context);
                              },
                            )
                          else
                            ListTile(
                              leading: const Icon(Icons.report),
                              title: const Text('Signaler'),
                              onTap: () {
                                // Code pour signaler le post
                                Navigator.pop(context);
                              },
                            ),
                          ListTile(
                            leading: const Icon(Icons.cancel),
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
                child: const Icon(Icons.more_vert, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(profileImageUrl),
                    radius: 25,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            getPostTimeAgo(post.timestamp),
                            style: const TextStyle(color: Color(0xFFC1C1C1), fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.description,
                        style: const TextStyle(color: Color(0xFFC1C1C1)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getPostTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} an(s)';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mois';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min';
    } else {
      return 'À l\'instant';
    }
  }
}
