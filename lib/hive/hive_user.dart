import 'package:hive/hive.dart';
import 'package:complete/hive/hive_meal_goal.dart';
import 'package:complete/hive/hive_meal_goal_list.dart';


part 'hive_user.g.dart'; 

@HiveType(typeId: 4)
class HiveUser extends HiveObject {
  @HiveField(0)
  double altura; 

  @HiveField(1)
  int idade; 

  @HiveField(2)
  double multiplicadorGord; 

  @HiveField(3)
  double multiplicadorProt; 

  @HiveField(4)
  int numRefeicoes; 

  @HiveField(5)
  double peso; 

  @HiveField(6)
  String nivelAtividade; 

  @HiveField(7)
  String objetivo; 

  @HiveField(8)
  int refeicaoPosTreino; 

  @HiveField(9)
  double tmb; 

  @HiveField(10)
  HiveMealGoalList? macrosRef;

  @HiveField(11)
  HiveMealGoal? macrosDiarios;

  HiveUser({
    required this.altura,
    required this.idade,
    required this.multiplicadorGord,
    required this.multiplicadorProt,
    required this.numRefeicoes,
    required this.peso,
    required this.nivelAtividade,
    required this.objetivo,
    required this.refeicaoPosTreino,
    required this.tmb,
    this.macrosRef,
    this.macrosDiarios,
  });
}
