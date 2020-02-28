import 'dart:async';

import 'package:generic_blocs/generic_blocs.dart';
import 'package:generic_blocs/src/double_filter/bloc/double_filter_event.dart';
import 'package:generic_blocs/src/finite_list/bloc/finite_list_state.dart';
import 'package:generic_blocs/src/finite_output_bloc/finite_output_bloc.dart';

typedef DoubleFilter<X, Y, R> = Future<List<R>> Function(List<X>, List<Y>);

class DoubleFilterBloc<X, FailureX, Y, FailureY, R>
    extends FiniteOutputBloc<DoubleFilterEvent<X, Y, R>, R> {
  final FiniteListBlocBase<X, FailureX> blocX;
  final FiniteListBlocBase<Y, FailureY> blocY;

  StreamSubscription _subscriptionX;
  StreamSubscription _subscriptionY;

  FiniteListState<X> _currentX = LoadingFiniteListState<X>();
  FiniteListState<Y> _currentY = LoadingFiniteListState<Y>();

  DoubleFilter<X, Y, R> _filter;

  DoubleFilterBloc(this.blocX, this.blocY, this._filter) {
    _subscriptionX = blocX.listen(_onX);
    _subscriptionY = blocY.listen(_onY);
  }

  @override
  Future<void> close() {
    _subscriptionX?.cancel();
    _subscriptionY?.cancel();
    return super.close();
  }

  @override
  FiniteListState<R> get initialState => LoadingFiniteListState<R>();

  @override
  Stream<FiniteListState<R>> mapEventToState(
    DoubleFilterEvent<X, Y, R> event,
  ) async* {
    if (event is SyncDoubleFilterEvent<X, Y, R>) {
      yield* _sync(event);
    } else if (event is ChangeDoubleFilterEvent<X, Y, R>) {
      yield* _changeFilter(event);
    }
  }

  Stream<FiniteListState<R>> _sync(
    SyncDoubleFilterEvent<X, Y, R> event,
  ) async* {
    _currentX = event.stateX;
    _currentY = event.stateY;
    yield* _build();
  }

  Stream<FiniteListState<R>> _changeFilter(
    ChangeDoubleFilterEvent<X, Y, R> event,
  ) async* {
    _filter = event.filter;
    yield* _build();
  }

  Stream<FiniteListState<R>> _build() async* {
    final x = _currentX;
    final y = _currentY;

    if (x is ErrorFiniteListState<X> || y is ErrorFiniteListState<Y>) {
      yield ErrorFiniteListState<R>();
    } else if (x is LoadingFiniteListState<X> ||
        y is LoadingFiniteListState<Y>) {
      yield LoadingFiniteListState<R>();
    } else if (x is LoadedFiniteListState<X> && y is LoadedFiniteListState<Y>) {
      yield LoadedFiniteListState<R>(list: await _filter(x.list, y.list));
    }
  }

  _onX(FiniteListState<X> state) {
    add(SyncDoubleFilterEvent<X, Y, R>(
      stateX: state,
      stateY: _currentY,
    ));
  }

  _onY(FiniteListState<Y> state) {
    add(SyncDoubleFilterEvent<X, Y, R>(
      stateX: _currentX,
      stateY: state,
    ));
  }

  @override
  void refresh() {
    blocX.add(RefreshFiniteListEvent<X, FailureX>());
    blocY.add(RefreshFiniteListEvent<Y, FailureY>());
  }
}
