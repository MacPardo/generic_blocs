import 'package:generic_blocs/src/double_filter/bloc/double_filter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:generic_blocs/generic_blocs.dart';

@immutable
abstract class DoubleFilterEvent<X, Y, R> {}

class SyncDoubleFilterEvent<X, Y, R> extends DoubleFilterEvent<X, Y, R> {
  final FiniteListState<X> stateX;
  final FiniteListState<Y> stateY;

  SyncDoubleFilterEvent({
    @required this.stateX,
    @required this.stateY,
  });
}

class ChangeDoubleFilterEvent<X, Y, R> extends DoubleFilterEvent<X, Y, R> {
  final DoubleFilter<X, Y, R> filter;

  ChangeDoubleFilterEvent({@required this.filter});
}
