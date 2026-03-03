import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:pcrypt/home/bloc/tab.dart';

class TabBloc extends Bloc<TabEvent, AppTab> {
  TabBloc() : super(AppTab.passwords){
    on<TabEvent>((event, emit) {
    if (event is UpdateTab) {
        emit(event.tab);
    }
    });
  }

  /*@override
  Stream<AppTab> mapEventToState(
    TabEvent event,
  ) async* {
    if (event is UpdateTab) {
      yield event.tab;
    }
  }*/
}
