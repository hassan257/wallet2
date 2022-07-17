import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallet2/src/widgets/cuentas.dart';

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
    stream = stream.where('fecha', isGreaterThanOrEqualTo: fechaInicial);
    stream = stream.where('fecha', isLessThan: fechaFinal);
    Query<Map<String, dynamic>> streamPieChart =
        stream.where('tipo', isEqualTo: 'GASTO');
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: StreamBuilder(
                  stream: stream.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
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
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 200,
              child: StreamBuilder(
                stream: streamPieChart.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasData) {
                    final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                        items = snapshot.data!.docs;
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
                          'color': Colors.primaries[
                              Random().nextInt(Colors.primaries.length)],
                          'porcentaje': 0
                        });
                      }
                    }
                    for (var element in map) {
                      element['porcentaje'] =
                          (element['cantidad'] / total * 100)
                              .toStringAsFixed(2);
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
            )
            // SizedBox(
            //     height: 200,
            //     child: PieChart(PieChartData(sections: [
            //       PieChartSectionData(
            //           value: 100,
            //           title: 'X',
            //           color: Colors.red,),
            //       PieChartSectionData(value: 50, title: 'Y'),
            //     ]))),
          ],
        ),
      ),
    );
  }
}
