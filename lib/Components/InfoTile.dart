import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InfoTile extends StatelessWidget {
  String label;
  String value;
  String nose;

  InfoTile({Key key, this.label, this.value, this.nose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.0),
//      decoration: BoxDecoration(
//        border: Border.all(color: Colors.black12),
//        borderRadius: BorderRadius.circular(10.0),
//        color: Colors.white12,
//      ),
      height: 100,
      width: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: Color(0XFF3C6E71)),
          ),
          Text(
            nose,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 0.8,
              color: Colors.grey,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: Color(0XFF3C6E71),
            ),
          ),
        ],
      ),
    );
  }
}
