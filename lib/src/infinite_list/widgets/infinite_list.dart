import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_blocs/generic_blocs.dart';

class InfiniteList<T, BlocType extends InfiniteListBloc<T, dynamic>>
    extends StatelessWidget {
  final Widget Function(T) toWidget;
  final Widget failureIndicator;
  final Widget loadingIndicator;

  InfiniteList({
    @required this.toWidget,
    @required this.failureIndicator,
    @required this.loadingIndicator,
  })  : assert(toWidget != null),
        assert(failureIndicator != null),
        assert(loadingIndicator != null);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<BlocType>(context);
    return BlocBuilder<BlocType, InfiniteListState<T>>(
        builder: (context, state) {
      return ListView.builder(itemBuilder: (context, index) {
        if (!state.disabled &&
            index == state.list.length &&
            !state.loading &&
            !state.failed) {
          bloc.add(LoadMoreInfiniteListEvent());
        }

        if (index < state.list.length) {
          return toWidget(state.list[index]);
        } else if (index == state.list.length && state.loading) {
          return loadingIndicator;
        } else if (index == state.list.length && state.failed) {
          return failureIndicator;
        } else {
          return null;
        }
      });
    });
  }
}
