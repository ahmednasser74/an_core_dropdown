import 'dart:async';
import 'package:an_core_ui/an_core_ui.dart';
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
      final result = await event.caller(requestModel);

      list = result.fold(
        (failure) {
          ToastHelper.showToast(msg: failure.message ?? 'somethingWentWrong'.translate);
          return <AppDropdownBaseModel>[];
        },
        (response) {
          emit(AppDropdownReadyState<AppDropdownBaseModel>(dropdownList: response.results!));
          return response.results!;
        },
      );
    } catch (error) {
      emit(AppDropdownErrorState(error.toString()));
    }
  }

  Future<void> _loadMoreList(AppDropdownLoadMoreEvent<AppDropdownBaseModel> event, Emitter<AppDropdownState> emit) async {
    page++;
    emit(AppDropdownLoadingMoreState());
    try {
      final AppDropDownRequestModel requestModel = AppDropDownRequestModel(page: page);
      final result = await event.caller(requestModel);
      result.fold(
        (l) {
          ToastHelper.showToast(msg: l.message ?? 'somethingWentWrong'.translate);
        },
        (r) {
          if (r.results!.isEmpty) {
            isLoadingMoreFinished = true;
          } else {
            list.addAll(r.results!);
            emit(AppDropdownReadyState<AppDropdownBaseModel>(dropdownList: list, loadMoreList: r.results!));
          }
        },
      );
      // if (result.isSuccess) {
      //   final List<AppDropdownBaseModel<dynamic>>? response = result.results;
      //   if (response == null || response.isEmpty) isLoadingMoreFinished = true;
      //   list.addAll(response!);
      //   emit(AppDropdownReadyState<AppDropdownBaseModel<dynamic>>(dropdownList: list, loadMoreList: response));
      // } else {
      //   page--;
      // }
    } catch (error, trace) {
      page--;
      emit(AppDropdownErrorState(error.toString()));
    }
  }
}
