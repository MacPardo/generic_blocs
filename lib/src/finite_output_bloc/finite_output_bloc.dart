import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generic_blocs/generic_blocs.dart';

abstract class FiniteOutputBloc<Event, T>
    extends Bloc<Event, FiniteListState<T>> {
  void refresh();
}
