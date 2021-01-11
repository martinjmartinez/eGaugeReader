import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:peta_app/Components/SectionHeader.dart';
import 'package:peta_app/Models/Settings.dart';
import 'package:peta_app/Pages/HomePage.dart';
import 'package:peta_app/Utils/Database.dart';
import 'package:peta_app/Utils/validationMixins.dart';

class SettingsPage extends StatefulWidget {
  UserSettings userSettings;
  AppDataBase dataBase;
  bool firstRun;

  SettingsPage({this.userSettings, this.dataBase, this.firstRun = false});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with ValidationMixins {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
    fix_0_100 = initialData?.fix_0_100;
    fix_101 = initialData?.fix_101;
    range_0_200 = initialData?.range_0_200;
    range_201_300 = initialData?.range_201_300;
    range_301_700 = initialData?.range_301_700;
    range_701 = initialData?.range_701;
  }

  Widget basicInformation() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0XFF3C6E71),
          )),
      child: Column(
        children: [
          buildInputField("Dominio", domainInputField()),
          SizedBox(height: 16),
          buildNumberSelection(billDay),
        ],
      ),
    );
  }

  Widget fixedPriceInformation() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0XFF3C6E71),
          )),
      child: Column(
        children: [
          buildInputField("De 0 hasta 100 kWh", firstFixedPriceRangeInputField(),),
          buildInputField("Mayor a 101 kWh", secondFixedPriceRangeInputField(),),

          // fix1Field("De 0 hasta 100 kWh", "37.95"),
          // fix2Field("Mayor a 101 kWh", "137.25"),
        ],
      ),
    );
  }

  Widget priceInformation() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0XFF3C6E71),
          )),
      child: Column(
        children: [
          buildInputField("De 0 hasta 200 kWh", firstPriceRangeInputField()),
          buildInputField("De 201 a 300 kWh", secondPriceRangeInputField()),
          buildInputField("De 301 a 700 kWh", thirdPriceRangeInputField()),
          buildInputField("Mas de 700 kWh", fourthPriceRangeInputField()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              SectionHeader(title: "Generales", hideInfo: true),
              const SizedBox(height: 8),
              basicInformation(),
              const SizedBox(height: 16),
              SectionHeader(title: "Facturación", hideInfo: true),
              const SizedBox(height: 8),
              SectionHeader(
                title: 'Cargo fijo',
                hideInfo: true,
                titleSize: 16,
                hideDivider: false,
              ),
              fixedPriceInformation(),
              const SizedBox(height: 16),
              SectionHeader(
                title: 'Cargo por energía',
                hideInfo: true,
                titleSize: 16,
                hideDivider: false,
              ),
              priceInformation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget domainInputField() {
    return TextFormField(
      initialValue: initialData?.domain,
      decoration: InputDecoration(
        hintText: 'egaugeXXXXX',
        border: OutlineInputBorder(),
      ),
      onSaved: (value) => domain = value,
      validator: validateStringField,
    );
  }

  Widget firstFixedPriceRangeInputField() {
    return TextFormField(
      initialValue: fix_0_100?.toString() ?? '',
      keyboardType: TextInputType.number,
      decoration:
          InputDecoration(hintText: '37.95', border: OutlineInputBorder()),
      onSaved: (value) => fix_0_100 = double.parse(value),
      validator: validateNumberField,
    );
  }

  Widget secondFixedPriceRangeInputField() {
    return TextFormField(
      initialValue: fix_101?.toString() ?? '',
      keyboardType: TextInputType.number,
      decoration:
          InputDecoration(hintText: '137.25', border: OutlineInputBorder()),
      onSaved: (value) => fix_101 = double.parse(value),
      validator: validateNumberField,
    );
  }

  Widget firstPriceRangeInputField() {
    return TextFormField(
      initialValue: range_0_200?.toString() ?? '',
      keyboardType: TextInputType.number,
      decoration:
          InputDecoration(hintText: '4.44', border: OutlineInputBorder()),
      onSaved: (value) => range_0_200 = double.parse(value),
      validator: validateNumberField,
    );
  }

  Widget secondPriceRangeInputField() {
    return TextFormField(
      keyboardType: TextInputType.number,
      initialValue: range_201_300?.toString() ?? '',
      decoration:
          InputDecoration(hintText: '6.97', border: OutlineInputBorder()),
      onSaved: (value) => range_201_300 = double.parse(value),
      validator: validateNumberField,
    );
  }

  Widget thirdPriceRangeInputField() {
    return TextFormField(
      initialValue: range_301_700?.toString() ?? '',
      keyboardType: TextInputType.number,
      decoration:
          InputDecoration(hintText: '10.86', border: OutlineInputBorder()),
      onSaved: (value) => range_301_700 = double.parse(value),
      validator: validateNumberField,
    );
  }

  Widget fourthPriceRangeInputField() {
    return TextFormField(
      initialValue: range_701?.toString() ?? '',
      keyboardType: TextInputType.number,
      decoration:
          InputDecoration(hintText: '11.10', border: OutlineInputBorder()),
      onSaved: (value) => range_701 = double.parse(value),
      validator: validateNumberField,
    );
  }

  Widget buildInputField(String title, Widget inputField ) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          hideInfo: true,
          titleSize: 15,
          hideDivider: true,
          titleWeight: FontWeight.w500,
        ),
        const SizedBox(height: 4),
        inputField
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
        const SizedBox(height: 4),
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
              if (formKey.currentState.validate()) {
                formKey.currentState.save();

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
              }
            })
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
