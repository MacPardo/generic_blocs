import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_blocs/generic_blocs.dart';

class FiniteList<T, BlocType extends Bloc<dynamic, FiniteListState<T>>>
    extends StatelessWidget {
  final Widget Function(T) toWidget;
  final Widget failureIndicator;
  final Widget loadingIndicator;
  final Future<void> Function(BuildContext context) onRefresh;

  FiniteList({
    @required this.toWidget,
    @required this.loadingIndicator,
    @required this.failureIndicator,
    @required this.onRefresh,
  })  : assert(toWidget != null),
        assert(loadingIndicator != null),
        assert(failureIndicator != null),
        assert(onRefresh != null);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlocType, FiniteListState<T>>(builder: (context, state) {
      return RefreshIndicator(
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (state is LoadedFiniteListState<T> &&
                index < state.list.length) {
              return toWidget(state.list[index]);
            } else if (state is LoadingFiniteListState<T> && index == 0) {
              return loadingIndicator;
            } else if (state is ErrorFiniteListState<T> && index == 0) {
              return failureIndicator;
            }

            return null;
          },
        ),
        onRefresh: () => onRefresh(context),
      );
    });
  }
}
