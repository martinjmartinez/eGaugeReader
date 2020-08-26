import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:peta_app/Components/Chip.dart';
import 'package:peta_app/Components/InfoTile.dart';
import 'package:peta_app/Components/ProgressBar.dart';
import 'package:peta_app/Components/SectionHeader.dart';
import 'package:peta_app/Components/SimpleGauge.dart';
import 'package:peta_app/Components/flutter_toggle_tab.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:xml2json/xml2json.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer timerActualData;
  Timer timerReportData;
  Timer timerRangeData;

  double currentEnergyUsed = 0;
  double currentEnergyGenerated = 0;
  double rangeEnergyGenerated = 0;
  double rangeEnergyUsed = 0;
  double prevRangeEnergyGenerated = 0;
  double prevRangeEnergyUsed = 0;
  //
  // double rangeGenerated = 0;
  // double rangeUsed = 0;

  DateTime fromDateRange;
  DateTime toDateRange;
  DateTime tempFromDateRange;
  DateTime tempToDateRange;

  final DateFormat formatter = DateFormat('dd/MM/yy');
  var numberFormat = new NumberFormat("#,###.0", "en_US");

  @override
  void initState() {
    super.initState();
    fromDateRange = _getDateOfBill(12);
    toDateRange = DateTime.now();
    _fetchActualData();
    // _fetchDataSinceLastBill();
    _fetchRangeData(
        DateTime(toDateRange.year, toDateRange.month, toDateRange.day, 0, 0, 0),
        toDateRange);
    timerActualData =
        Timer.periodic(Duration(seconds: 1), (Timer t) => _fetchActualData());
    // timerReportData = Timer.periodic(Duration(seconds: 60), (Timer t) => _fetchDataSinceLastBill());
    timerRangeData = Timer.periodic(Duration(seconds: 30),
        (Timer t) => _fetchRangeData(fromDateRange, toDateRange));
  }

  void _fetchActualData() async {
    var url = 'https://egauge53186.egaug.es/cgi-bin/egauge?v1&inst';
    var response = await http.get(url);
    final myTransformer = Xml2Json();
    myTransformer.parse(response.body);
    var attributes = json.decode(myTransformer.toGData())['data']['r'] as List;
    var used =
        attributes.firstWhere((element) => element['did'] == '0')['i']['\$t'];
    var generated =
        attributes.firstWhere((element) => element['did'] == '2')['i']['\$t'];

    setState(() {
      currentEnergyUsed = double.parse(used);
      currentEnergyGenerated = double.parse(generated);
    });
  }

  DateTime _getDateOfBill(int day) {
    DateTime now = DateTime.now();
    int year = now.month == 1 ? now.year - 1 : now.year;
    DateTime fromDateRange = now.day > day
        ? DateTime(now.year, now.month, day, 12, 00, 0)
        : DateTime(year, now.month - 1, day, 12, 00, 0);

    return fromDateRange;
  }

  void _fetchRangeData([DateTime fromDate, DateTime toDate]) async {
    int dayOfBill = 12;
    DateTime now = DateTime.now();
    int year = now.month == 1 ? now.year - 1 : now.year;
    DateTime dateOfBill = now.day > dayOfBill
        ? DateTime(now.year, now.month, dayOfBill, 12, 00, 0)
        : DateTime(year, now.month - 1, dayOfBill, 12, 00, 0);

    fromDate = fromDate != null ? fromDate : dateOfBill;
    toDate = toDate != null ? toDate : now;
    DateTimeRange prevRange = getPreviousPeriod(fromDate, toDate);
    print(prevRange.start);
    print(prevRange.end);
    var actualUrl =
        'https://egauge53186.egaug.es/cgi-bin/egauge-show?a&E&T=${(fromDate.millisecondsSinceEpoch / 1000).floor()},${(toDate.millisecondsSinceEpoch / 1000).floor()}';
    var prevlUrl =
        'https://egauge53186.egaug.es/cgi-bin/egauge-show?a&E&T=${(prevRange.start.millisecondsSinceEpoch / 1000).floor()},${(prevRange.end.millisecondsSinceEpoch / 1000).floor()}';

    var actualResponse = await http.get(actualUrl);
    var prevResponse = await http.get(prevlUrl);
    var responses = [actualResponse, prevResponse];
    var isPrev = false;
    for (var response in responses) {
      if (response.statusCode == 200) {
        final myTransformer = Xml2Json();

        myTransformer.parse(response.body);
        var jsonData = myTransformer.toGData();
        var fromReg = (json.decode(jsonData)['group']['data'][0] != null
            ? json.decode(jsonData)['group']['data'][0]['r']['c']
            : json.decode(jsonData)['group']['data']['r'][0]['c']) as List;
        var toReg = (json.decode(jsonData)['group']['data'][1] != null
            ? json.decode(jsonData)['group']['data'][1]['r']['c']
            : json.decode(jsonData)['group']['data']['r'][1]['c']) as List;

        var from = {
          'use': int.parse(fromReg[0]['\$t']) / 3600000,
          'gen': int.parse(fromReg[1]['\$t']) / 3600000
        };
        var to = {
          'use': int.parse(toReg[0]['\$t']) / 3600000,
          'gen': int.parse(toReg[1]['\$t']) / 3600000
        };

        final used = to['use'] - from['use'];
        final gen = to['gen'] - from['gen'];

        if (isPrev) {
          setState(() {
            prevRangeEnergyUsed = used;
            prevRangeEnergyGenerated = gen;
          });
        } else {
          isPrev = true;
          setState(() {
            rangeEnergyUsed = used;
            rangeEnergyGenerated = gen;
            fromDateRange = fromDate;
            toDateRange = toDate;
          });
        }
      }
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    DateTime now = DateTime.now();
    DateTime start = args.value.startDate;
    DateTime end = (args.value.endDate ?? args.value.startDate);
    var isToday = end.difference(now).inDays;

    DateTime newStart = DateTime(start.year, start.month, start.day, 0, 0, 0);
    DateTime newEnd =
        isToday == 0 ? now : DateTime(end.year, end.month, end.day, 23, 59, 59);

    setState(() {
      tempFromDateRange = newStart;
      tempToDateRange = newEnd;
    });
  }

  var alertStyle = AlertStyle(
    animationType: AnimationType.fromTop,
    isCloseButton: false,
    animationDuration: Duration(milliseconds: 400),
  );
  _openPopup(context) {
    Alert(
        style: alertStyle,
        context: context,
        title: "",
        content: Container(
          width: 400,
          height: 300,
          child: SfDateRangePicker(
            maxDate: DateTime.now(),
            initialSelectedRange: PickerDateRange(fromDateRange, toDateRange),
//            minDate: DateTime.now(),//TODO DATE OF START READING
            initialDisplayDate: DateTime.now(),
            selectionColor: Color(0XFF3C6E71),
            endRangeSelectionColor: Color(0XFF3C6E71),
            startRangeSelectionColor: Color(0XFF3C6E71),
            rangeSelectionColor: Color(0XFFC2DFE0),
            todayHighlightColor: Color(0XFFC2DFE0),
            onSelectionChanged: _onSelectionChanged,
            selectionMode: DateRangePickerSelectionMode.range,
          ),
        ),
        buttons: [
          DialogButton(
            color: Colors.white,
            onPressed: () => {Navigator.pop(context)},
            child: Text(
              "Cancel",
              style: TextStyle(color: Color(0XFF3C6E71), fontSize: 15),
            ),
          ),
          DialogButton(
            color: Colors.white,
            onPressed: () {
              setState(() {
                fromDateRange = tempFromDateRange;
                toDateRange = tempToDateRange;
              });
              _fetchRangeData(fromDateRange, toDateRange);
              Navigator.pop(context);
            },
            child: Text(
              "Ok",
              style: TextStyle(color: Color(0XFF3C6E71), fontSize: 15),
            ),
          ),
        ]).show();
  }

  @override
  void dispose() {
    timerActualData?.cancel();
    // timerReportData?.cancel();
    timerRangeData?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildActualMesurements(),
            buildCurrentNetEnergy(),
            SizedBox(height: 16),
            buildDateRanges(context),
            SizedBox(height: 8),
            buildGoals(context),
            SizedBox(height: 16),
            buildReportData(),
          ],
        ),
      ),
    );
  }

  Widget buildReportData() {
    return Column(
      children: [
        SectionHeader(
            title: 'Resumen por periodo',
            subTitle:
                'Cuanto estoy generando/consumiendo en un rango de tiempo dado?'),
        SizedBox(height: 8),
        Table(
          border: TableBorder.symmetric(inside: BorderSide(width: 0.07)),
          children: [
            TableRow(
              children: [
                InfoTile(
                  value: rangeEnergyUsed.toStringAsFixed(2),
                  nose: 'kWh',
                  label: 'Usada',
                ),
                InfoTile(
                  value: rangeEnergyGenerated.toStringAsFixed(2),
                  nose: 'kWh',
                  label: 'Generada',
                ),
                InfoTile(
                  value: (rangeEnergyUsed - rangeEnergyGenerated)
                      .toStringAsFixed(2),
                  nose: 'kWh',
                  label: 'Neta',
                ),
              ],
            ),
            TableRow(
              children: [
                InfoTile(
                  value: "\$${numberFormat.format(rangeEnergyUsed * 11.10)}",
                  nose: 'DOP',
                  label: 'Factura',
                ),
                InfoTile(
                  value:
                      "\$${numberFormat.format(rangeEnergyGenerated * 11.10)}",
                  nose: 'DOP',
                  label: 'Ahorro',
                ),
                InfoTile(
                  value:
                      "\$${numberFormat.format(((rangeEnergyUsed * 11.10) - (rangeEnergyGenerated * 11.10)))}",
                  nose: 'DOP',
                  label: 'Pagar',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDateRanges(BuildContext context) {
    return Column(
      children: [
        FlutterToggleTab(
          width: 90,
          borderRadius: 30,
          height: 25,
          initialIndex: 0,
          unSelectedBackgroundColors: [Colors.white, Colors.white],
          selectedBackgroundColors: [Color(0XFF3C6E71)],
          selectedTextStyle: TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          unSelectedTextStyle: TextStyle(
              color: Color(0XFF3C6E71),
              fontSize: 14,
              fontWeight: FontWeight.w500),
          labels: const ["Hoy", "Semana", "Mes", "Factura", 'Custom'],
          selectedLabelIndex: (index) {
            var now = DateTime.now();
            switch (index) {
              case 3:
                _fetchRangeData();
                break;
              case 0:
                _fetchRangeData(
                    DateTime(now.year, now.month, now.day, 0, 0, 0), now);
                break;
              case 1:
                var _firstDayOfTheWeek = now.subtract(
                    new Duration(days: now.weekday == 1 ? 0 : now.weekday));
                _fetchRangeData(
                    DateTime(_firstDayOfTheWeek.year, _firstDayOfTheWeek.month,
                        _firstDayOfTheWeek.day, 0, 0, 0),
                    now);
                break;

              case 2:
                _fetchRangeData(DateTime(now.year, now.month, 1, 0, 0, 0), now);
                break;
              case 4:
                _openPopup(context);
                break;
            }
          },
        ),
        SizedBox(height: 8),
        Text(
          "${formatter.format(fromDateRange)} - ${formatter.format(toDateRange)}",
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: Color(0XFF3C6E71)),
        ),
      ],
    );
  }

  DateTimeRange getPreviousPeriod(DateTime from, DateTime to) {
    int diffDays = to.difference(from).inDays;
    print(diffDays);
    if(diffDays == 0) {
      diffDays = 1;
    }
    DateTime newFrom = from.subtract(Duration(days: diffDays));
    newFrom = DateTime(newFrom.year, newFrom.month, newFrom.day, 0, 0, 0);
    DateTime newTo = to.subtract(Duration(days: diffDays));
    newTo = DateTime(newTo.year, newTo.month, newTo.day, 23, 59, 59);

    return DateTimeRange(start: newFrom, end: newTo);
  }

  Container buildGoals(BuildContext context) {
    var total = rangeEnergyUsed >= rangeEnergyGenerated
        ? rangeEnergyUsed
        : rangeEnergyGenerated;
    var energyFlow = rangeEnergyGenerated - rangeEnergyUsed;
    var prevEnergyFlow = prevRangeEnergyGenerated - prevRangeEnergyUsed;
    print(prevEnergyFlow);
    var delta = energyFlow - prevEnergyFlow;
    var percentage = delta / prevEnergyFlow * 100;

    return Container(
      child: Column(
        children: [
          SectionHeader(
              title: 'Flujo de Energía',
              subTitle: 'Estoy generando más de lo que consumo?'),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              " ${energyFlow.toStringAsFixed(2)} kWh",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0XFF3C6E71),
              ),
            ),
            CustomChip(
              label: '${percentage.toStringAsFixed(2)}%',
              icon: FontAwesome.history,
            ),
          ]),
          new ProgressBar(
            showValues: false,
            padding: 5,
            barColor: Color(0XFFe57373),
            barHeight: 15,
            barWidth: MediaQuery.of(context).size.width,
            numerator: rangeEnergyUsed,
            showRemainder: false,
            denominator: total, //TODO META CONSUMO
            title: 'Usada',
            dialogTextStyle: new TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            titleStyle: new TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0XFF3C6E71)),
            boarderColor: Colors.grey,
          ),
          new ProgressBar(
            showValues: false,
            padding: 5,
            barColor: Color(0XFF81c784),
            barHeight: 15,
            barWidth: MediaQuery.of(context).size.width,
            numerator: rangeEnergyGenerated,
            showRemainder: false,
            denominator: total, //TODO META Generacion
            title: 'Generada',
            dialogTextStyle: new TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            titleStyle: new TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0XFF3C6E71)),
            boarderColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  IntrinsicHeight buildActualMesurements() {
    return IntrinsicHeight(
      child: Column(
        children: [
          SectionHeader(
              title: 'Actual',
              subTitle: 'Cuanto estoy generando/consumiendo actualmente?'),
          buildGauges(),
        ],
      ),
    );
  }

  Row buildCurrentNetEnergy() {
    double currentNetEnergy;
    IconData icon;
    Color color;
    if (currentEnergyUsed > currentEnergyGenerated) {
      currentNetEnergy = currentEnergyUsed - currentEnergyGenerated;
      icon = FontAwesome.industry;
      color = Color(0XFFe57373);
    } else {
      currentNetEnergy = currentEnergyGenerated - currentEnergyUsed;
      icon = FontAwesome.leaf;
      color = Color(0XFF81c784);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
            child: Divider(
          endIndent: 6,
        )),
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        SizedBox(width: 4),
        Text(
          '${(currentNetEnergy / 1000).toStringAsFixed(2)} kW',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: color),
        ),
        Flexible(
            child: Divider(
          indent: 6,
        )),
      ],
    );
  }

  Row buildGauges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Flexible(
          flex: 50,
          child: SimpleGauge(
            maxValue: 4,
            icon: FontAwesome.industry,
            value: currentEnergyUsed,
            invertColors: false,
          ),
        ),
        Flexible(
          flex: 1,
          child: VerticalDivider(
            indent: 16,
            endIndent: 16,
          ),
        ),
        Flexible(
          flex: 50,
          child: SimpleGauge(
            icon: FontAwesome.leaf,
            maxValue: 4,
            value: currentEnergyGenerated,
            invertColors: true,
          ),
        ),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 60,
      actions: [
        //TODO SEND TO SETTING PAGE
        IconButton(
          icon: Icon(FontAwesome.cog),
          onPressed: null,
        )
      ],
      title: Text(
        widget.title,
        style: TextStyle(
            color: Color(0XFF3C6E71),
            fontSize: 30,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
