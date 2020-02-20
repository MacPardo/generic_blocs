import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class InfiniteListState<T> extends Equatable {
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
  List<Object> get props => [list, loading, failed, disabled];
}
