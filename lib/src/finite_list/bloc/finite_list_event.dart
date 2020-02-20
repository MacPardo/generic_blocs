import 'package:meta/meta.dart';
import 'package:generic_blocs/generic_blocs.dart';

@immutable
abstract class FiniteListEvent<T, Failure> {}

class LoadFiniteListEvent<T, Failure> extends FiniteListEvent<T, Failure> {
  final FiniteListSource<T, Failure> source;

  LoadFiniteListEvent({@required this.source});
}

class RefreshFiniteListEvent<T, Failure> extends FiniteListEvent<T, Failure> {}
