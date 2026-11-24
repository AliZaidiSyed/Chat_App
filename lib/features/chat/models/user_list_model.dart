class UserListTileState {
  final bool isLoading;
  final String? requestStatus;
  final bool areFriends;
  final bool isRequestSender;
  final String? pendingRequestId;


  const UserListTileState({
    this.isLoading = false,
    this.requestStatus,
    this.areFriends = false,
    this.isRequestSender = false,
    this.pendingRequestId,
  });

  UserListTileState copyWith({
    bool? isLoading,
    String? requestStatus,
    bool? areFriends,
    bool? isRequestSender,
    String? pendingRequestId,
  }) {
    return UserListTileState(
      isLoading: isLoading?? this.isLoading,
      requestStatus: requestStatus?? this.requestStatus,
      areFriends: areFriends??this.areFriends,
      isRequestSender: isRequestSender?? this.isRequestSender,
      pendingRequestId: pendingRequestId?? this.pendingRequestId,

    );
  }
}