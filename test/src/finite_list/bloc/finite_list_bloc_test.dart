import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generic_blocs/generic_blocs.dart';

class Failure {}

List<int> l1 = [1, 2, 3];
List<int> l2 = [4, 5, 6];

Future<Either<List<int>, Failure>> source1() async => Left(l1);
Future<Either<List<int>, Failure>> source2() async => Left(l2);

class IntBloc extends FiniteListBlocBase<int, Failure> {
  @override
  Stream<FiniteListState<int>> onFailure(Failure failure) async* {
    yield ErrorFiniteListState<int>();
  }
}

void main() {
  IntBloc bloc;

  setUp(() {
    bloc = IntBloc();
  });

  group('FiniteListBloc', () {
    test('should emit Loading and Loaded state on successful reload event', () {
      expectLater(
        bloc,
        emitsInOrder([
          LoadingFiniteListState<int>(),
          LoadedFiniteListState<int>(list: l1),
        ]),
      );

      bloc.add(LoadFiniteListEvent(source: source1));
      bloc.close();
    });

    test('should go back to loading state on second reload', () {
      expectLater(
        bloc,
        emitsInOrder([
          LoadingFiniteListState<int>(),
          LoadedFiniteListState<int>(list: l1),
          LoadingFiniteListState<int>(),
          LoadedFiniteListState<int>(list: l2)
        ]),
      );

      bloc.add(LoadFiniteListEvent(source: source1));
      bloc.add(LoadFiniteListEvent(source: source2));
      bloc.close();
    });

    test('refresh loads from the same source', () {
      expectLater(
        bloc,
        emitsInOrder([
          LoadingFiniteListState<int>(),
          LoadedFiniteListState<int>(list: l1),
          LoadingFiniteListState<int>(),
          LoadedFiniteListState<int>(list: l1)
        ]),
      );

      bloc.add(LoadFiniteListEvent(source: source1));
      bloc.add(RefreshFiniteListEvent());
      bloc.close();
    });

    test('a refresh without a load before loads an empty list', () {
      expectLater(
        bloc,
        emitsInOrder([
          LoadingFiniteListState<int>(),
          LoadedFiniteListState<int>(list: []),
        ]),
      );

      bloc.add(RefreshFiniteListEvent());
      bloc.close();
    });
  });
}
