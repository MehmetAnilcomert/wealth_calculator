part of 'theme_cubit.dart';

/// State for theme management
class ThemeState extends Equatable {
  /// Initialize ThemeState with [themeMode]
  const ThemeState({required this.themeMode});

  /// Current theme mode
  final ThemeMode themeMode;

  @override
  List<Object> get props => [themeMode];
}
