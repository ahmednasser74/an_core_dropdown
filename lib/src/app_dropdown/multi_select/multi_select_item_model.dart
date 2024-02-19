/// A model class used to represent a selectable item.
class MultiSelectItem<T> {
  MultiSelectItem(this.value, this.label);

  final T value;
  final String label;
  bool selected = false;
}
