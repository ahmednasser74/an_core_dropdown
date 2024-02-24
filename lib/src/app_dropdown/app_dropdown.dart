import 'package:an_core_dropdown/src/dependencies/index.dart';
import 'package:an_core_ui/an_core_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'bloc/index.dart';
import 'multi_select/multi_select_item_model.dart';
import '../app_dropdown/models/index.dart';
import 'drop_down_view.dart';

/*
    - How to use AppDropdown

    Widget _buildAppDropdown() {
      List<String> texts = [
        'Option1',
        'Option2',
        'Option3',
      ];
      AppDropdownController appDropdownController = AppDropdownController<AppDropdownItem>();
      return AppDropdown(
        labelText: 'Test',
        list: texts.map((e) => AppDropdownItem(e)).toList(),
        controller: appDropdownController,
      );
    }
 */

class AppDropdown<T extends AppDropdownBaseModel<T>> extends StatefulWidget {
  AppDropdown({
    required this.controller,
    required this.list,
    this.multiSelectItems,
    this.scrollController,
    this.focusNode,
    this.labelText,
    this.validator,
    this.hintText,
    this.loading = false,
    this.onItemSelected,
    this.autoFocus = false,
    this.listWithCheckBox = false,
    this.readOnly = false,
    this.translate = true,
    this.initDisplayText,
    this.appDropdownBloc,
    this.hasInitValue = true,
    this.hasSearch = false,
    this.isMultiSelect = false,
    this.isOptional = false,
    this.caller,
    this.onMultiSelectionChanged,
    this.multiSelectInitValues,
  });

  final FocusNode? focusNode;
  final String? labelText;
  String? hintText;
  final bool autoFocus;
  final FormFieldValidator<String>? validator;
  final Function(T)? onItemSelected;
  final AppDropdownController<T> controller;
  final bool loading;
  final AppDropdownBloc? appDropdownBloc;
  final bool listWithCheckBox;
  final bool readOnly;
  List<T>? list;
  final String? initDisplayText;
  final bool hasInitValue;
  final bool isMultiSelect;

  /// translate the text in list
  final bool translate;
  final ScrollController? scrollController;
  final AppDropDownCallBack<T>? caller;
  final bool hasSearch;
  final List<MultiSelectItem<T>>? multiSelectItems;
  final void Function(List<T>)? onMultiSelectionChanged;
  List<T>? multiSelectInitValues;
  final bool isOptional;

  @override
  _AppDropdownState<T> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T extends AppDropdownBaseModel<T>> extends State<AppDropdown<T>> {
  TextEditingController dropDownFieldController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initDisplayText != null) dropDownFieldController.text = widget.initDisplayText!;
      if (widget.initDisplayText == null && widget.list != null && widget.list!.isNotEmpty && widget.hasInitValue) {
        dropDownFieldController.text = widget.list!.first.textDisplay;
      }
    });
    widget.controller.setValue = setValue;
    widget.controller.changeList = changeList;
    super.initState();
  }

  void setValue(T? value) {
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if (widget.onItemSelected != null && value != null && widget.controller.value != value) widget.onItemSelected!(value);
      if (mounted) dropDownFieldController.text = value?.textDisplay ?? '';
      if (value != null && widget.controller.value != value) widget.controller.value = value;
    });
  }

  void changeList(List<T>? changedList) {
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if (mounted) {
        setState(() {
          widget.list = changedList;
          if (changedList != null && changedList.isNotEmpty && widget.hasInitValue) {
            widget.controller.value = changedList.first;
          } else {
            dropDownFieldController.clear();
          }
        });
        if (widget.initDisplayText != null) dropDownFieldController.text = widget.initDisplayText!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    dropDownFieldController.text = widget.controller.value?.textDisplay ?? widget.initDisplayText ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppTextFieldWidget(
          onTap: widget.readOnly ? null : () => openDropdownMenu(context),
          labelText: widget.labelText,
          focusNode: widget.focusNode,
          autoFocus: widget.autoFocus,
          maxLines: 1,
          fontSize: 12.sp,
          hint: widget.hintText,
          dispose: false,
          readOnly: true,
          validator: widget.validator,
          controller: dropDownFieldController,
          suffixIcon: buildISuffixIcon(),
          // padding: EdgeInsets.symmetric(horizontal: 12.w),
        ),
        if (widget.list == null || widget.list!.isEmpty) AppText('${widget.labelText} ${'listIsEmpty'.translate}', color: Colors.red, size: 10.sp),
      ],
    );
  }

  Widget buildISuffixIcon() {
    if (widget.loading) return const CupertinoActivityIndicator();
    if (widget.isOptional && widget.controller.value != null) {
      return IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          dropDownFieldController.clear();
          widget.controller.value = null;
          setState(() {});
        },
      );
    }
    return const Icon(Icons.keyboard_arrow_down_outlined, size: 24);
  }

  void openDropdownMenu(BuildContext context) {
    if (widget.list == null || widget.list!.isEmpty) return;
    context.dismissKeyboard();
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AppContainer(
          paddingBottom: MediaQuery.of(context).viewInsets.bottom,
          color: Colors.white,
          marginAll: 18.sp,
          borderRadius: 12.r,
          child: BlocProvider<AppDropdownBloc>.value(
            value: widget.appDropdownBloc ?? dropDownPackageGetIt<AppDropdownBloc>(),
            child: BlocConsumer<AppDropdownBloc, AppDropdownState>(
              listener: (BuildContext context, AppDropdownState state) {
                WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
                  dropDownFieldController.text = widget.appDropdownBloc!.searchText ?? '';
                });
                if (state is AppDropdownReadyState) {
                  if (widget.controller.changeList != null) widget.controller.changeList!(state.dropdownList as List<T>);
                  widget.list = state.dropdownList as List<T>;
                  if (widget.isMultiSelect && state.loadMoreList != null && state.loadMoreList!.isNotEmpty) {
                    for (final T item in state.loadMoreList! as List<T>) {
                      widget.multiSelectItems!.add(MultiSelectItem<T>(item, item.textDisplay));
                    }
                  }
                }
              },
              builder: (_, AppDropdownState state) {
                return SizedBox(
                  height: _calculateViewHeight(context, widget.list?.length ?? 2),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownView<T>(
                        isMultiSelect: widget.isMultiSelect,
                        multiSelectInitValues: widget.multiSelectInitValues,
                        multiSelectedItems: widget.multiSelectItems,
                        onMultiSelectionChanged: (list) => onMultiSelectionChanged(list, setState),
                        title: widget.labelText ?? widget.hintText ?? '',
                        selectedKey: widget.controller.value,
                        list: widget.list!,
                        scrollController: widget.scrollController,
                        isLoadingMore: state is AppDropdownLoadingMoreState,
                        isLoading: state is AppDropdownLoadingState,
                        onSelectedItem: (T item) => onSelectedItem(item, setState),
                        initSearchText: widget.appDropdownBloc?.searchText ?? '',
                        onSearchChange: widget.hasSearch ? onSearchChange : null,
                        translate: widget.translate,
                        listWithRightLabel: widget.listWithCheckBox,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void onMultiSelectionChanged(List<T> list, setState) {
    if (list.isNotEmpty) {
      final String listCount = list.length > 1 ? '(+${(list.length - 1).toString()})' : '';
      if (list.isNotEmpty) dropDownFieldController.text = '${list.first.textDisplay} $listCount';
    } else {
      dropDownFieldController.text = '';
    }
    setState(() {});
    if (widget.onMultiSelectionChanged != null) widget.onMultiSelectionChanged!(list);
    widget.controller.values = list;
  }

  void onSelectedItem(T item, setState) {
    if (widget.isOptional) setState(() {});
    if (widget.onItemSelected != null) {
      widget.onItemSelected!(item);
    }
    widget.controller.value = item;
    dropDownFieldController.text = item.textDisplay;
  }

  void onSearchChange(String value) {
    if (widget.appDropdownBloc == null) return;
    widget.appDropdownBloc!.searchText = value;
    if (widget.caller != null) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => widget.appDropdownBloc!.add(AppDropdownLoadEvent<T>(caller: widget.caller!)),
      );
    }
  }

  double _calculateViewHeight(BuildContext context, int listLength) {
    final double maxHeight = MediaQuery.of(context).size.height - 170.h;
    final double searchFieldHeight = widget.hasSearch ? 46.h : 0;
    final double extraHeight = 140.h;
    final double itemHeight = 12.h;
    final double height = extraHeight + (listLength * itemHeight) + searchFieldHeight;

    if (maxHeight < height) {
      return maxHeight;
    }
    return height;
  }
}
