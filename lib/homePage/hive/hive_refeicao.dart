import 'package:hive/hive.dart';
import 'package:complete/homePage/hive/hive_food_item.dart'; 

part 'hive_refeicao.g.dart'; 

@HiveType(typeId: 2)
class HiveRefeicao {
  @HiveField(0)
  List<HiveFoodItem> items;

 @HiveField(1)
  bool modified; 

  HiveRefeicao({List<HiveFoodItem>? items, this.modified = false})
      : items = items ?? [];
}