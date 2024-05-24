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
  DateTime dataNascimento;

  @HiveField(3)
  double multiplicadorGord;

  @HiveField(4)
  double multiplicadorProt;

  @HiveField(5)
  int numRefeicoes;

  @HiveField(6)
  double peso;

  @HiveField(7)
  String nivelAtividade;

  @HiveField(8)
  String objetivo;

  @HiveField(9)
  int refeicaoPosTreino;

  @HiveField(10)
  double tmb;

  @HiveField(11)
  HiveMealGoalList? macrosRef;

  @HiveField(12)
  HiveMealGoal? macrosDiarios;

  @HiveField(13)
  String nome;

  @HiveField(14)
  String genero;

  @HiveField(15)
  DateTime? lastFeedbackDate;

  @HiveField(16)
  DateTime? lastObjectiveChange;

  HiveUser({
    required this.altura,
    required this.idade,
    required this.dataNascimento,
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
    required this.nome,
    required this.genero,
    this.lastFeedbackDate,
    this.lastObjectiveChange
  });
}
