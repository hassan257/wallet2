import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wallet2/src/widgets/cuentas.dart';

import '../../locator.dart';
import '../providers/providers.dart';
import '../services/navigation_service.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    Query<Map<String, dynamic>> stream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('moves');
    final Timestamp fechaInicial =
        Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month));
    final Timestamp fechaFinal = Timestamp.fromDate(
        DateTime(DateTime.now().year, DateTime.now().month + 1));
    // Query<Map<String, dynamic>> streamBarChart = stream.where('fecha',
    //     isGreaterThanOrEqualTo: Timestamp.fromDate(
    //         DateTime(DateTime.now().year, DateTime.now().month - 5)));
    // streamBarChart = streamBarChart.where('fecha',
    //     isLessThan: Timestamp.fromDate(
    //         DateTime(DateTime.now().year, DateTime.now().month + 1)));
    stream = stream.where('fecha', isGreaterThanOrEqualTo: fechaInicial);
    stream = stream.where('fecha', isLessThan: fechaFinal);
    Query<Map<String, dynamic>> streamPieChart =
        stream.where('tipo', isEqualTo: 'GASTO');
    return SingleChildScrollView(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            // color: Colors.red,
            padding: const EdgeInsets.all(8),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                _BotonVersion(),
                SizedBox(
                  width: 20,
                ),
                _BotonLogout()
              ],
            ),
          ),
          _TarjetaTotal(stream: stream),
          const _Espacio30(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _GraficaCircular(streamPieChart: streamPieChart),
          ),
          const _Espacio30(),
          // _GraficaBarra(streamBarChart: streamBarChart)
        ],
      ),
    );
  }
}

class _BotonLogout extends StatelessWidget {
  const _BotonLogout({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        BottomNavigationProvider bottomNavigationProvider =
            Provider.of<BottomNavigationProvider>(context, listen: false);
        bottomNavigationProvider.isLog = false;
        locator<NavigationService>().navigateTo('/login');
      },
      child: const Icon(
        Icons.logout_rounded,
        size: 40,
        color: Colors.pinkAccent,
      ),
    );
  }
}

class _BotonVersion extends StatelessWidget {
  const _BotonVersion({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          'Versión 1.2.0',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserratAlternates(),
        )));
      },
      child: const Icon(
        Icons.info,
        size: 40,
        color: Colors.pinkAccent,
      ),
    );
  }
}

// ignore: unused_element
class _GraficaBarra extends StatelessWidget {
  const _GraficaBarra({
    Key? key,
    required this.streamBarChart,
  }) : super(key: key);

  final Query<Map<String, dynamic>> streamBarChart;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: StreamBuilder(
        stream: streamBarChart.snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            final List<QueryDocumentSnapshot<Map<String, dynamic>>> items =
                snapshot.data!.docs;
            List<Map<String, dynamic>> map = [];
            for (var i = DateTime.now().month - 5;
                i <= DateTime.now().month;
                i++) {
              map.add({
                'month': i,
                'cantidad_gasto': 0.0,
                'cantidad_ingreso': 0.0,
              });
            }
            for (var item in items) {
              // bool flag = false;
              Timestamp fecha = item['fecha'];
              for (var m in map) {
                if (m['month'] == fecha.toDate().month) {
                  // flag = true;
                  if (item['tipo'] == 'GASTO') {
                    m['cantidad_gasto'] += double.parse(item['cantidad']);
                  } else {
                    m['cantidad_ingreso'] += double.parse(item['cantidad']);
                  }
                }
              }
            }

            final barGroup = map.map((m) {
              return makeGroupData(
                  m['month'] - 1, m['cantidad_ingreso'], m['cantidad_gasto']);
            }).toList();
            return BarChart(BarChartData(
              barGroups: barGroup,
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: bottomTitles,
                    reservedSize: 42,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: leftTitles,
                  ),
                ),
              ),
            ));
          }
          List<Map<String, dynamic>> map = [];
          for (var i = DateTime.now().month - 5;
              i <= DateTime.now().month;
              i++) {
            map.add({
              'month': i,
              'cantidad_gasto': 0.0,
              'cantidad_ingreso': 0.0,
            });
          }
          final barGroup = map.map((m) {
            return makeGroupData(
                m['month'] - 1, m['cantidad_ingreso'], m['cantidad_gasto']);
          }).toList();
          return BarChart(BarChartData(
            barGroups: barGroup,
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: bottomTitles,
                  reservedSize: 42,
                ),
              ),
              // leftTitles: AxisTitles(
              //   sideTitles: SideTitles(
              //     showTitles: true,
              //     reservedSize: 28,
              //     interval: 1,
              //     getTitlesWidget: leftTitles,
              //   ),
              // ),
            ),
          ));
        },
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        toY: y1,
        color: const Color(0xff53fdd7),
        width: 7,
      ),
      BarChartRodData(
        toY: y2,
        color: const Color(0xffff5182),
        width: 7,
      ),
    ]);
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    List<String> titles = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC'
    ];

    Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value == 1000) {
      text = '1K';
    } else if (value == 5000) {
      text = '5K';
    } else if (value == 15000) {
      text = '15K';
    } else if (value == 25000) {
      text = '25K';
    } else if (value == 40000) {
      text = '40K';
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }
}

class _Espacio30 extends StatelessWidget {
  const _Espacio30({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 30,
    );
  }
}

class _GraficaCircular extends StatelessWidget {
  const _GraficaCircular({
    Key? key,
    required this.streamPieChart,
  }) : super(key: key);

  final Query<Map<String, dynamic>> streamPieChart;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: StreamBuilder(
        stream: streamPieChart.snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            final List<QueryDocumentSnapshot<Map<String, dynamic>>> items =
                snapshot.data!.docs;
            List<Map<String, dynamic>> map = [];
            double total = 0;
            for (var item in items) {
              bool flag = false;
              total += double.parse(item['cantidad']);
              for (var m in map) {
                if (m['id'] == item['categoria_id']) {
                  flag = true;
                  m['cantidad'] += double.parse(item['cantidad']);
                }
              }
              if (!flag) {
                map.add({
                  'id': item['categoria_id'],
                  'descripcion': item['categoria'],
                  'cantidad': double.parse(item['cantidad']),
                  'color': Colors
                      .primaries[Random().nextInt(Colors.primaries.length)],
                  'porcentaje': 0
                });
              }
            }
            for (var element in map) {
              element['porcentaje'] =
                  (element['cantidad'] / total * 100).toStringAsFixed(2);
            }
            final sectionData = map.map((item) {
              return PieChartSectionData(
                  value: double.parse(item['porcentaje']),
                  title: item['descripcion'],
                  color: item['color'].withOpacity(1.0),
                  showTitle: false,
                  radius: 50);
            }).toList();
            final labels = map.map((item) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        color: item['color'],
                      ),
                      Text(
                        "${item['descripcion']} (${item['porcentaje']})",
                        style: GoogleFonts.montserratAlternates(
                            color: Colors.grey),
                        softWrap: true,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 2,
                  )
                ],
              );
            }).toList();
            return Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(PieChartData(
                        sections: sectionData,
                        centerSpaceRadius: double.infinity)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: labels,
                    ),
                  ),
                )
              ],
            );
          } else {
            return PieChart(PieChartData());
          }
        },
      ),
    );
  }
}

class _TarjetaTotal extends StatelessWidget {
  const _TarjetaTotal({
    Key? key,
    required this.stream,
  }) : super(key: key);

  final Query<Map<String, dynamic>> stream;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: StreamBuilder(
          stream: stream.snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            double saldo = 0;
            if (snapshot.hasData) {
              final items = snapshot.data!.docs;
              for (var item in items) {
                if (item.get('tipo') == 'GASTO') {
                  saldo -= double.parse(item.get('cantidad'));
                } else {
                  saldo += double.parse(item.get('cantidad'));
                }
              }
            }
            return TarjetaCuenta(element: {
              'nombre': 'Total',
              'tipo': 0,
              'saldo': saldo.toStringAsFixed(2)
            });
          }),
    );
  }
}
