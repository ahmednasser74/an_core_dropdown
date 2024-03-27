import 'package:an_core_network/an_core_network.dart';
import 'package:dartz/dartz.dart';

import 'app_drop_down_request_model.dart';

/// call backFunction
// typedef AppDropDownCallBack<T extends AppDropdownBaseModel<T>> = Future<Either<Failure, AppResponseListResult<T>>> Function(AppDropDownRequestModel requestModel);
typedef AppDropDownCallBack<T extends AppDropdownBaseModel<T>> = Future<Either<Failure, AppResponseListResult<T>>> Function(AppDropDownRequestModel requestModel);

class AppDropdownController<T extends AppDropdownBaseModel<T>> {
  AppDropdownController();

  T? _value;

  List<T?>? values;
  Function? refreshList;

  T? get value => _value;

  set value(T? value) {
    _value = value;
    if (setValue != null) setValue!(value);
  }

  Function(T?)? setValue;
  Function(List<T>? list)? changeList;
}

abstract class AppDropdownBaseModel<T> extends BaseResponse<T> {
  String get textDisplay;
}

class AppDropdownItem extends AppDropdownBaseModel<AppDropdownItem> {
  AppDropdownItem(this.text, {this.value});

  final String text;
  final String? value;

  @override
  String get textDisplay => text;

  @override
  List<Object> get props => <Object>[text, value ?? ''];

  @override
  AppDropdownItem fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}
