import 'package:meta/meta.dart';

@immutable
abstract class FiniteListState<T> {}

class LoadingFiniteListState<T> extends FiniteListState<T> {}

class LoadedFiniteListState<T> extends FiniteListState<T> {
  final List<T> list;

  LoadedFiniteListState({@required this.list});

  @override
  String toString() {
    return 'LoadedFiniteListState { list: $list }';
  }

  @override
  bool operator ==(other) =>
      other is LoadedFiniteListState<T> && other.list == list;

  @override
  int get hashCode => list.hashCode;
}

class ErrorFiniteListState<T> extends FiniteListState<T> {}
