import 'package:core/src/cache/core/cache_model.dart';

abstract class CacheOperation<T extends CacheModel> {
  void add(T item);
  void remove(String id);
  void removeAll(List<String> ids);
  void addAll(List<T> items);
  void clear();

  T? get(String id);
  List<T> getAll();
}
