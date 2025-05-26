import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qadam_app/app/models/challenge_model.dart';

class ChallengeService extends ChangeNotifier {
  final List<ChallengeModel> _challenges = [];
  bool _isLoading = false;
  String? _error;

  List<ChallengeModel> get challenges => _challenges;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchChallenges() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final challengesRef = FirebaseFirestore.instance.collection('challenges');
      final snapshot = await challengesRef.get();

      _challenges.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        _challenges.add(ChallengeModel(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          reward: int.tryParse(data['reward'].toString()) ?? 0,
          targetSteps: data['targetSteps'] ?? 0,
          duration: data['duration'] ?? 1,
          type: data['type'] ?? 'daily',
          startDate: DateTime.tryParse(data['startDate']) ?? DateTime.now(),
          endDate: DateTime.tryParse(data['endDate']) ?? DateTime.now(),
        ));
      }

      print(_challenges.length);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print(e);
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateChallengeProgress(
      String challengeId, double progress) async {
    try {
      await FirebaseFirestore.instance
          .collection('challenges')
          .doc(challengeId)
          .update({'progress': progress});

      final index = _challenges.indexWhere((c) => c.id == challengeId);
      if (index != -1) {
        _challenges[index] = _challenges[index].copyWith(progress: progress);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> completeChallenge(String challengeId) async {
    try {
      // Get the challenge reward amount before marking as complete
      final challenge = _challenges.firstWhere((c) => c.id == challengeId);
      final rewardAmount = challenge.reward;

      await FirebaseFirestore.instance
          .collection('challenges')
          .doc(challengeId)
          .update({
        'isCompleted': true,
        'completedAt': DateTime.now(),
      });

      // Update user's balance in Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final userDoc = await transaction.get(userRef);
          final currentBalance = userDoc.data()?['balance'] ?? 0;
          transaction.update(userRef, {
            'balance': currentBalance + rewardAmount,
          });
        });
      }

      final index = _challenges.indexWhere((c) => c.id == challengeId);
      if (index != -1) {
        _challenges[index] = _challenges[index].copyWith(isCompleted: true);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

// add challenge function

  Future<void> addChallenge(ChallengeModel challenge) async {
    try {
      final docRef =
          await FirebaseFirestore.instance.collection('challenges').add({
        'title': challenge.title,
        'description': challenge.description,
        'reward': challenge.reward,
        'targetSteps': challenge.targetSteps,
        'duration': challenge.duration,
        'type': challenge.type,
        'startDate': challenge.startDate,
        'endDate': challenge.endDate,
        'progress': challenge.progress,
        'isCompleted': challenge.isCompleted,
      });

      final newChallenge = ChallengeModel(
        id: docRef.id,
        title: challenge.title,
        description: challenge.description,
        reward: challenge.reward,
        targetSteps: challenge.targetSteps,
        duration: challenge.duration,
        type: challenge.type,
        startDate: challenge.startDate,
        endDate: challenge.endDate,
        progress: challenge.progress,
        isCompleted: challenge.isCompleted,
      );

      _challenges.add(newChallenge);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteChallenge(String challengeId) async {
    try {
      await FirebaseFirestore.instance
          .collection('challenges')
          .doc(challengeId)
          .delete();

      _challenges.removeWhere((c) => c.id == challengeId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
