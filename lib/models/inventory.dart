import 'power_up.dart';

class Inventory {
  static const int maxCapacity = 6;

  final List<PowerUp> _items = [];

  List<PowerUp> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get length => _items.length;

  bool add(PowerUp p) {
    if (_items.length >= maxCapacity) return false;
    _items.add(p);
    return true;
  }

  bool remove(PowerUp p) => _items.remove(p);

  void clear() => _items.clear();
}