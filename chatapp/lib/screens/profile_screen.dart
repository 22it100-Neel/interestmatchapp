import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final user = firebaseService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await firebaseService.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                user?.displayName ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user?.email ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              _buildProfileCard(
                title: 'Account Settings',
                children: [
                  _buildListTile(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      // TODO: Implement edit profile
                    },
                  ),
                  _buildListTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      // TODO: Implement notifications settings
                    },
                  ),
                  _buildListTile(
                    icon: Icons.privacy_tip,
                    title: 'Privacy',
                    onTap: () {
                      // TODO: Implement privacy settings
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildProfileCard(
                title: 'App Settings',
                children: [
                  _buildListTile(
                    icon: Icons.language,
                    title: 'Language',
                    onTap: () {
                      // TODO: Implement language settings
                    },
                  ),
                  _buildListTile(
                    icon: Icons.dark_mode,
                    title: 'Theme',
                    onTap: () {
                      // TODO: Implement theme settings
                    },
                  ),
                  _buildListTile(
                    icon: Icons.help,
                    title: 'Help & Support',
                    onTap: () {
                      // TODO: Implement help & support
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 