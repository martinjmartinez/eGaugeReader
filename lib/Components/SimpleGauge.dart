import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// ignore: must_be_immutable
class SimpleGauge extends StatefulWidget {
  SimpleGauge({Key key, this.avgValue, this.maxValue, this.value, this.title, this.invertColors, this.icon})
      : super(key: key);

  double maxValue;
  double avgValue;
  double value;
  String title;
  bool invertColors;
  IconData icon;

  @override
  _SimpleGaugeState createState() => _SimpleGaugeState();
}

class _SimpleGaugeState extends State<SimpleGauge> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.title != null
            ? Text(
                widget.title,
                style: TextStyle(color: Color(0XFF3C6E71), fontSize: 17, height: -30, fontWeight: FontWeight.w500),
              )
            : SizedBox(),
        buildGauge(),
      ],
    );
  }

  Container buildGauge() {
    return Container(
      height: 180,
      child: SfRadialGauge(
        enableLoadingAnimation: true,
        axes: <RadialAxis>[
          RadialAxis(
            radiusFactor: 0.8,
            minimum: 0,
            labelFormat: '{value}kW',
            maximum: widget.maxValue,
            axisLineStyle: AxisLineStyle(
              thickness: 0.03,
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            ranges: [
              GaugeRange(
                startValue: 0,
                endValue: (widget.maxValue / 3).floorToDouble(),
                color: widget.invertColors ? Color(0XFFe57373) : Color(0XFF81c784),
              ),
              GaugeRange(
                startValue: (widget.maxValue / 3).floorToDouble(),
                endValue: ((widget.maxValue / 3) * 2).floorToDouble(),
                color: Color(0XFFffb74d),
              ),
              GaugeRange(
                startValue: ((widget.maxValue / 3) * 2).floorToDouble(),
                endValue: ((widget.maxValue / 3) * 3).floorToDouble(),
                color: widget.invertColors ? Color(0XFF81c784) : Color(0XFFe57373),
              ),
            ],
            pointers: <GaugePointer>[
              NeedlePointer(
                  needleLength: 0.7,
                  needleEndWidth: 4,
                  value: widget.value / 1000,
                  lengthUnit: GaugeSizeUnit.factor,
                  needleColor: Colors.black45,
                  needleStartWidth: 1,
                  tailStyle: TailStyle(width: 0.2),
                  knobStyle: KnobStyle(sizeUnit: GaugeSizeUnit.factor, color: Colors.black45, knobRadius: 0.05)),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  widget: Column(
                    children: [
                      Icon(widget.icon, color: Color(0XFF3C6E71)),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        child: Text(
                          '${(widget.value / 1000).toStringAsFixed(2)} kW',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0XFF3C6E71)),
                        ),
                      ),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 1.4),
            ],
          )
        ],
      ),
    );
  }
}
