import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomChip extends StatelessWidget {
  String label;
  IconData icon;

  CustomChip({
    @required this.label,
    this.icon,
  });

  final selectedStyle = TextStyle(
    color: Color(0XFF3C6E71),
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Color(0XFF3C6E71),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 27,
      alignment: Alignment.center,
      child: Row(
        children: [
          Text(
            label,
            style: selectedStyle,
          ),
          icon != null
              ? Icon(
                  icon,
                  color: Color(0XFF3C6E71),
                  size: 17,
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
