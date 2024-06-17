import 'package:flutter/material.dart';
import 'package:projet_kosmos/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:projet_kosmos/services/flushbar_service.dart';

import 'home_page.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;
  final String userName;
  final String currentUserId;
  final String profileImageUrl;

  const PostDetailPage({
    super.key,
    required this.post,
    required this.userName,
    required this.currentUserId,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.network(
            post.imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false indicating no refresh needed
                },
              ),
            ),
          ),
          Positioned(
            top: 44,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(50),
              ),
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
                                deletePost(context, post.uid);
                              },
                            )
                          else
                            ListTile(
                              leading: const Icon(Icons.report),
                              title: const Text('Signaler'),
                              onTap: () {
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
                child: const Padding(
                  padding: EdgeInsets.all(11.0),
                  child: Icon(Icons.more_vert, color: Colors.white),
                ),
              ),
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
    );
  }

  Future<void> deletePost(BuildContext context, String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      FlushbarService.instance.showFlushbar(context, 'Succès', 'Post supprimé avec succès', Colors.green);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false
      );
    } catch (e) {
      FlushbarService.instance.showFlushbar(context, 'Erreur', 'Erreur lors de la suppression du post', Colors.red);
    }
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
