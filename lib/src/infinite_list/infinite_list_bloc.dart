import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:generic_blocs/generic_blocs.dart';

typedef InfiniteListSource<T, Failure> = Future<Either<List<T>, Failure>>
    Function(int);

abstract class InfiniteListBloc<T, Failure>
    extends Bloc<InfiniteListEvent<T>, InfiniteListState<T>> {
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
    InfiniteListEvent<T> event,
  ) async* {
    if (event is ChangeSourceInfiniteListEvent<T>) {
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
      ChangeSourceInfiniteListEvent<T> event) async* {
    _source = event.source;
    _nextPage = firstPage;
    _sourceClosed = false;
    yield initialState;
  }

  Stream<InfiniteListState<T>> _reset(ResetInfiniteListEvent<T> event) async* {
    _nextPage = firstPage;
    _sourceClosed = false;
    yield initialState;
  }

  Stream<InfiniteListState<T>> _loadMore(
      LoadMoreInfiniteListEvent<T> event) async* {
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
  Stream<InfiniteListState<T>> disable() async* {
    _sourceClosed = true;
    yield state.copyWith(loading: false, disabled: true);
  }

  @protected
  Stream<InfiniteListState<T>> fail() async* {
    yield state.copyWith(failed: true, loading: false);
  }
}
