import 'package:flutter_bloc/flutter_bloc.dart';

/// A base Cubit class that provides common functionality for all Cubits in the application.
abstract class BaseCubit<T extends Object> extends Cubit<T> {
  /// Creates an instance of [BaseCubit] with the given initial state.
  BaseCubit(super.initialState);

  @override
  void emit(T newState) {
    if (isClosed) return;
    super.emit(newState);
  }
}
