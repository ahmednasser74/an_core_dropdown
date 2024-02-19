import 'package:an_core_ui/an_core_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'index.dart';
// import 'package:nasser_core_package/nasser_core_package.dart';

class DropdownView<T extends AppDropdownBaseModel<dynamic>> extends StatefulWidget {
  const DropdownView({
    required this.title,
    required this.selectedKey,
    required this.list,
    required this.onSelectedItem,
    this.dismissible = true,
    this.translate = false,
    this.listWithRightLabel = false,
    this.isLoadingMore = false,
    this.isLoading = false,
    this.scrollController,
    this.onSearchChange,
    this.initSearchText,
    this.isMultiSelect = false,
    this.multiSelectedItems,
    this.multiSelectInitValues,
    this.separateSelectedItems = false,
    this.onMultiSelectionChanged,
    this.isNavigatePop = true,
    Key? key,
  }) : super(key: key);
  final String title;
  final T? selectedKey;
  final bool dismissible;
  final List<T> list;
  final Function(T item) onSelectedItem;

  final bool listWithRightLabel;
  final bool isLoadingMore;
  final bool isLoading;

  final bool isNavigatePop;

  final ScrollController? scrollController;

  /// translate the text in list
  final bool translate;
  final Function(String value)? onSearchChange;
  final String? initSearchText;

  ///multi select
  final bool isMultiSelect;
  final List<MultiSelectItem<T>>? multiSelectedItems;
  final List<T>? multiSelectInitValues;
  final bool separateSelectedItems;
  final void Function(List<T>)? onMultiSelectionChanged;

  @override
  _DropdownViewState<T> createState() => _DropdownViewState<T>();
}

class _DropdownViewState<T extends AppDropdownBaseModel<dynamic>> extends State<DropdownView<T>> with MultiSelectActions<T> {
  int selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();
  List<T> _multiSelectedValues = <T>[];

  @override
  void initState() {
    if (widget.selectedKey != null) {
      selectedIndex = widget.list.indexOf(widget.selectedKey!);
    }
    searchController.text = widget.initSearchText ?? '';

    if (widget.isMultiSelect) _multiSelectedValues.addAll(widget.multiSelectInitValues!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        9.heightBox,
        _buildBottomSheetIndicator(),
        // if (widget.title != '') _buildBottomSheetTitle(widget.title),
        if (widget.onSearchChange != null) _buildSearchField(),
        Expanded(child: _buildListView()),
        if (widget.isLoadingMore) _buildLoadingMoreIndicator(),
      ],
    );
  }

  Widget _buildListView() {
    if (widget.isLoading) return const Center(child: CupertinoActivityIndicator());
    if ((widget.isMultiSelect && widget.multiSelectedItems != null && widget.multiSelectedItems!.isEmpty) || widget.list.isEmpty) {
      return Padding(padding: const EdgeInsets.all(12), child: Text('NoDataFound'.translate));
    }
    return StatefulBuilder(builder: (context, setState) {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 40),
        controller: widget.scrollController,
        itemCount: widget.isMultiSelect ? widget.multiSelectedItems?.length ?? 0 : widget.list.length,
        itemBuilder: (BuildContext context, int index) {
          if (widget.isMultiSelect) {
            return _buildMultiSelectListItem(widget.multiSelectedItems![index], setState);
          }
          return _buildListItem(widget.list[index].textDisplay, widget.list.length != index + 1, index, setState);
        },
      );
    });
  }

  Widget _buildListItem(String textDisplay, bool hidBottomBoarder, int index, setState) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
      child: InkWell(
        onTap: () {
          widget.onSelectedItem(widget.list[index]);
          setState(() => selectedIndex = index);
          if (widget.isNavigatePop == true) Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(.2) : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(child: Text(textDisplay, textAlign: TextAlign.center)),
              // if (widget.listWithRightLabel)
              CircleAvatar(
                backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                radius: 8.r,
                child: Icon(
                  Icons.check,
                  size: 10.r,
                  color: isSelected ? Colors.white : Colors.transparent,
                ),
              ),
              6.widthBox
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetIndicator() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Container(
          width: 90,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Color(0xFF2B2B2B)),
        ),
      ),
    );
  }

  /// Returns a CheckboxListTile
  Widget _buildMultiSelectListItem(MultiSelectItem<T> item, setState) {
    if (_multiSelectedValues.contains(item.value)) item.selected = true;
    return CheckboxListTile(
      checkColor: Colors.white,
      value: item.selected,
      activeColor: Theme.of(context).primaryColor,
      title: Text(
        item.value.textDisplay,
        style: TextStyle(color: item.selected ? Theme.of(context).primaryColor : Colors.black),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (bool? checked) {
        _multiSelectedValues = onItemCheckedChange(_multiSelectedValues, item.value, checked!);
        if (widget.onMultiSelectionChanged != null) widget.onMultiSelectionChanged!(_multiSelectedValues);
        checked ? item.selected = true : item.selected = false;
        // if (widget.separateSelectedItems) widget.items?.addAll(separateSelected(widget.items!));
        setState(() {});
      },
    );
  }

  Widget _buildSearchField() {
    return AppTextFieldWidget(
      controller: searchController,
      onChanged: (String? value) => widget.onSearchChange!(value ?? ''),
      prefixIcon: const Icon(Icons.search),
      hint: 'search'.translate,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      height: 46.h,
      suffixIcon: InkWell(
        onTap: () {
          widget.onSearchChange!('');
          searchController.clear();
        },
        child: const Icon(Icons.close),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      alignment: Alignment.center,
      height: 20.h,
      width: 20.w,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      child: CircularProgressIndicator(color: Theme.of(context).primaryColor, strokeWidth: 2.r),
    );
  }
}
