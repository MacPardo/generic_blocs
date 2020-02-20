import 'package:meta/meta.dart';
import 'package:generic_blocs/generic_blocs.dart';

@immutable
abstract class InfiniteListEvent<T> {}

class LoadMoreInfiniteListEvent<T> extends InfiniteListEvent<T> {}

class ResetInfiniteListEvent<T> extends InfiniteListEvent<T> {}

class ChangeSourceInfiniteListEvent<T> extends InfiniteListEvent<T> {
  final InfiniteListSource source;

  ChangeSourceInfiniteListEvent(this.source);
}
