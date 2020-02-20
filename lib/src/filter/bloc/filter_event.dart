import 'package:meta/meta.dart';
import 'package:generic_blocs/generic_blocs.dart';

@immutable
abstract class FilterEvent<T> {}

class SyncWithListFilterEvent<T> extends FilterEvent<T> {
  final FiniteListState finiteListState;

  SyncWithListFilterEvent({@required this.finiteListState});
}

class ChangeFilterEvent<T> extends FilterEvent<T> {
  final ListFilter<T> filter;

  ChangeFilterEvent({@required this.filter});
}
