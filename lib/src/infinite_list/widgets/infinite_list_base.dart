import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_blocs/generic_blocs.dart';

class InfiniteListBase<T, BlocType extends InfiniteListBlocBase<T, dynamic>>
    extends StatelessWidget {
  final Widget Function(T) toWidget;
  final Widget failureIndicator;
  final Widget loadingIndicator;
  final Future<void> Function(BuildContext context) onRefresh;

  InfiniteListBase({
    @required this.toWidget,
    @required this.failureIndicator,
    @required this.loadingIndicator,
    @required this.onRefresh,
  })  : assert(toWidget != null),
        assert(failureIndicator != null),
        assert(loadingIndicator != null),
        assert(onRefresh != null);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<BlocType>(context);
    return BlocBuilder<BlocType, InfiniteListState<T>>(
        builder: (context, state) {
      return RefreshIndicator(
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
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
          },
        ),
        onRefresh: () => onRefresh(context),
      );
    });
  }
}
