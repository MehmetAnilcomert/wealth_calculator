import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/profile/model/user_profile_model.dart';

/// Status for user profile operations.
enum UserProfileStatus { initial, loading, loaded, saving, saved, error }

/// State for [UserProfileCubit].
class UserProfileState extends Equatable {
  /// Current user profile data.
  final UserProfileModel profile;

  /// Current operation status.
  final UserProfileStatus status;

  /// Error message if any.
  final String? errorMessage;

  const UserProfileState({
    required this.profile,
    this.status = UserProfileStatus.initial,
    this.errorMessage,
  });

  /// Creates the initial state with empty profile.
  factory UserProfileState.initial() => UserProfileState(
        profile: UserProfileModel.empty(),
      );

  /// Whether profile data is available.
  bool get hasProfile => profile.isNotEmpty;

  /// Whether the cubit is currently loading or saving.
  bool get isLoading =>
      status == UserProfileStatus.loading ||
      status == UserProfileStatus.saving;

  /// Creates a copy with updated fields.
  UserProfileState copyWith({
    UserProfileModel? profile,
    UserProfileStatus? status,
    String? errorMessage,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [profile, status, errorMessage];
}
