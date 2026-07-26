import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Firebase exception to user-safe readable message mapper.
abstract class FirebaseFailureMapper {
  static String map(Object exception) {
    if (exception is FirebaseException) {
      return switch (exception.code) {
        'permission-denied' =>
          'Access denied. You do not have permission for this action.',
        'not-found' => 'The requested document or item was not found.',
        'already-exists' => 'This record or identifier already exists.',
        'unavailable' =>
          'Network service is temporarily unavailable. Please check connection.',
        'deadline-exceeded' =>
          'The request timed out. Please try again shortly.',
        'unauthenticated' =>
          'Authentication required. Please sign in to proceed.',
        'cancelled' => 'The operation was cancelled.',
        'invalid-argument' => 'Invalid data provided for request.',
        'failed-precondition' =>
          'Operation failed prerequisite checks. Please refresh.',
        'aborted' => 'Operation conflicted with another change.',
        'resource-exhausted' => 'Request limit reached. Please try later.',
        _ => exception.message ?? 'An unexpected database error occurred.',
      };
    }
    return exception.toString().replaceAll('Exception: ', '');
  }
}
