import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final GoogleSignIn _googleSignIn;

  FirebaseService() {
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb 
        ? '258107692441-8rrk458pa179eiqf8vb2pmdi7li0at0h.apps.googleusercontent.com'
        : null,
      scopes: ['email'],
    );
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('Attempting email/password sign in...'); // Debug print
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Sign in successful: ${userCredential.user?.uid}'); // Debug print
      
      // Update user's online status
      await updateUserStatus(userCredential.user!.uid, 'online');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code} - ${e.message}'); // Debug print
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        default:
          message = e.message ?? 'An error occurred during sign in.';
      }
      throw Exception(message);
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password, String name) async {
    try {
      print('Starting email/password sign up process...'); // Debug print
      print('Email: $email, Name: $name'); // Debug print (don't log password)
      
      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Firebase user created successfully: ${userCredential.user?.uid}'); // Debug print
      
      // Create user document in Firestore
      print('Creating user document in Firestore...'); // Debug print
      await _createOrUpdateUser(userCredential.user!, name: name);
      print('User document created successfully'); // Debug print
      
      // Update user's online status
      print('Updating user status to online...'); // Debug print
      await updateUserStatus(userCredential.user!.uid, 'online');
      print('User status updated successfully'); // Debug print
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Detailed sign up error: ${e.code} - ${e.message}'); // Debug print
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          message = 'The email address is invalid.';
          break;
        default:
          message = e.message ?? 'An error occurred during sign up.';
      }
      throw Exception(message);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-in process...'); // Debug print
      
      // First, try to sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-in cancelled by user'); // Debug print
        return null;
      }
      print('Google Sign-in successful, getting auth...'); // Debug print

      // Get the auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('Got Google auth details'); // Debug print

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      print('Signing in to Firebase...'); // Debug print
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      print('Firebase sign-in successful: ${userCredential.user?.uid}'); // Debug print
      
      // Create or update user document
      await _createOrUpdateUser(userCredential.user!);
      
      // Update user's online status
      await updateUserStatus(userCredential.user!.uid, 'online');
      
      return userCredential;
    } catch (e) {
      print('Detailed Google Sign-in error: $e'); // Debug print
      if (e.toString().contains('People API')) {
        throw Exception('Google Sign-in is not properly configured. Please enable the People API in Google Cloud Console.');
      }
      throw Exception('Failed to sign in with Google. Please try again.');
    }
  }

  // Create or update user document
  Future<void> _createOrUpdateUser(User user, {String? name}) async {
    try {
      final userData = {
        'name': name ?? user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'lastSeen': FieldValue.serverTimestamp(),
        'status': 'online',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(
        userData,
        SetOptions(merge: true),
      );
      print('User document created/updated successfully'); // Debug print
    } catch (e) {
      print('Error creating/updating user document: $e'); // Debug print
      // Don't throw here, as the user is already created in Firebase Auth
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return;

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore.collection('users').doc(user.uid).update(updates);
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  // Update user status
  Future<void> updateUserStatus(String userId, String status) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': status,
        'lastSeen': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user status: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final user = currentUser;
      if (user != null) {
        await updateUserStatus(user.uid, 'offline');
      }
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Create a new chat
  Future<String> createChat(String otherUserId) async {
    try {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      final chatRef = await _firestore.collection('chats').add({
        'participants': [currentUserId, otherUserId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return chatRef.id;
    } catch (e) {
      print('Error creating chat: $e');
      rethrow;
    }
  }

  // Add this method to send a message
  Future<void> sendMessage(String senderId, String receiverId, String message) async {
    try {
      final chatId = _getChatId(senderId, receiverId);
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': senderId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Update last message in chat document
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [senderId, receiverId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
      throw e;
    }
  }

  // Add this method to get chat messages stream
  Stream<QuerySnapshot> getChatMessages(String currentUserId, String otherUserId) {
    final chatId = _getChatId(currentUserId, otherUserId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Helper method to generate a consistent chat ID
  String _getChatId(String userId1, String userId2) {
    // Sort user IDs to ensure consistent chat ID regardless of who initiates
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Get user's chats
  Stream<QuerySnapshot> getUserChats() {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  // Add this method to save user interests
  Future<void> saveUserInterests(String userId, List<String> interests) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'interests': interests,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User interests saved successfully');
    } catch (e) {
      print('Error saving user interests: $e');
      throw e;
    }
  }

  // Add this method to get users with matching interests
  Future<List<Map<String, dynamic>>> getUsersWithMatchingInterests(String currentUserId) async {
    try {
      // Get current user's interests
      final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
      final currentUserInterests = List<String>.from(currentUserDoc.data()?['interests'] ?? []);
      
      if (currentUserInterests.isEmpty) return [];

      // Get all users who share at least one interest
      final usersSnapshot = await _firestore.collection('users').get();
      
      final matchingUsers = usersSnapshot.docs
          .where((doc) => doc.id != currentUserId) // Exclude current user
          .map((doc) => {
                'id': doc.id,
                'data': doc.data(),
                'matchingInterests': List<String>.from(doc.data()['interests'] ?? [])
                    .where((interest) => currentUserInterests.contains(interest))
                    .toList(),
              })
          .where((user) => (user['matchingInterests'] as List).isNotEmpty)
          .toList();

      return matchingUsers;
    } catch (e) {
      print('Error getting matching users: $e');
      throw e;
    }
  }

  // Add this method to get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      throw e;
    }
  }

  // Add this method to get the current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
} 