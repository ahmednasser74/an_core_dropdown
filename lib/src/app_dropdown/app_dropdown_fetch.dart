import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../dependencies/index.dart';
import 'bloc/index.dart';
import 'index.dart';

/*
    - How to use AppDropDownFetch

    Widget _buildAppDropDownFetch() {
      AppDropdownController appDropdownController = AppDropdownController<AppDropdownItem>();
      return AppDropDownFetch<AppDropdownItem>(
        title: 'Test1',
        caller: widget._settingsBloc.dropdownRepo.getAll,
        controller: appDropdownController,
      );
    }
 */

class AppDropDownFetch<T extends AppDropdownBaseModel<T>> extends StatefulWidget {
  const AppDropDownFetch({
    Key? key,
    required this.title,
    required this.caller,
    required this.controller,
    this.onItemSelected,
    this.validator,
    this.isMultiSelect = false,
    this.listWithCheckBox = false,
    this.onAutomationSelectFirstItem,
    this.readOnly = false,
    this.isPaginated = false,
    this.refreshList = false,
    this.hasInitValue = true,
    this.hasSearch = true,
    this.isOptional = false,
    this.initDisplayText,
    this.onMultiSelectionChanged,
    this.multiSelectInitValues,
  }) : super(key: key);

  final String title;
  final AppDropDownCallBack<T> caller;
  final AppDropdownController<T> controller;
  final FormFieldValidator<String>? validator;
  final bool isMultiSelect;
  final Function(T)? onItemSelected;
  final bool listWithCheckBox;
  final Function(T)? onAutomationSelectFirstItem;
  final bool readOnly;
  final bool isPaginated;
  final bool hasInitValue;
  final bool refreshList;
  final bool hasSearch;
  final String? initDisplayText;
  final void Function(List<T>)? onMultiSelectionChanged;
  final List<T>? multiSelectInitValues;
  final bool isOptional;

  @override
  AppDropDownFetchState<T> createState() => AppDropDownFetchState<T>();
}

class AppDropDownFetchState<T extends AppDropdownBaseModel<T>> extends State<AppDropDownFetch<T>> {
  final AppDropdownBloc _appDropdownBloc = dropDownPackageGetIt<AppDropdownBloc>();
  List<T>? list;
  final ScrollController scrollController = ScrollController();
  final List<MultiSelectItem<T>> multiSelectItems = [];

  @override
  void initState() {
    _appDropdownBloc.add(AppDropdownLoadEvent<T>(caller: widget.caller));
    _loadMoreScrollListener();
    super.initState();
  }

  // void refreshList() => _appDropdownBloc.add(AppDropdownLoadEvent<T>(caller: widget.caller));

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppDropdownBloc>(
      create: (_) => _appDropdownBloc,
      child: BlocConsumer<AppDropdownBloc, AppDropdownState>(
        listener: _blocListener,
        builder: (BuildContext context, AppDropdownState state) {
          bool loading = false;
          if (state is AppDropdownLoadingState) {
            loading = true;
          }
          return AppDropdown<T>(
            labelText: widget.title,
            list: list,
            appDropdownBloc: _appDropdownBloc,
            loading: loading,
            validator: widget.validator,
            controller: widget.controller,
            onItemSelected: widget.onItemSelected,
            listWithCheckBox: widget.listWithCheckBox,
            readOnly: widget.readOnly,
            scrollController: scrollController,
            initDisplayText: widget.initDisplayText,
            hasInitValue: widget.hasInitValue,
            caller: widget.caller,
            hasSearch: widget.hasSearch,
            isMultiSelect: widget.isMultiSelect,
            multiSelectItems: multiSelectItems,
            onMultiSelectionChanged: widget.onMultiSelectionChanged,
            multiSelectInitValues: widget.multiSelectInitValues,
            isOptional: widget.isOptional,
          );
        },
      ),
    );
  }

  void _blocListener(BuildContext context, AppDropdownState state) {
    if (state is AppDropdownReadyState<AppDropdownBaseModel<dynamic>>) {
      final List<T>? newList = state.dropdownList as List<T>?;
      if (widget.controller.changeList != null) {
        widget.controller.changeList!(newList);
      }
      list = newList;
      if (widget.isMultiSelect && state.loadMoreList == null) {
        multiSelectItems.clear();
        for (final T item in list!) {
          multiSelectItems.add(MultiSelectItem<T>(item, item.textDisplay));
        }
      }

      if (list != null && list!.isNotEmpty && widget.hasInitValue) {
        widget.controller.value = list!.first;
        if (widget.onAutomationSelectFirstItem != null) {
          widget.onAutomationSelectFirstItem!(list!.first);
        }
      }
    }
  }

  void _loadMoreScrollListener() {
    if (widget.isPaginated) {
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !_appDropdownBloc.isLoadingMoreFinished) {
          _appDropdownBloc.add(AppDropdownLoadMoreEvent<T>(caller: widget.caller));
        }
      });
    }
  }
}
