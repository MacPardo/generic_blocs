import 'package:meta/meta.dart';
import 'package:generic_blocs/generic_blocs.dart';

@immutable
abstract class InfiniteListEvent<T, Failure> {}

class LoadMoreInfiniteListEvent<T, Failure>
    extends InfiniteListEvent<T, Failure> {}

class ResetInfiniteListEvent<T, Failure> extends InfiniteListEvent<T, Failure> {
}

class ChangeSourceInfiniteListEvent<T, Failure>
    extends InfiniteListEvent<T, Failure> {
  final InfiniteListSource<T, Failure> source;

  ChangeSourceInfiniteListEvent(this.source);
}
