import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../index.dart';
import 'index.dart';

@Injectable()
class AppDropdownBloc extends Bloc<AppDropdownEvent, AppDropdownState> {
  AppDropdownBloc() : super(AppDropdownInitialState()) {
    on<AppDropdownLoadEvent>(_loadList);
    on<AppDropdownLoadMoreEvent>(_loadMoreList);
  }

  List<AppDropdownBaseModel<dynamic>> list = <AppDropdownBaseModel<dynamic>>[];

  int page = 0;
  String? searchText;
  bool isLoadingMoreFinished = false;

  Future<void> _loadList(AppDropdownLoadEvent<AppDropdownBaseModel> event, Emitter<AppDropdownState> emit) async {
    page = 0;
    list.clear();
    emit(AppDropdownLoadingState());
    try {
      final AppDropDownRequestModel requestModel = AppDropDownRequestModel(page: page, search: searchText);
      final response = await event.caller(requestModel);
      // if (result.code == AppResultCode.success) {
      // list = result.fold(
      //   (l) => null,
      //   (r) => null,
      // )!;
      emit(AppDropdownReadyState<AppDropdownBaseModel>(dropdownList: response.results!));
      // }
    } catch (error) {
      emit(AppDropdownErrorState(error.toString()));
    }
  }

  Future<void> _loadMoreList(AppDropdownLoadMoreEvent<AppDropdownBaseModel> event, Emitter<AppDropdownState> emit) async {
    // page++;
    // emit(AppDropdownLoadingMoreState());
    // try {
    //   final AppDropDownRequestModel requestModel = AppDropDownRequestModel(page: page);
    //   final AppResponseListResult<AppDropdownBaseModel> result = await event.caller(requestModel);
    //   if (result.code == AppResultCode.success) {
    //     final List<AppDropdownBaseModel<dynamic>>? response = result.results;
    //     if (response == null || response.isEmpty) isLoadingMoreFinished = true;
    //     list.addAll(response!);
    //     emit(AppDropdownReadyState<AppDropdownBaseModel<dynamic>>(dropdownList: list, loadMoreList: response));
    //   } else {
    //     page--;
    //   }
    // } catch (error, trace) {
    //   page--;
    //   emit(AppDropdownErrorState(error.toString()));
    // }
  }
}
