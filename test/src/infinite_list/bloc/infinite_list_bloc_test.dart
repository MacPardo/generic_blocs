import 'package:flutter_test/flutter_test.dart';
import 'package:generic_blocs/generic_blocs.dart';

void main() {
  test('copyWith should change each field correctly', () {
    final firstList = [1, 2, 3];
    final secondList = [4, 5, 6];
    final secondListCopy = [4, 5, 6];

    final state = InfiniteListState(
      list: firstList,
      failed: false,
      loading: false,
    );

    final stateList = InfiniteListState(
      list: secondList,
      failed: false,
      loading: false,
    );

    final stateFailedLastRequest = InfiniteListState(
      list: firstList,
      failed: true,
      loading: false,
    );

    final stateLoading = InfiniteListState(
      list: firstList,
      failed: false,
      loading: true,
    );

    final stateDisabled = InfiniteListState(
      list: firstList,
      failed: false,
      loading: false,
      disabled: true,
    );

    expect(state.copyWith(list: secondListCopy), stateList);
    expect(state.copyWith(failed: true), stateFailedLastRequest);
    expect(state.copyWith(loading: true), stateLoading);
    expect(state.copyWith(disabled: true), stateDisabled);
  });
}
