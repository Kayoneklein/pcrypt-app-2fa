import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pcrypt/home/bloc/tab.dart';

@immutable
abstract class TabEvent extends Equatable {
  const TabEvent();
}

class UpdateTab extends TabEvent {
  const UpdateTab(this.tab);

  final AppTab tab;

  @override
  List<Object> get props => [tab];
}
