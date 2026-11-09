import 'power_up.dart';

class Inventory {
  final List<PowerUp> _items = [];

  List<PowerUp> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get length => _items.length;

  void add(PowerUp p) => _items.add(p);

  bool remove(PowerUp p) => _items.remove(p);

  void clear() => _items.clear();
}