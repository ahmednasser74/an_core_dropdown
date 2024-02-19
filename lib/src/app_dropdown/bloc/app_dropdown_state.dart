import 'package:equatable/equatable.dart';

import '../index.dart';

abstract class AppDropdownState extends Equatable {
  @override
  List<Object> get props => <Object>[];
}

// Initial
class AppDropdownInitialState extends AppDropdownState {}

// Loading
class AppDropdownLoadingState extends AppDropdownState {}

class AppDropdownLoadingMoreState extends AppDropdownState {}

// Ready
class AppDropdownReadyState<T extends AppDropdownBaseModel> extends AppDropdownState {
  AppDropdownReadyState({
    required this.dropdownList,
    this.loadMoreList,
  });
  final List<T> dropdownList;
  final List<T>? loadMoreList;

  @override
  List<Object> get props => <Object>[dropdownList.length];
}

// Error
class AppDropdownErrorState extends AppDropdownState {
  AppDropdownErrorState(this.errorMessage);

  final String errorMessage;

  @override
  List<Object> get props => <Object>[errorMessage];
}
