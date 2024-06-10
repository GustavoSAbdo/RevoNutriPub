import 'package:hive/hive.dart';

part 'hive_weight_record.g.dart';

@HiveType(typeId: 5)
class HiveWeightRecord extends HiveObject {
  @HiveField(0)
  double peso;

  @HiveField(1)
  DateTime data;

  @HiveField(2)
  String objetivo;

  HiveWeightRecord({
    required this.peso,
    required this.data,
    required this.objetivo,
  });
}
