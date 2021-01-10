import 'dart:async';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';

import 'package:peta_app/Components/Chip.dart';
import 'package:peta_app/Components/InfoTile.dart';
import 'package:peta_app/Components/ProgressBar.dart';
import 'package:peta_app/Components/SectionHeader.dart';
import 'package:peta_app/Components/SimpleGauge.dart';
import 'package:peta_app/Components/flutter_toggle_tab.dart';
import 'package:peta_app/Models/Settings.dart';
import 'package:peta_app/Models/measurement.dart';
import 'package:peta_app/Pages/SettingsPage.dart';
import 'package:peta_app/Utils/Database.dart';
import 'package:peta_app/Utils/egauge.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AppDataBase dataBase = AppDataBase();
  UserSettings userSettings;
  Egauge egaugeService;
  Timer timerActualData;
  Timer timerReportData;
  Timer timerRangeData;

  double currentEnergyUsed = 0;
  double currentEnergyGenerated = 0;
  double rangeEnergyGenerated = 0;
  double rangeEnergyUsed = 0;
  double prevRangeEnergyGenerated = 0;
  double prevRangeEnergyUsed = 0;

  DateTime fromDateRange;
  DateTime toDateRange;
  DateTimeRange lastPeriodDates;
  DateTime tempFromDateRange;
  DateTime tempToDateRange;
  DateTime billDate;

  DateFormat formatter = DateFormat('dd/MM/yy hh:mm');
  final numberFormat = new NumberFormat("#,###.0", "en_US");

  _getInitialData() async {
    // await dataBase.deleteDb();
    await dataBase.initDB();
    await _fetchSettings();
  }

  _fetchSettings() async {
    if (dataBase != null) {
      final List<UserSettings> userSettingsList =
          await dataBase.getUserSettings();

      if (userSettingsList != null) {
        setState(() => userSettings = userSettingsList[0]);

        if (userSettings.domain != null && userSettings.domain.isNotEmpty) {
          egaugeService = Egauge(domain: userSettings.domain);

          setState(() {
            billDate = userSettings.nextBillingDate();
            toDateRange = DateTime.now();
            fromDateRange = DateTime(
                toDateRange.year, toDateRange.month, toDateRange.day, 0, 0, 0);
          });

          _fetchCurrentMeasurements();
          _fetchMeasurementsByRange(fromDateRange, toDateRange);

          timerActualData = Timer.periodic(
              Duration(seconds: 1), (Timer t) => _fetchCurrentMeasurements());
          timerRangeData = Timer.periodic(
              Duration(seconds: 30),
              (Timer t) =>
                  _fetchMeasurementsByRange(fromDateRange, toDateRange));
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getInitialData();
  }

  void _fetchCurrentMeasurements() async {
    final measurement = await egaugeService.getCurrentMeasurement();

    setState(() {
      currentEnergyUsed = measurement.consumption;
      currentEnergyGenerated = measurement.generation;
    });
  }

  void _fetchMeasurementsByRange(DateTime fromDate, DateTime toDate) async {
    final currentRange =
        await egaugeService.getMeasurementByDateRange(fromDate, toDate);
    final dates = getPreviousPeriod(fromDate, toDate);
    final previousRange =
        await egaugeService.getMeasurementByDateRange(dates.start, dates.end);

    setState(() {
      rangeEnergyUsed = currentRange.consumption;
      rangeEnergyGenerated = currentRange.generation;
      prevRangeEnergyUsed = previousRange.consumption;
      prevRangeEnergyGenerated = previousRange.generation;
      fromDateRange = fromDate;
      toDateRange = toDate;
    });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    final now = DateTime.now();
    final start = args.value.startDate;
    final end = (args.value.endDate ?? args.value.startDate);
    final isToday = end.difference(now).inDays;
    final newStart = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final newEnd =
        isToday == 0 ? now : DateTime(end.year, end.month, end.day, 23, 59, 59);

    setState(() {
      tempFromDateRange = newStart;
      tempToDateRange = newEnd;
    });
  }

  _openPopup(context) {
    Alert(
        style: AlertStyle(
          animationType: AnimationType.fromTop,
          isCloseButton: false,
          animationDuration: Duration(milliseconds: 400),
        ),
        context: context,
        title: "",
        content: Container(
          width: 400,
          height: 300,
          child: SfDateRangePicker(
            maxDate: DateTime.now(),
            initialSelectedRange: PickerDateRange(fromDateRange, toDateRange),
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancelar",
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
              _fetchMeasurementsByRange(fromDateRange, toDateRange);
              Navigator.pop(context);
            },
            child: Text(
              "Aceptar",
              style: TextStyle(color: Color(0XFF3C6E71), fontSize: 15),
            ),
          ),
        ]).show();
  }

  @override
  void dispose() {
    timerActualData?.cancel();
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
              currentMeasurements(),
              currentNetEnergy(),
              const SizedBox(height: 16),
              rangeSelector(context),
              const SizedBox(height: 8),
              totalMeasurements(context),
              const SizedBox(height: 16),
              rangeMeasurementsDetails(),
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

  Widget rangeMeasurementsDetails() {
    final netEnergy = rangeEnergyUsed - rangeEnergyGenerated;
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
        const SizedBox(height: 8),
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
                      "\$${numberFormat.format(_getEnergyPrice(rangeEnergyUsed - rangeEnergyGenerated).abs())}",
                  nose: 'DOP',
                  label:
                      _getEnergyPrice(rangeEnergyUsed - rangeEnergyGenerated) <
                              0
                          ? 'Ahorrado'
                          : 'Pagar',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget rangeSelector(BuildContext context) {
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
                _fetchMeasurementsByRange(billDate, now);
                break;
              case 0:
                _fetchMeasurementsByRange(
                    DateTime(now.year, now.month, now.day, 0, 0, 0), now);
                break;
              case 1:
                var _firstDayOfTheWeek = now.subtract(
                    new Duration(days: now.weekday == 1 ? 0 : now.weekday));
                _fetchMeasurementsByRange(
                    DateTime(_firstDayOfTheWeek.year, _firstDayOfTheWeek.month,
                        _firstDayOfTheWeek.day, 0, 0, 0),
                    now);
                break;
              case 2:
                _fetchMeasurementsByRange(
                    DateTime(now.year, now.month, 1, 0, 0, 0), now);
                break;
              case 4:
                _openPopup(context);
                break;
            }
          },
        ),
        const SizedBox(height: 8),
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
      if (now.isAfter(from) && now.difference(from).inDays != 0) {
        now = DateTime(0, 0, 0, 23, 59, 59);
      }
    } else if (now.isAfter(to)) {
      now = DateTime(0, 0, 0, 23, 59, 59);
    }

    DateTime newFrom = from.subtract(Duration(days: diffDays));
    newFrom = DateTime(newFrom.year, newFrom.month, newFrom.day, 0, 0, 0);
    DateTime newTo = to.subtract(Duration(days: diffDays));
    newTo = DateTime(
        newTo.year, newTo.month, newTo.day, now.hour, now.minute, now.second);

    setState(() {
      lastPeriodDates = DateTimeRange(start: newFrom, end: newTo);
    });

    return lastPeriodDates;
  }

  Container totalMeasurements(BuildContext context) {
    IconData icon;
    Color color;
    final total = rangeEnergyUsed >= rangeEnergyGenerated
        ? rangeEnergyUsed
        : rangeEnergyGenerated;
    final energyFlow = rangeEnergyGenerated - rangeEnergyUsed;
    final prevEnergyFlow = prevRangeEnergyGenerated - prevRangeEnergyUsed;
    final delta = energyFlow - prevEnergyFlow;
    final percentage = delta / prevEnergyFlow * 100;

    if (energyFlow < 0) {
      icon = FontAwesome.industry;
      color = Color(0XFFe57373);
    } else {
      icon = FontAwesome.leaf;
      color = Color(0XFF81c784);
    }
    return Container(
      child: Column(
        children: [
          SectionHeader(
              title: 'Flujo de Energía',
              subTitle: 'Estoy generando más de lo que consumo?'),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                Text(
                  " ${energyFlow.abs().toStringAsFixed(2)} kWh",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            CustomChip(
              label: '${percentage.toStringAsFixed(2)}%',
              icon: FontAwesome.history,
            ),
          ]),
          new ProgressBar(
            showValues: false,
            padding: 5,
            barColor: Color(0XFF81c784),
            barHeight: 15,
            barWidth: MediaQuery.of(context).size.width,
            numerator: rangeEnergyGenerated,
            showRemainder: false,
            denominator: total,
            title: 'Generada',
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
            barColor: Color(0XFFe57373),
            barHeight: 15,
            barWidth: MediaQuery.of(context).size.width,
            numerator: rangeEnergyUsed,
            showRemainder: false,
            denominator: total,
            title: 'Usada',
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

  IntrinsicHeight currentMeasurements() {
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

  Row currentNetEnergy() {
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
        const SizedBox(width: 4),
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
          child: const VerticalDivider(
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
    var navigationResult = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SettingsPage(userSettings: userSettings, dataBase: dataBase)),
    );

    if (navigationResult == 'changed') {
      _getInitialData();
    }
  }
}
