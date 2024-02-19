import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../index.dart';

@immutable
abstract class AppDropdownEvent extends Equatable {
  @override
  List<dynamic> get props => <dynamic>[];
}

// Initiate
class AppDropdownInitiateEvent extends AppDropdownEvent {}

// Logout
class AppDropdownLoadEvent<T extends AppDropdownBaseModel<T>> extends AppDropdownEvent {
  AppDropdownLoadEvent({required this.caller});
  final AppDropDownCallBack<T> caller;

  @override
  List<dynamic> get props => <dynamic>[caller];
}

class AppDropdownLoadMoreEvent<T extends AppDropdownBaseModel<T>> extends AppDropdownEvent {
  AppDropdownLoadMoreEvent({required this.caller});

  final AppDropDownCallBack<T> caller;

  @override
  List<dynamic> get props => <dynamic>[caller];
}
