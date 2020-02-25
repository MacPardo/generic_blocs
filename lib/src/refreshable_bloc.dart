import 'package:flutter_bloc/flutter_bloc.dart';

abstract class RefreshableBloc<Event, State> extends Bloc<Event, State> {
  void refresh();
}
