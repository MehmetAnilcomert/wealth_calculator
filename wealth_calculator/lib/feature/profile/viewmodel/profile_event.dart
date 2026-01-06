import 'package:equatable/equatable.dart';
import 'package:wealth_calculator/feature/profile/model/user_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String email;
  final String? profilePicture;

  const UpdateProfile({
    required this.name,
    required this.email,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [name, email, profilePicture];
}

class UploadProfilePicture extends ProfileEvent {
  final String imagePath;

  const UploadProfilePicture(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

class DeleteProfilePicture extends ProfileEvent {
  const DeleteProfilePicture();
}

class UpdateUserRole extends ProfileEvent {
  final UserRole role;

  const UpdateUserRole(this.role);

  @override
  List<Object> get props => [role];
}

class RefreshStatistics extends ProfileEvent {
  const RefreshStatistics();
}

class Logout extends ProfileEvent {
  const Logout();
}

class DeleteAccount extends ProfileEvent {
  const DeleteAccount();
}

class CheckAuthStatus extends ProfileEvent {
  const CheckAuthStatus();
}
