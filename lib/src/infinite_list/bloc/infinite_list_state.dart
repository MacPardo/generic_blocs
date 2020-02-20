import 'package:meta/meta.dart';

@immutable
class InfiniteListState<T> {
  final List<T> list;
  final bool loading;
  final bool failed;
  final bool disabled;

  InfiniteListState({
    @required this.list,
    this.loading = false,
    this.failed = false,
    this.disabled = false,
  }) : assert(list != null);

  InfiniteListState<T> copyWith({
    List<T> list,
    bool loading,
    bool failed,
    bool disabled,
  }) =>
      InfiniteListState<T>(
        list: list ?? this.list,
        loading: loading ?? this.loading,
        failed: failed ?? this.failed,
        disabled: disabled ?? this.disabled,
      );

  @override
  String toString() {
    return 'InfiniteListState { list: $list, loading: $loading, failed: $failed, disabled: $disabled }';
  }

  @override
  bool operator ==(other) =>
      other is InfiniteListState<T> &&
      other.list == list &&
      other.loading == loading &&
      other.failed == failed &&
      other.disabled == disabled;

  @override
  int get hashCode =>
      list.hashCode ^ loading.hashCode ^ failed.hashCode ^ disabled.hashCode;
}
