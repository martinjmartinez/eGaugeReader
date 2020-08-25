import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:peta_app/Components/Chip.dart';

class RangePicker extends StatelessWidget {
//  bool isSelected;
//  String label;
//
//  RangePicker({
//    @required this.isSelected,
//    @required this.label,
//  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black12,
          )),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomChip(label: 'Factura', isSelected: true),
            VerticalDivider(),
            CustomChip(label: 'Hoy', isSelected: false),
            VerticalDivider(),
            CustomChip(label: 'Semana', isSelected: false),
            VerticalDivider(),
            CustomChip(label: 'Mes', isSelected: false),
            VerticalDivider(),
            CustomChip(label: 'Custom', isSelected: false),
          ],
        ),
      ),
    );
  }
}
