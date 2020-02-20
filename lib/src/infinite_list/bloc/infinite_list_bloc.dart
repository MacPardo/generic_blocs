import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:generic_blocs/generic_blocs.dart';

typedef InfiniteListSource<T, Failure> = Future<Either<List<T>, Failure>>
    Function(int);

abstract class AbstractInfiniteListBloc<T, Failure>
    extends Bloc<InfiniteListEvent<T, Failure>, InfiniteListState<T>> {
  static const int firstPage = 1;
  int _nextPage = firstPage;
  InfiniteListSource<T, Failure> _source;
  bool _sourceClosed = false;

  @protected
  Stream<InfiniteListState<T>> onFailure(Failure failure);

  @override
  InfiniteListState<T> get initialState => InfiniteListState<T>(list: []);

  @override
  Stream<InfiniteListState<T>> mapEventToState(
    InfiniteListEvent<T, Failure> event,
  ) async* {
    if (event is ChangeSourceInfiniteListEvent<T, Failure>) {
      yield* _changeSource(event);
    } else if (event is ResetInfiniteListEvent) {
      yield* _reset(event);
    } else if (event is LoadMoreInfiniteListEvent &&
        _source != null &&
        !_sourceClosed) {
      yield* _loadMore(event);
    }
    yield state.copyWith();
  }

  Stream<InfiniteListState<T>> _changeSource(
      ChangeSourceInfiniteListEvent<T, Failure> event) async* {
    _source = event.source;
    _nextPage = firstPage;
    _sourceClosed = false;
    yield initialState;
  }

  Stream<InfiniteListState<T>> _reset(
      ResetInfiniteListEvent<T, Failure> event) async* {
    _nextPage = firstPage;
    _sourceClosed = false;
    yield initialState;
  }

  Stream<InfiniteListState<T>> _loadMore(
      LoadMoreInfiniteListEvent<T, Failure> event) async* {
    yield state.copyWith(loading: true, failed: false);
    final either = await _source(_nextPage);

    yield* either.fold((result) async* {
      _nextPage++;
      yield state.copyWith(loading: false, list: [...state.list, ...result]);
    }, (failure) async* {
      yield* onFailure(failure);
    });
  }

  @protected
  Stream<InfiniteListState<T>> disabledState() async* {
    _sourceClosed = true;
    yield state.copyWith(loading: false, disabled: true);
  }

  @protected
  Stream<InfiniteListState<T>> failedState() async* {
    yield state.copyWith(failed: true, loading: false);
  }
}
