import 'package:URL_launcher/models/item.dart';
import 'package:hive/hive.dart';

class DbProvider {
  var _box = Hive.box("URLBox");

  Future<void> addOrUpdateItem({required Item item, int? index}) async {
    index == null
        ? await _box.add(
            Item(title: item.title, url: item.url),
          )
        : await _box.putAt(
            index,
            Item(title: item.title, url: item.url),
          );
  }

  Future<void> deleteItem({required int index}) async {
    _box.deleteAt(index);
  }

  Stream<BoxEvent> get itemsStream => _box.watch();

  List get items => _box.values.toList();
}
