enum MutationStatus { idle, loading, success, failure }

class RowMutationState {
  const RowMutationState({
    this.status = MutationStatus.idle,
    this.errorMessage,
  });

  final MutationStatus status;
  final String? errorMessage;
}

class StitchingStatusMutationState {
  const StitchingStatusMutationState({
    this.requests = const <String, RowMutationState>{},
  });

  final Map<String, RowMutationState> requests;

  StitchingStatusMutationState copyWith({
    Map<String, RowMutationState>? requests,
  }) {
    return StitchingStatusMutationState(requests: requests ?? this.requests);
  }
}
