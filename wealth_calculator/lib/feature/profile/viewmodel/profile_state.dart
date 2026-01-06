import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/profile/model/user_model.dart';
import 'package:wealth_calculator/product/utility/constants/enums/profile_status.dart';

class ProfileState extends Equatable {
  final User user;
  final ProfileStatus status;
  final AuthStatus authStatus;
  final String? errorMessage;
  final bool isEditing;

  const ProfileState({
    required this.user,
    this.status = ProfileStatus.initial,
    this.authStatus = AuthStatus.unknown,
    this.errorMessage,
    this.isEditing = false,
  });

  factory ProfileState.initial() {
    return ProfileState(
      user: User.guest(),
      status: ProfileStatus.initial,
      authStatus: AuthStatus.unknown,
    );
  }

  factory ProfileState.unauthenticated() {
    return ProfileState(
      user: User.guest(),
      status: ProfileStatus.unauthenticated,
      authStatus: AuthStatus.unauthenticated,
    );
  }

  factory ProfileState.authenticated(User user) {
    return ProfileState(
      user: user,
      status: ProfileStatus.loaded,
      authStatus: AuthStatus.authenticated,
    );
  }

  ProfileState copyWith({
    User? user,
    ProfileStatus? status,
    AuthStatus? authStatus,
    String? errorMessage,
    bool? isEditing,
    bool clearError = false,
  }) {
    return ProfileState(
      user: user ?? this.user,
      status: status ?? this.status,
      authStatus: authStatus ?? this.authStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isEditing: isEditing ?? this.isEditing,
    );
  }

  bool get isAuthenticated => authStatus == AuthStatus.authenticated;

  bool get isLoading =>
      status == ProfileStatus.loading || status == ProfileStatus.updating;

  @override
  List<Object?> get props => [
        user,
        status,
        authStatus,
        errorMessage,
        isEditing,
      ];
}
