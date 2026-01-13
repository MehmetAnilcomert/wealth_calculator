import 'package:flutter_bloc/flutter_bloc.dart';

/// A base Bloc class that provides common functionality for all Blocs in the application.
abstract class BaseBloc<E extends Object, S extends Object> extends Bloc<E, S> {
  /// Creates an instance of [BaseBloc] with the given initial state.
  BaseBloc(super.initialState);

  @override
  void emit(S newState) {
    if (isClosed) return;
    super.emit(newState);
  }
}
