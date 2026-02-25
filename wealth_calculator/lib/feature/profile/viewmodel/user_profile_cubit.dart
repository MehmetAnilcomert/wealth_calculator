import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wealth_calculator/feature/profile/model/user_profile_model.dart';
import 'package:wealth_calculator/feature/profile/viewmodel/user_profile_state.dart';
import 'package:wealth_calculator/product/service/user_profile_dao.dart';
import 'package:wealth_calculator/product/state/base/base_cubit.dart';

/// Cubit for managing local user profile state.
class UserProfileCubit extends BaseCubit<UserProfileState> {
  final UserProfileDao _dao;

  UserProfileCubit({required UserProfileDao dao})
      : _dao = dao,
        super(UserProfileState.initial()) {
    loadProfile();
  }

  /// Loads the user profile from database.
  Future<void> loadProfile() async {
    emit(state.copyWith(status: UserProfileStatus.loading));
    try {
      final profile = await _dao.getProfile();
      emit(state.copyWith(
        profile: profile ?? UserProfileModel.empty(),
        status: UserProfileStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Saves the user profile with given data.
  Future<void> saveProfile({
    required String name,
    required String surname,
    String? newImagePath,
  }) async {
    emit(state.copyWith(status: UserProfileStatus.saving));
    try {
      String? savedImagePath;

      if (newImagePath != null && newImagePath.isNotEmpty) {
        // New image selected — copy to app directory
        savedImagePath = await _copyImageToAppDir(newImagePath);
      } else {
        // Keep existing image
        savedImagePath = state.profile.imagePath;
      }

      final profile = UserProfileModel(
        id: state.profile.id,
        name: name,
        surname: surname,
        imagePath: savedImagePath,
      );

      await _dao.saveProfile(profile);

      // Re-read from DB to get the correct id
      final saved = await _dao.getProfile();
      emit(state.copyWith(
        profile: saved ?? profile,
        status: UserProfileStatus.saved,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Removes the profile image only.
  Future<void> removeProfileImage() async {
    if (state.profile.imagePath != null) {
      final file = File(state.profile.imagePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    final updated = state.profile.copyWith(imagePath: '');
    final updatedClean = UserProfileModel(
      id: updated.id,
      name: updated.name,
      surname: updated.surname,
    );

    await _dao.saveProfile(updatedClean);
    emit(state.copyWith(
      profile: updatedClean,
      status: UserProfileStatus.saved,
    ));
  }

  /// Deletes the user profile and associated image.
  Future<void> deleteProfile() async {
    emit(state.copyWith(status: UserProfileStatus.saving));
    try {
      if (state.profile.imagePath != null) {
        final file = File(state.profile.imagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      await _dao.deleteProfile();
      emit(UserProfileState.initial().copyWith(
        status: UserProfileStatus.saved,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Copies selected image to app documents directory for persistence.
  Future<String> _copyImageToAppDir(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/profile');
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    // Delete old image if exists
    if (state.profile.imagePath != null) {
      final oldFile = File(state.profile.imagePath!);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }
    }

    final ext = p.extension(sourcePath);
    final fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}$ext';
    final destPath = '${profileDir.path}/$fileName';

    await File(sourcePath).copy(destPath);
    return destPath;
  }
}
