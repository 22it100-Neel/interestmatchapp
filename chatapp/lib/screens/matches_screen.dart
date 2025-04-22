import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/user_interest.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _matchingUsers = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMatchingUsers();
  }

  Future<void> _loadMatchingUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final currentUser = firebaseService.getCurrentUser();
      
      if (currentUser != null) {
        final users = await firebaseService.getUsersWithMatchingInterests(currentUser.uid);
        if (mounted) {
          setState(() {
            _matchingUsers = users;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2196F3),  // Blue
              Color(0xFF4CAF50),  // Green
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Matches',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadMatchingUsers,
                    ),
                  ],
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.interests),
                        label: const Text('Change Interests'),
                        onPressed: () {
                          Navigator.pushNamed(context, '/interests');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.person),
                        label: const Text('Profile'),
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Matches list
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Error: $_error',
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadMatchingUsers,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF2196F3),
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _matchingUsers.isEmpty
                            ? const Center(
                                child: Text(
                                  'No matches found.\nTry selecting different interests!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _matchingUsers.length,
                                padding: const EdgeInsets.all(16),
                                itemBuilder: (context, index) {
                                  final user = _matchingUsers[index];
                                  final userData = user['data'] as Map<String, dynamic>;
                                  final matchingInterests = user['matchingInterests'] as List;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.white.withOpacity(0.2),
                                        backgroundImage: userData['photoUrl'] != null
                                            ? NetworkImage(userData['photoUrl'])
                                            : null,
                                        child: userData['photoUrl'] == null
                                            ? Text(
                                                (userData['name'] as String?)?.substring(0, 1).toUpperCase() ?? '?',
                                                style: const TextStyle(color: Colors.white),
                                              )
                                            : null,
                                      ),
                                      title: Text(
                                        userData['name'] ?? 'Anonymous',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Matching Interests:',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            children: matchingInterests.map<Widget>((interest) {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  interest.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                      trailing: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.chat,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            final userInterest = UserInterest(
                                              id: user['id'],
                                              name: userData['name'] ?? 'Anonymous',
                                              interests: List<String>.from(matchingInterests),
                                            );
                                            Navigator.pushNamed(
                                              context,
                                              '/chat',
                                              arguments: userInterest,
                                            );
                                          },
                                        ),
                                      ),
                                      onTap: () {
                                        final userInterest = UserInterest(
                                          id: user['id'],
                                          name: userData['name'] ?? 'Anonymous',
                                          interests: List<String>.from(matchingInterests),
                                        );
                                        Navigator.pushNamed(
                                          context,
                                          '/chat',
                                          arguments: userInterest,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 