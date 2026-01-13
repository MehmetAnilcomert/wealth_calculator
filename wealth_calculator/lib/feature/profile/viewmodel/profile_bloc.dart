import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_calculator/feature/profile/model/user_model.dart';
import 'package:wealth_calculator/feature/profile/viewmodel/profile_event.dart';
import 'package:wealth_calculator/feature/profile/viewmodel/profile_state.dart';
import 'package:wealth_calculator/product/state/base/base_bloc.dart';
import 'package:wealth_calculator/product/utility/constants/enums/profile_status.dart';

class ProfileBloc extends BaseBloc<ProfileEvent, ProfileState> {
  // TODO: Inject AuthService and UserRepository when implemented
  ProfileBloc() : super(ProfileState.initial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadProfilePicture>(_onUploadProfilePicture);
    on<DeleteProfilePicture>(_onDeleteProfilePicture);
    on<UpdateUserRole>(_onUpdateUserRole);
    on<RefreshStatistics>(_onRefreshStatistics);
    on<Logout>(_onLogout);
    on<DeleteAccount>(_onDeleteAccount);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      // TODO: Check authentication status from AuthService
      // For now, simulate with guest user
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate unauthenticated state
      emit(ProfileState.unauthenticated());

      // TODO: Replace with actual auth check
      // final isAuthenticated = await authService.isAuthenticated();
      // if (isAuthenticated) {
      //   final user = await userRepository.getCurrentUser();
      //   emit(ProfileState.authenticated(user));
      // } else {
      //   emit(ProfileState.unauthenticated());
      // }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Kimlik doğrulama kontrolü başarısız: $e',
      ));
    }
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      // TODO: Load user from repository
      await Future.delayed(const Duration(seconds: 1));

      // Mock user data for now
      final user = User(
        id: '1',
        name: 'Ahmet Yılmaz',
        email: 'ahmet.yilmaz@example.com',
        role: UserRole.premium,
        createdAt: DateTime(2024, 1, 1),
        lastLogin: DateTime.now(),
        statistics: {
          'totalAssets': 250000.0,
          'monthlyIncome': 15000.0,
          'monthlyExpense': 10000.0,
          'savingsRate': 0.33,
        },
      );

      emit(ProfileState.authenticated(user));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Profil yüklenemedi: $e',
      ));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    try {
      // TODO: Update user in repository
      await Future.delayed(const Duration(seconds: 1));

      final updatedUser = state.user.copyWith(
        name: event.name,
        email: event.email,
        profilePicture: event.profilePicture,
      );

      emit(state.copyWith(
        user: updatedUser,
        status: ProfileStatus.updated,
        isEditing: false,
      ));

      // Return to loaded state after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      emit(state.copyWith(status: ProfileStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Profil güncellenemedi: $e',
      ));
    }
  }

  Future<void> _onUploadProfilePicture(
    UploadProfilePicture event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    try {
      // TODO: Upload image to storage service
      await Future.delayed(const Duration(seconds: 1));

      final updatedUser = state.user.copyWith(
        profilePicture: event.imagePath,
      );

      emit(state.copyWith(
        user: updatedUser,
        status: ProfileStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Profil resmi yüklenemedi: $e',
      ));
    }
  }

  Future<void> _onDeleteProfilePicture(
    DeleteProfilePicture event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    try {
      // TODO: Delete image from storage service
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedUser = state.user.copyWith(profilePicture: '');

      emit(state.copyWith(
        user: updatedUser,
        status: ProfileStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Profil resmi silinemedi: $e',
      ));
    }
  }

  Future<void> _onUpdateUserRole(
    UpdateUserRole event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final updatedUser = state.user.copyWith(role: event.role);
      emit(state.copyWith(user: updatedUser));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Kullanıcı rolü güncellenemedi: $e',
      ));
    }
  }

  Future<void> _onRefreshStatistics(
    RefreshStatistics event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      // TODO: Fetch latest statistics from services
      await Future.delayed(const Duration(seconds: 1));

      final updatedStatistics = {
        'totalAssets': 250000.0,
        'monthlyIncome': 15000.0,
        'monthlyExpense': 10000.0,
        'savingsRate': 0.33,
      };

      final updatedUser = state.user.copyWith(statistics: updatedStatistics);

      emit(state.copyWith(user: updatedUser));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'İstatistikler yenilenemedi: $e',
      ));
    }
  }

  Future<void> _onLogout(
    Logout event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      // TODO: Clear auth tokens and user session
      await Future.delayed(const Duration(milliseconds: 500));

      emit(ProfileState.unauthenticated());
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Çıkış yapılamadı: $e',
      ));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    try {
      // TODO: Delete user account from backend
      await Future.delayed(const Duration(seconds: 1));

      emit(ProfileState.unauthenticated());
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Hesap silinemedi: $e',
      ));
    }
  }
}
