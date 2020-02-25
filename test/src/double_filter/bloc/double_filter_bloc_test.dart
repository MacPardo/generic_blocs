import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:generic_blocs/generic_blocs.dart';
import 'package:generic_blocs/src/double_filter/bloc/double_filter_bloc.dart';
import 'package:generic_blocs/src/double_filter/bloc/double_filter_event.dart';
import 'package:mockito/mockito.dart';

class MockX extends Mock implements FiniteListBlocBase<int, int> {}

class MockY extends Mock implements FiniteListBlocBase<String, String> {}

List<String> combine(List<int> a, List<String> b) {
  final List<String> x = [];

  for (int i = 0; i < min(a.length, b.length); i++) {
    x.add('${a[i]} - ${b[i]}');
  }

  return x;
}

void main() {
  MockX mockX;
  MockY mockY;
  DoubleFilterBloc<int, int, String, String, String> doubleFilterBloc;

  setUp(() {
    mockX = MockX();
    mockY = MockY();
    doubleFilterBloc = DoubleFilterBloc(mockX, mockY, combine);
  });

  group('DoubleFilterBloc', () {
    test('initial state is LoadingFiniteListState', () {
      expect(doubleFilterBloc.initialState, LoadingFiniteListState<String>());
    });

    test('reacts while applying filter function', () {
      final xStates = [
        LoadingFiniteListState<int>(),
        LoadedFiniteListState<int>(list: [1]),
        LoadedFiniteListState<int>(list: [2]),
        LoadedFiniteListState<int>(list: [3]),
        LoadingFiniteListState<int>(),
      ];
      final yStates = [
        LoadingFiniteListState<String>(),
        ErrorFiniteListState<String>(),
        LoadingFiniteListState<String>(),
        LoadedFiniteListState<String>(list: ['a']),
        ErrorFiniteListState<String>(),
      ];

      expectLater(
        doubleFilterBloc,
        emitsInOrder([
          LoadingFiniteListState<String>(),
          ErrorFiniteListState<String>(),
          LoadingFiniteListState<String>(),
          LoadedFiniteListState<String>(list: combine([3], ['a'])),
          ErrorFiniteListState<String>(),
        ]),
      );

      for (int i = 0; i < min(xStates.length, yStates.length); i++) {
        doubleFilterBloc.add(SyncDoubleFilterEvent(
          stateX: xStates[i],
          stateY: yStates[i],
        ));
      }
      doubleFilterBloc.close();
    });
  });
}
