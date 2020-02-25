import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generic_blocs/generic_blocs.dart';
import 'package:mockito/mockito.dart';

final l1 = List.generate(10, (i) => faker.randomGenerator.integer(100));
final l2 = List.generate(10, (i) => faker.randomGenerator.integer(100));
final l3 = List.generate(10, (i) => faker.randomGenerator.integer(100));

List<int> transformer(List<int> l) =>
    l.map((a) => a * 5).where((a) => a % 2 == 0).toList();

class MockFiniteList extends Mock implements FiniteListBlocBase<int, void> {}

void main() {
  MockFiniteList countFiniteList;
  FilterBloc<int> transformBloc;

  setUp(() {
    countFiniteList = MockFiniteList();
    transformBloc = FilterBloc<int>(countFiniteList);
  });

  group('TransformBloc', () {
    test('initial state is LoadingFiniteListState', () {
      expect(transformBloc.initialState, isA<LoadingFiniteListState>());
    });
    test('initial transformer is identity function', () {
      for (int i = 0; i < 20; i++) {
        final list = List.generate(
          20,
          (i) => faker.randomGenerator.integer(1000),
        );
        expect(transformBloc.initialFilter(list), list);
      }
    });

    test('mimics FinteListBloc while with identity transformer', () {
      final finiteListStates = [
        LoadingFiniteListState<int>(),
        LoadedFiniteListState<int>(list: l1),
        LoadedFiniteListState<int>(list: l2),
        LoadedFiniteListState<int>(list: l3),
        ErrorFiniteListState<int>(),
      ];

      expectLater(
        transformBloc,
        emitsInOrder(finiteListStates),
      );

      finiteListStates.forEach((s) {
        transformBloc.add(SyncWithListFilterEvent(finiteListState: s));
      });
      transformBloc.close();
    });

    test(
        'the list in the state correspond to the list returned by the transformer',
        () {
      final List<int> Function(List<int>) transformer =
          (a) => a.map((x) => x * 2).toList();
      final finiteListStates = [
        LoadingFiniteListState<int>(),
        LoadedFiniteListState<int>(list: l1),
        LoadedFiniteListState<int>(list: l2),
        LoadedFiniteListState<int>(list: l3),
        ErrorFiniteListState<int>(),
      ];

      expectLater(
        transformBloc,
        emitsInOrder([
          LoadingFiniteListState<int>(),
          LoadedFiniteListState<int>(list: transformer(l1)),
          LoadedFiniteListState<int>(list: transformer(l2)),
          LoadedFiniteListState<int>(list: transformer(l3)),
          ErrorFiniteListState<int>(),
        ]),
      );

      transformBloc.add(ChangeFilterEvent(filter: transformer));
      finiteListStates.forEach((s) {
        transformBloc.add(SyncWithListFilterEvent(finiteListState: s));
      });
      transformBloc.close();
    });
  });
}
