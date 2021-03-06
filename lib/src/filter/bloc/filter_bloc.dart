import 'dart:async';

import 'package:generic_blocs/generic_blocs.dart';
import 'package:generic_blocs/src/finite_output_bloc/finite_output_bloc.dart';

typedef ListFilter<T> = Future<List<T>> Function(List<T>);

class FilterBloc<T> extends FiniteOutputBloc<FilterEvent<T>, T> {
  final FiniteListBlocBase<T, dynamic> finiteListBloc;
  StreamSubscription _finiteListBlocSubscription;
  ListFilter<T> _currentFilter;
  FiniteListState _currentFiniteListState;

  FilterBloc(this.finiteListBloc) {
    _currentFilter = initialFilter;
    _currentFiniteListState = initialState;
    _finiteListBlocSubscription = finiteListBloc.listen(_onFiniteListState);
  }

  @override
  Future<void> close() {
    _finiteListBlocSubscription?.cancel();
    return super.close();
  }

  @override
  FiniteListState<T> get initialState => LoadingFiniteListState<T>();

  ListFilter<T> get initialFilter => (a) async => a;

  @override
  Stream<FiniteListState<T>> mapEventToState(FilterEvent<T> event) async* {
    if (event is SyncWithListFilterEvent<T>) {
      yield* _onSyncWithList(event);
    } else if (event is ChangeFilterEvent<T>) {
      yield* _onChangeFilter(event);
    }
  }

  void _onFiniteListState(FiniteListState<T> state) {
    add(SyncWithListFilterEvent<T>(finiteListState: state));
  }

  Stream<FiniteListState<T>> _onSyncWithList(
      SyncWithListFilterEvent<T> event) async* {
    final finiteListState = event.finiteListState;
    _currentFiniteListState = finiteListState;
    if (finiteListState is LoadedFiniteListState<T>) {
      yield LoadedFiniteListState(
        list: await _currentFilter(finiteListState.list),
      );
    } else {
      yield finiteListState;
    }
  }

  Stream<FiniteListState<T>> _onChangeFilter(
      ChangeFilterEvent<T> event) async* {
    _currentFilter = event.filter;
    final currentFiniteListState = _currentFiniteListState;
    if (currentFiniteListState is LoadedFiniteListState) {
      yield LoadedFiniteListState(
        list: await _currentFilter(currentFiniteListState.list),
      );
    }
  }

  @override
  void refresh() {
    finiteListBloc.add(RefreshFiniteListEvent());
  }
}
