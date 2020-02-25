import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_blocs/generic_blocs.dart';
import 'package:generic_blocs/src/finite_output_bloc/finite_output_bloc.dart';

class FiniteListBase<T, BlocType extends FiniteOutputBloc<dynamic, T>>
    extends StatelessWidget {
  final Widget Function(T) toWidget;
  final Widget Function(VoidCallback onRefresh) failureIndicator;
  final Widget loadingIndicator;

  FiniteListBase({
    @required this.toWidget,
    @required this.loadingIndicator,
    @required this.failureIndicator,
  })  : assert(toWidget != null),
        assert(loadingIndicator != null),
        assert(failureIndicator != null);

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
              return failureIndicator(() => _refresh(context));
            }

            return null;
          },
        ),
        onRefresh: () => _refresh(context),
      );
    });
  }

  _refresh(BuildContext context) {
    final BlocType bloc = BlocProvider.of<BlocType>(context);
    bloc.refresh();
  }
}
