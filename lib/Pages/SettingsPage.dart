import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:peta_app/Components/SectionHeader.dart';
import 'package:peta_app/Models/Settings.dart';
import 'package:peta_app/Pages/HomePage.dart';
import 'package:peta_app/Utils/Database.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class SettingsPage extends StatefulWidget {
  UserSettings userSettings;
  AppDataBase dataBase;
  bool firstRun;

  SettingsPage({this.userSettings, this.dataBase, this.firstRun = false});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserSettings initialData;
  String domain;
  int billDay;
  double fix_0_100;
  double fix_101;
  double range_0_200;
  double range_201_300;
  double range_301_700;
  double range_701;

  @override
  void initState() {
    super.initState();

    initialData = widget.userSettings;
    billDay = initialData?.billDay;
    domain = initialData?.domain;
    fix_101 = initialData?.fix_101;
    fix_0_100 = initialData?.fix_0_100;
    range_0_200 = initialData?.range_0_200;
    range_201_300 = initialData?.range_201_300;
    range_301_700 = initialData?.range_301_700;
    range_701 = initialData?.range_701;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SectionHeader(title: "Generales", hideInfo: true),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Color(0XFF3C6E71),
                  )),
              child: Column(
                children: [
                  buildtextField("Dominio", "egaugeXXXXX"),
                  SizedBox(height: 16),
                  buildNumberSelection(billDay),
                ],
              ),
            ),
            SizedBox(height: 16),
            SectionHeader(title: "Facturación", hideInfo: true),
            SizedBox(height: 8),
            SectionHeader(
              title: 'Cargo fijo',
              hideInfo: true,
              titleSize: 16,
              hideDivider: false,
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Color(0XFF3C6E71),
                  )),
              child: Column(
                children: [
                  fix1Field("De 0 hasta 100 kWh", "37.95"),
                  fix2Field("Mayor a 101 kWh", "137.25"),
                ],
              ),
            ),
            SizedBox(height: 16),
            SectionHeader(
              title: 'Cargo por energía',
              hideInfo: true,
              titleSize: 16,
              hideDivider: false,
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Color(0XFF3C6E71),
                  )),
              child: Column(
                children: [
                  range1Field("De 0 hasta 200 kWh", "4.44"),
                  range2Field("De 201 a 300 kWh", "6.97"),
                  range3Field("De 301 a 700 kWh", "10.86"),
                  range4Field("Mas de 700 kWh", "11.10"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildtextField(String title, String hint) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          hideInfo: true,
          titleSize: 15,
          hideDivider: true,
          titleWeight: FontWeight.w500,
        ),
        SizedBox(height: 4),
        TextFormField(
          initialValue: domain,
          decoration:
              InputDecoration(hintText: hint, border: OutlineInputBorder()),
          onChanged: (value) {
            setState(() {
              domain = value;
            });
          },
        ),
      ],
    );
  }

  Widget buildNumberField(String title, String hint, double oldValuer) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          hideInfo: true,
          titleSize: 15,
          hideDivider: true,
          titleWeight: FontWeight.w500,
        ),
        SizedBox(height: 4),
        TextFormField(
          initialValue: oldValuer?.toStringAsFixed(2),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration:
              InputDecoration(hintText: hint, border: OutlineInputBorder()),
          onChanged: (value) {
            setState(() {
              oldValuer = double.parse(value);
            });
          },
        ),
      ],
    );
  }

  Widget fix1Field(String title, String hint) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          hideInfo: true,
          titleSize: 15,
          hideDivider: true,
          titleWeight: FontWeight.w500,
        ),
        SizedBox(height: 4),
        TextFormField(
          initialValue: fix_0_100?.toStringAsFixed(2),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration:
              InputDecoration(hintText: hint, border: OutlineInputBorder()),
          onChanged: (value) {
            setState(() {
              fix_0_100 = double.parse(value);
            });
          },
        ),
      ],
    );
  }

  Widget fix2Field(String title, String hint) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          hideInfo: true,
          titleSize: 15,
          hideDivider: true,
          titleWeight: FontWeight.w500,
        ),
        SizedBox(height: 4),
        TextFormField(
          initialValue: fix_101?.toStringAsFixed(2),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration:
              InputDecoration(hintText: hint, border: OutlineInputBorder()),
          onChanged: (value) {
            setState(() {
              fix_101 = double.parse(value);
            });
          },
        ),
      ],
    );
  }

  Widget range1Field(String title, String hint) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          hideInfo: true,
          titleSize: 15,
          hideDivider: true,
          titleWeight: FontWeight.w500,
        ),
        SizedBox(height: 4),
        TextFormField(
          initialValue: range_0_200?.toStringAsFixed(2),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration:
              InputDecoration(hintText: hint, border: OutlineInputBorder()),
          onChanged: (value) {
            setState(() {
              range_0_200 = double.parse(value);
            });
          },
        ),
      ],
    );
  }

  Widget range2Field(String title, String hint) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          hideInfo: true,
          titleSize: 15,
          hideDivider: true,
          titleWeight: FontWeight.w500,
        ),
        SizedBox(height: 4),
        TextFormField(
          initialValue: range_201_300?.toStringAsFixed(2),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration:
              InputDecoration(hintText: hint, border: OutlineInputBorder()),
          onChanged: (value) {
            setState(() {
              range_201_300 = double.parse(value);
            });
          },
        ),
      ],
    );
  }

  Widget range3Field(String title, String hint) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          hideInfo: true,
          titleSize: 15,
          hideDivider: true,
          titleWeight: FontWeight.w500,
        ),
        SizedBox(height: 4),
        TextFormField(
          initialValue: range_301_700?.toStringAsFixed(2),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration:
              InputDecoration(hintText: hint, border: OutlineInputBorder()),
          onChanged: (value) {
            setState(() {
              range_301_700 = double.parse(value);
            });
          },
        ),
      ],
    );
  }

  Widget range4Field(String title, String hint) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          hideInfo: true,
          titleSize: 15,
          hideDivider: true,
          titleWeight: FontWeight.w500,
        ),
        SizedBox(height: 4),
        TextFormField(
          initialValue: range_701?.toStringAsFixed(2),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration:
              InputDecoration(hintText: hint, border: OutlineInputBorder()),
          onChanged: (value) {
            setState(() {
              range_701 = double.parse(value);
            });
          },
        ),
      ],
    );
  }

  Widget buildNumberSelection(int day) {
    return Column(
      children: [
        SectionHeader(
          title: "Inicio de facturación",
          hideInfo: true,
          titleSize: 15,
          hideDivider: true,
          titleWeight: FontWeight.w500,
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Text("Cada",
                style: TextStyle(color: Color(0XFF3C6E71), fontSize: 15)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: DropdownButton<int>(
                value: billDay,
                items: Iterable<int>.generate(32)
                    .toList()
                    .getRange(1, 32)
                    .map((int value) {
                  return new DropdownMenuItem<int>(
                    value: value,
                    child: new Text(value.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    billDay = value;
                  });
                },
              ),
            ),
            Text(
              "del mes.",
              style: TextStyle(color: Color(0XFF3C6E71), fontSize: 15),
            ),
          ],
        ),
      ],
    );
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
          width: 200,
          height: 70,
          child: Text(
            'Los ajustes no puedes estar vacios o ser 0.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        buttons: [
          DialogButton(
            color: Colors.white,
            onPressed: () => {Navigator.pop(context)},
            child: Text(
              "ok",
              style: TextStyle(color: Color(0XFF3C6E71), fontSize: 15),
            ),
          ),
        ]).show();
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: BackButton(
        color: Color(0XFF3C6E71),
      ),
      centerTitle: false,
      toolbarHeight: 60,
      actions: [
        IconButton(
          icon: Icon(FontAwesome.save),
          color: Color(0XFF3C6E71),
          onPressed: () async {
            var newUser = UserSettings(
                id: 1,
                domain: domain,
                billDay: billDay,
                fix_0_100: fix_0_100,
                fix_101: fix_101,
                range_0_200: range_0_200,
                range_201_300: range_201_300,
                range_301_700: range_301_700,
                range_701: range_701);
            if (newUser.domain != null &&
                newUser.domain?.isNotEmpty &&
                newUser.fix_0_100 > 0 &&
                newUser.fix_101 > 0 &&
                newUser.range_0_200 > 0 &&
                newUser.range_201_300 > 0 &&
                newUser.range_301_700 > 0 &&
                newUser.range_701 > 0) {
              await widget.dataBase.updateSettings(newUser);
              if (widget.firstRun) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyHomePage(title: 'DashBoard')),
                    ModalRoute.withName("/Home"));
              } else {
                Navigator.pop(context, 'changed');
              }
            } else {
              _openPopup(context);
            }
          },
        )
      ],
      title: Text(
        'Ajustes',
        style: TextStyle(
            color: Color(0XFF3C6E71),
            fontSize: 30,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
