import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A universal base view to handle Bloc Dependency Injection.
/// It automatically chooses between [BlocProvider] and [BlocProvider.value]
/// based on whether a bloc is injected (useful for testing or shared blocs).
class BaseView<T extends Bloc<Object?, S>, S> extends StatelessWidget {
  const BaseView({
    super.key,
    this.bloc,
    required this.create,
    required this.onPageBuilder,
  });

  /// Optional injected bloc. If provided, [BlocProvider.value] will be used.
  final T? bloc;

  /// Closure to create the bloc if [bloc] is null.
  final T Function(BuildContext context) create;

  /// UI builder that receives the bloc and the current state.
  final Widget Function(BuildContext context, T bloc) onPageBuilder;

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<T>.value(
        value: bloc!,
        child: _BaseViewBody<T, S>(onPageBuilder: onPageBuilder),
      );
    }

    return BlocProvider<T>(
      create: create,
      child: _BaseViewBody<T, S>(onPageBuilder: onPageBuilder),
    );
  }
}

class _BaseViewBody<T extends Bloc<Object?, S>, S> extends StatelessWidget {
  const _BaseViewBody({
    required this.onPageBuilder,
  });

  final Widget Function(BuildContext context, T bloc) onPageBuilder;

  @override
  Widget build(BuildContext context) {
    return onPageBuilder(context, context.read<T>());
  }
}
