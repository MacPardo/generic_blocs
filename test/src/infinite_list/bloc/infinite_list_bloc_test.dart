import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generic_blocs/generic_blocs.dart';

abstract class Failure {}

class NetworkResponseFailure extends Failure {}

class UnexpectedNetworkResponseFailure extends NetworkResponseFailure {}

class NotFoundNetworkResponseFailure extends NetworkResponseFailure {}

class UnauthorizedNetworkResponseFailure extends NetworkResponseFailure {}

List<int> f1(int a) => List.generate(10, (i) => a + i);
List<int> f2(int a) => List.generate(10, (i) => a + i * 100);
List<int> f3(int a) => List.generate(10, (i) => a + i * 1000);

final state1 = InfiniteListState<int>(list: []);

class FailsTheFirstTimeWithUnexpected {
  bool firstTime = true;

  Future<Either<List<int>, Failure>> source(int a) async {
    final result = firstTime
        ? Right<List<int>, NetworkResponseFailure>(
            UnexpectedNetworkResponseFailure())
        : Left<List<int>, NetworkResponseFailure>(f3(a));
    firstTime = false;
    return result;
  }
}

class FailsTheFirstTimeWithNotFound {
  bool firstTime = true;

  Future<Either<List<int>, Failure>> source(int a) async {
    final result = firstTime
        ? Right<List<int>, NetworkResponseFailure>(
            NotFoundNetworkResponseFailure())
        : Left<List<int>, NetworkResponseFailure>(f3(a));
    firstTime = false;
    return result;
  }
}

class FailsTheFirstTimeWithUnauthorized {
  bool firstTime = true;

  Future<Either<List<int>, Failure>> source(int a) async {
    final result = firstTime
        ? Right<List<int>, NetworkResponseFailure>(
            UnauthorizedNetworkResponseFailure())
        : Left<List<int>, NetworkResponseFailure>(f3(a));
    firstTime = false;
    return result;
  }
}

class IntBloc extends InfiniteListBloc<int, Failure> {
  @override
  Stream<InfiniteListState<int>> onFailure(Failure failure) async* {
    if (failure is NotFoundNetworkResponseFailure ||
        failure is UnauthorizedNetworkResponseFailure) {
      yield* disable();
    } else {
      yield* this.fail();
    }
  }
}

void main() {
  IntBloc bloc;
  FailsTheFirstTimeWithUnexpected failsTheFirstTimeWithUnexpected;
  FailsTheFirstTimeWithNotFound failsTheFirstTimeWithNotFound;
  FailsTheFirstTimeWithUnauthorized failsTheFirstTimeWithUnauthorized;

  Future<Either<List<int>, Failure>> firstSource(int a) async => Left(f1(a));
  Future<Either<List<int>, Failure>> secondSource(int a) async => Left(f2(a));
  Future<Either<List<int>, Failure>> brokenSource(int a) async =>
      Right(UnexpectedNetworkResponseFailure());

  setUp(() {
    failsTheFirstTimeWithUnexpected = FailsTheFirstTimeWithUnexpected();
    failsTheFirstTimeWithNotFound = FailsTheFirstTimeWithNotFound();
    failsTheFirstTimeWithUnauthorized = FailsTheFirstTimeWithUnauthorized();
    bloc = IntBloc();
  });

  group('InfiniteListBloc', () {
    test('ChangeSource changes source and makes list empty', () {
      final state2 = state1.copyWith(loading: true);
      final state3 = state1.copyWith(list: f1(1));
      final state4 = state1.copyWith(list: f2(1));

      expectLater(
        bloc,
        emitsInOrder([
          state1,
          state2,
          state3,
          state1,
          state2,
          state4,
        ]),
      );

      bloc.add(ChangeSourceInfiniteListEvent(firstSource));
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.add(ChangeSourceInfiniteListEvent(secondSource));
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.close();
    });

    test('LoadMore loads each page at a time, starting at 1', () async {
      final state2 = state1.copyWith(loading: true);
      final state3 = state2.copyWith(loading: false, list: f1(1));
      final state4 = state3.copyWith(loading: true);
      final state5 =
          state4.copyWith(loading: false, list: [...f1(1), ...f1(2)]);
      expectLater(
        bloc,
        emitsInOrder([
          state1,
          state2,
          state3,
          state4,
          state5,
        ]),
      );

      bloc.add(ChangeSourceInfiniteListEvent<int, Failure>(firstSource));
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.close();
    });

    test('Reset empties list and makes LoadMore start back from first page',
        () {
      final state2 = state1.copyWith(loading: true);
      final state3 = state2.copyWith(loading: false, list: f1(1));
      final state4 = state3.copyWith(loading: true);
      final state5 =
          state4.copyWith(loading: false, list: [...f1(1), ...f1(2)]);
      expectLater(
        bloc,
        emitsInOrder([
          state1,
          state2,
          state3,
          state4,
          state5,
          state1,
          state2,
          state3,
        ]),
      );

      bloc.add(ChangeSourceInfiniteListEvent<int, Failure>(firstSource));
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.add(ResetInfiniteListEvent());
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.close();
    });

    test('failed is set to true on failure', () {
      final state2 = state1.copyWith(loading: true);
      final state3 = state1.copyWith(failed: true);

      expectLater(
        bloc,
        emitsInOrder([
          state1,
          state2,
          state3,
        ]),
      );

      bloc.add(ChangeSourceInfiniteListEvent<int, Failure>(brokenSource));
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.close();
    });

    test(
        'failed is set back to false on a successful LoadMore and the page is not skipped',
        () {
      final state2 = state1.copyWith(loading: true);
      final state3 = state1.copyWith(failed: true);
      final state4 = state1.copyWith(list: f3(1));

      expectLater(
        bloc,
        emitsInOrder([
          state1,
          state2,
          state3,
          state2,
          state4,
        ]),
      );

      bloc.add(ChangeSourceInfiniteListEvent(
          failsTheFirstTimeWithUnexpected.source));
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.close();
    });

    test('failed is set back to false on a successful Reset', () {
      final state2 = state1.copyWith(loading: true);
      final state3 = state1.copyWith(failed: true);

      expectLater(
        bloc,
        emitsInOrder([
          state1,
          state2,
          state3,
          state1,
        ]),
      );

      bloc.add(ChangeSourceInfiniteListEvent(brokenSource));
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.add(ResetInfiniteListEvent());
      bloc.close();
    });

    test(
        'if the failure is a [NotFoundNetworkResponseFailure] the list stops loading and [failed] is not set to [true]',
        () {
      final state2 = state1.copyWith(loading: true);
      final state3 = state1.copyWith(disabled: true);

      expectLater(
        bloc,
        emitsInOrder([
          state1,
          state2,
          state3,
        ]),
      );

      bloc.add(
          ChangeSourceInfiniteListEvent(failsTheFirstTimeWithNotFound.source));
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.close();
    });

    test(
        'if the failure is a [UnauthorizedNetworkResponseFailure] the list stops loading and [failed] is not set to [true]',
        () async {
      final state2 = state1.copyWith(loading: true);
      final state3 = state1.copyWith(disabled: true);
      bloc.listen((s) {});

      expectLater(
        bloc,
        emitsInOrder([
          state1,
          state2,
          state3,
        ]),
      );

      bloc.add(
        ChangeSourceInfiniteListEvent(
          failsTheFirstTimeWithUnauthorized.source,
        ),
      );
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.add(LoadMoreInfiniteListEvent());
      bloc.close();
    });
  });
}
