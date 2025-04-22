import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/interests.dart';
import '../services/firebase_service.dart';

class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({Key? key}) : super(key: key);

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  final Map<String, bool> selectedInterests = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize all interests as unchecked
    for (var interest in Interests.allInterests) {
      selectedInterests[interest] = false;
    }
  }

  Future<void> _saveInterestsAndNavigate() async {
    final selected = selectedInterests.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one interest'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final currentUser = firebaseService.getCurrentUser();
      
      if (currentUser != null) {
        // Save interests to Firestore
        await firebaseService.saveUserInterests(currentUser.uid, selected);
        
        if (mounted) {
          // Navigate to matches screen
          Navigator.pushReplacementNamed(context, '/matches');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving interests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Interests',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose what you love',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: Interests.allInterests.length,
                    itemBuilder: (context, index) {
                      final interest = Interests.allInterests[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CheckboxListTile(
                          title: Text(
                            interest,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                          value: selectedInterests[interest],
                          onChanged: (bool? value) {
                            setState(() {
                              selectedInterests[interest] = value ?? false;
                            });
                          },
                          checkColor: Colors.white,
                          activeColor: Colors.transparent,
                          side: const BorderSide(color: Colors.black),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white70],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveInterestsAndNavigate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.bold,
                            ),
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