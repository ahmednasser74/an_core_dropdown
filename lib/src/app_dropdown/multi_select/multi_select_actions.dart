import 'package:flutter/material.dart';

import 'multi_select_item_model.dart';

mixin MultiSelectActions<T> {
  List<T> onItemCheckedChange(List<T> selectedValues, T itemValue, bool checked) {
    if (checked) {
      selectedValues.add(itemValue);
    } else {
      selectedValues.remove(itemValue);
    }
    return selectedValues;
  }

  void onCancelTap(BuildContext ctx, List<T> initiallySelectedValues) {
    Navigator.pop(ctx, initiallySelectedValues);
  }

  void onConfirmTap(BuildContext ctx, List<T> selectedValues, Function(List<T>)? onConfirm) {
    Navigator.pop(ctx, selectedValues);
    if (onConfirm != null) {
      onConfirm(selectedValues);
    }
  }

  List<MultiSelectItem<T>> separateSelected(List<MultiSelectItem<T>> list) {
    List<MultiSelectItem<T>> _selectedItems = [];
    List<MultiSelectItem<T>> _nonSelectedItems = [];

    _nonSelectedItems.addAll(list.where((element) => !element.selected));
    _nonSelectedItems.sort((a, b) => a.label.compareTo(b.label));
    _selectedItems.addAll(list.where((element) => element.selected));
    _selectedItems.sort((a, b) => a.label.compareTo(b.label));

    return [..._selectedItems, ..._nonSelectedItems];
  }
}
