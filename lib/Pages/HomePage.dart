import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
import 'package:peta_app/Models/Settings.dart';
import 'package:peta_app/Pages/SettingsPage.dart';
import 'package:peta_app/Utils/Database.dart';
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
  AppDataBase dataBase = AppDataBase();
  UserSettings userSettings;
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
  DateTime billDate;

  DateFormat formatter = DateFormat('dd/MM/yy');
  var numberFormat = new NumberFormat("#,###.0", "en_US");

  _initDataBase() async {
    // await dataBase.deleteDb();
    await dataBase.initDB();
    await _fetchSettings();
  }

  _fetchSettings() async {
    if (dataBase != null) {
      List<UserSettings> userSettingsList = await dataBase.getUserSettings();

      if (userSettingsList != null) {
        setState(() {
          userSettings = userSettingsList[0];
        });

        if (userSettings.domain != null && userSettings.domain.isNotEmpty) {
          setState(() {
            billDate = _getDateOfBill(userSettings.billDay);
            toDateRange = DateTime.now();
            fromDateRange = DateTime(
                toDateRange.year, toDateRange.month, toDateRange.day, 0, 0, 0);
          });

          _fetchActualData();
          setRangeGenUsg(fromDateRange, toDateRange);

          timerActualData = Timer.periodic(
              Duration(seconds: 1), (Timer t) => _fetchActualData());
          // timerReportData = Timer.periodic(Duration(seconds: 60), (Timer t) => _fetchDataSinceLastBill());
          timerRangeData = Timer.periodic(Duration(seconds: 30),
              (Timer t) => setRangeGenUsg(fromDateRange, toDateRange));
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // _klk();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDataBase();
      _fetchSettings();
    });
  }

  void _fetchActualData() async {
    var url = 'https://${userSettings.domain}.egaug.es/cgi-bin/egauge?v1&inst';
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

  Future<Map<String, double>> _fetchRangeData(
      [DateTime fromDate, DateTime toDate]) async {
    int dayOfBill = 12; //todo get this from settings
    DateTime now = DateTime.now();
    int year = now.month == 1 ? now.year - 1 : now.year;
    DateTime dateOfBill = now.day > dayOfBill
        ? DateTime(now.year, now.month, dayOfBill, 12, 00, 0)
        : DateTime(year, now.month - 1, dayOfBill, 12, 00, 0);

    fromDate = fromDate != null ? fromDate : dateOfBill;
    toDate = toDate != null ? toDate : now;
    var actualUrl =
        'https://${userSettings.domain}.egaug.es/cgi-bin/egauge-show?a&E&T=${(fromDate.millisecondsSinceEpoch / 1000).floor()},${(toDate.millisecondsSinceEpoch / 1000).floor()}';

    var response = await http.get(actualUrl);

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

    return {"gen": gen, "used": used};
  }

  void setRangeGenUsg([DateTime fromDate, DateTime toDate]) async {
    var actualPeriod = await _fetchRangeData(fromDate, toDate);
    var dates = getPreviousPeriod(fromDate, toDate);
    var prevPeriod = await _fetchRangeData(dates.start, dates.end);

    setState(() {
      rangeEnergyUsed = actualPeriod['used'];
      rangeEnergyGenerated = actualPeriod['gen'];
      prevRangeEnergyUsed = prevPeriod['used'];
      prevRangeEnergyGenerated = prevPeriod['gen'];
      fromDateRange = fromDate;
      toDateRange = toDate;
    });
  }

  void setLastPeriodGenUsg([DateTime fromDate, DateTime toDate]) async {
    var data = await _fetchRangeData(fromDate, toDate);
    setState(() {
      prevRangeEnergyUsed = data['used'];
      prevRangeEnergyGenerated = data['gen'];
    });
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
              setRangeGenUsg(fromDateRange, toDateRange);
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

  _getPage() {
    if (userSettings == null ||
        userSettings.domain == null ||
        userSettings.domain.isEmpty) {
      return SettingsPage(
          userSettings: userSettings, dataBase: dataBase, firstRun: true);
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return _getPage();
  }

  Widget buildReportData() {
    double netEnergy = rangeEnergyUsed - rangeEnergyGenerated;
    double fixPrice = userSettings.fix_101;

    if (netEnergy >= 101) {
      fixPrice = userSettings.fix_101;
    } else if (netEnergy >= 0 && netEnergy <= 100) {
      fixPrice = userSettings.fix_0_100;
    }

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
                  value:
                      "\$${numberFormat.format(_getEnergyPrice(rangeEnergyUsed))}",
                  nose: 'DOP',
                  label: 'Factura',
                ),
                InfoTile(
                  value:
                      "\$${numberFormat.format(_getEnergyPrice(rangeEnergyGenerated))}",
                  nose: 'DOP',
                  label: 'Ahorro',
                ),
                InfoTile(
                  value:
                      "\$${numberFormat.format(_getEnergyPrice(rangeEnergyUsed - rangeEnergyGenerated))}",
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
                setRangeGenUsg(billDate, now);
                break;
              case 0:
                setRangeGenUsg(
                    DateTime(now.year, now.month, now.day, 0, 0, 0), now);
                break;
              case 1:
                var _firstDayOfTheWeek = now.subtract(
                    new Duration(days: now.weekday == 1 ? 0 : now.weekday));
                setRangeGenUsg(
                    DateTime(_firstDayOfTheWeek.year, _firstDayOfTheWeek.month,
                        _firstDayOfTheWeek.day, 0, 0, 0),
                    now);
                break;

              case 2:
                setRangeGenUsg(DateTime(now.year, now.month, 1, 0, 0, 0), now);
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
    DateTime now = DateTime.now();
    if (diffDays == 0) {
      diffDays = 1;
      if (now.isAfter(from)) {
        now = DateTime(0, 0, 0, 23, 59, 59);
      }
    }
    DateTime newFrom = from.subtract(Duration(days: diffDays));
    newFrom = DateTime(newFrom.year, newFrom.month, newFrom.day, 0, 0, 0);
    DateTime newTo = to.subtract(Duration(days: diffDays));
    newTo = DateTime(
        newTo.year, newTo.month, newTo.day, now.hour, now.minute, now.second);

    return DateTimeRange(start: newFrom, end: newTo);
  }

  Container buildGoals(BuildContext context) {
    var total = rangeEnergyUsed >= rangeEnergyGenerated
        ? rangeEnergyUsed
        : rangeEnergyGenerated;
    var energyFlow = rangeEnergyGenerated - rangeEnergyUsed;
    var prevEnergyFlow = prevRangeEnergyGenerated - prevRangeEnergyUsed;
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

  double _getEnergyPrice(double energyAmount) {
    double factor = userSettings.range_701;

    if (energyAmount >= 701) {
      factor = userSettings.range_701;
    } else if (energyAmount >= 301 && energyAmount <= 700) {
      factor = userSettings.range_301_700;
    } else if (energyAmount >= 201 && energyAmount <= 300) {
      factor = userSettings.range_201_300;
    } else if (energyAmount >= 0 && energyAmount <= 200) {
      factor = userSettings.range_0_200;
    }
    return energyAmount * factor;
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
        IconButton(
            icon: Icon(FontAwesome.cog),
            color: Color(0XFF3C6E71),
            onPressed: () async {
              _showSettingPage();
            })
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

  _showSettingPage() async {
    var navigatonResult = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SettingsPage(userSettings: userSettings, dataBase: dataBase)),
    );

    if (navigatonResult == 'changed') {
      _initDataBase();
    }
  }
}
