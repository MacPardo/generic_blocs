import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class FiniteListState<T> extends Equatable {}

class LoadingFiniteListState<T> extends FiniteListState<T> {
  @override
  List<Object> get props => [];
}

class LoadedFiniteListState<T> extends FiniteListState<T> {
  final List<T> list;

  LoadedFiniteListState({@required this.list});

  @override
  String toString() {
    return 'LoadedFiniteListState { list: $list }';
  }

  @override
  List<Object> get props => [list];
}

class ErrorFiniteListState<T> extends FiniteListState<T> {
  @override
  List<Object> get props => [];
}
