// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:hive/hive.dart';
// import 'package:complete/hive/hive_user.dart';
// import 'package:complete/hive/hive_weight_record.dart';
// import 'package:intl/intl.dart';

// class WeightChartPage extends StatefulWidget {
//   final String userId;

//   WeightChartPage({required this.userId});

//   @override
//   _WeightChartPageState createState() => _WeightChartPageState();
// }

// class _WeightChartPageState extends State<WeightChartPage> {
//   List<FlSpot> _weightData = [];
//   bool _loading = true;
//   double _minY = double.infinity;
//   double _maxY = double.negativeInfinity;
//   double _minX = double.infinity;
//   double _maxX = double.negativeInfinity;

//   @override
//   void initState() {
//     super.initState();
//     _loadWeightData();
//   }

//   Future<void> _loadWeightData() async {
//     final userBox = Hive.box<HiveUser>('userBox');
//     HiveUser? hiveUser = userBox.get(widget.userId);

//     if (hiveUser != null) {
//       List<HiveWeightRecord> weightRecords = hiveUser.listaPeso;

//       List<FlSpot> spots = weightRecords
//           .map((record) {
//             double xValue = record.data.millisecondsSinceEpoch.toDouble();
//             double yValue = record.peso;

//             // Atualiza os valores mínimos e máximos
//             if (xValue < _minX) _minX = xValue;
//             if (xValue > _maxX) _maxX = xValue;
//             if (yValue < _minY) _minY = yValue;
//             if (yValue > _maxY) _maxY = yValue;

//             return FlSpot(xValue, yValue);
//           })
//           .toList();

//       setState(() {
//         _weightData = spots;
//         _minY = _minY.floorToDouble() - 1;
//         _maxY = _maxY.ceilToDouble() + 1;
//         _loading = false;
//       });
//     } else {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   String _formatDate(double value) {
//     DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
//     return DateFormat('dd/MM').format(date);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Weight Chart')),
//       body: _loading
//           ? Center(child: CircularProgressIndicator())
//           : _weightData.isEmpty
//               ? Center(child: Text('No weight data available'))
//               : Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Container(
//                       height: MediaQuery.of(context).size.height * 0.5,
//                       width: MediaQuery.of(context).size.width * 0.9,
//                       child: LineChart(
//                         LineChartData(
//                           gridData: FlGridData(show: true),
//                           titlesData: FlTitlesData(
//                             bottomTitles: AxisTitles(
//                               axisNameWidget: Text('Data', style: TextStyle(fontSize: 12)),
//                               sideTitles: SideTitles(
//                                 showTitles: true,
//                                 getTitlesWidget: (value, meta) {
//                                   return Padding(
//                                     padding: const EdgeInsets.only(top: 8.0),
//                                     child: Text(
//                                       _formatDate(value),
//                                       style: TextStyle(fontSize: 10),
//                                     ),
//                                   );
//                                 },
//                                 interval: (_maxX - _minX) / (_weightData.length - 1), // Ajuste o intervalo conforme necessário
//                               ),
//                             ),
//                             leftTitles: AxisTitles(
//                               axisNameWidget: Text('Peso (kg)', style: TextStyle(fontSize: 12)),
//                               sideTitles: SideTitles(
//                                 showTitles: true,
//                                 interval: 1, // Intervalo de 1 kg
//                                 getTitlesWidget: (value, meta) {
//                                   if (value < _minY || value > _maxY) {
//                                     return Container();
//                                   }
//                                   return Padding(
//                                     padding: const EdgeInsets.only(left: 8.0),
//                                     child: Text(
//                                       value.toInt().toString(),
//                                       style: TextStyle(fontSize: 10),
//                                       textAlign: TextAlign.left,
//                                     ),
//                                   );
//                                 },
//                                 reservedSize: 40, // Reserva espaço para os títulos
//                               ),
//                             ),
//                             rightTitles: AxisTitles(
//                               sideTitles: SideTitles(showTitles: false),
//                             ),
//                             topTitles: AxisTitles(
//                               sideTitles: SideTitles(showTitles: false),
//                             ),
//                           ),
//                           borderData: FlBorderData(
//                             show: true,
//                             border: Border.all(color: Colors.black, width: 1),
//                           ),
//                           minX: _minX,
//                           maxX: _maxX,
//                           minY: _minY,
//                           maxY: _maxY,
//                           lineBarsData: [
//                             LineChartBarData(
//                               spots: _weightData,
//                               isCurved: true,
//                               barWidth: 2,
//                               color: Colors.blue,
//                               belowBarData: BarAreaData(
//                                 show: true,
//                                 color: Colors.blue.withOpacity(0.3),
//                               ),
//                             ),
//                           ],
//                           extraLinesData: ExtraLinesData(horizontalLines: [
//                             HorizontalLine(
//                               y: _maxY,
//                               color: Colors.transparent,
//                               strokeWidth: 0,
//                               label: HorizontalLineLabel(
//                                 show: true,
//                                 labelResolver: (value) => '',
//                                 alignment: Alignment.topRight,
//                               ),
//                             ),
//                           ]),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//     );
//   }
// }
