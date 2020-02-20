import 'package:meta/meta.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_blocs/generic_blocs.dart';

typedef FiniteListSource<T, Failure> = Future<Either<List<T>, Failure>>
    Function();

abstract class FiniteListBloc<T, Failure>
    extends Bloc<FiniteListEvent<T, Failure>, FiniteListState<T>> {
  FiniteListSource _lastSource = () async => Left<List<T>, Failure>(<T>[]);

  @protected
  Stream<FiniteListState<T>> onFailure(Failure failure);

  @override
  FiniteListState<T> get initialState => LoadingFiniteListState();

  @override
  Stream<FiniteListState<T>> mapEventToState(
    FiniteListEvent<T, Failure> event,
  ) async* {
    if (event is LoadFiniteListEvent<T, Failure>) {
      yield* _loadEvent(event);
    } else if (event is RefreshFiniteListEvent<T, Failure>) {
      yield* _refreshEvent(event);
    }
  }

  Stream<FiniteListState<T>> _loadEvent(
    LoadFiniteListEvent<T, Failure> event,
  ) async* {
    _lastSource = event.source;
    yield* _load(event.source);
  }

  Stream<FiniteListState<T>> _refreshEvent(
    RefreshFiniteListEvent<T, Failure> event,
  ) async* {
    yield* _load(_lastSource);
  }

  Stream<FiniteListState<T>> _load(
    FiniteListSource<T, Failure> source,
  ) async* {
    yield LoadingFiniteListState<T>();
    final either = await source();
    yield* either.fold((list) async* {
      yield LoadedFiniteListState<T>(list: list);
    }, (failure) async* {
      yield* onFailure(failure);
    });
  }
}
