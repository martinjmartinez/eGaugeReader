import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// ignore: must_be_immutable
class CustomChip extends StatelessWidget {
  bool isSelected;
  String label;

  CustomChip({
    @required this.isSelected,
    @required this.label,
  });

  final selectedStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  final notSelectedStyle = TextStyle(
    color: Color(0XFF3C6E71),
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => isSelected = true,
      child: Container(
        width: 65,
        decoration: isSelected
            ? BoxDecoration(
                color: Color(0XFF3C6E71),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 27,
        alignment: Alignment.center,
        child: Text(
          label,
          style: isSelected ? selectedStyle : notSelectedStyle,
        ),
      ),
    );
  }
}
