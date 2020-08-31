import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SectionHeader extends StatefulWidget {
  SectionHeader({
    Key key,
    this.title,
    this.titleSize = 18,
    this.subTitle,
    this.hideInfo = false,
    this.hideDivider = false,
    this.titleWeight = FontWeight.bold
  }) : super(key: key);

  final String title;
  final String subTitle;
  final double titleSize;
  final bool hideInfo;
  final bool hideDivider;
  final FontWeight titleWeight;

  @override
  _SectionHeaderState createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<SectionHeader> {
  bool isInfoHidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: Color(0XFF3C6E71),
                fontSize: widget.titleSize,
                fontWeight: widget.titleWeight,
              ),
            ),
            !widget.hideInfo
                ? IconButton(
                    constraints: BoxConstraints(maxWidth: 20, maxHeight: 20),
                    padding: EdgeInsets.only(bottom: 1, left: 3),
                    color: Colors.grey,
                    icon: Icon(Icons.info_outline),
                    iconSize: 20,
                    onPressed: () => {
                      setState(() {
                        isInfoHidden = !isInfoHidden;
                      })
                    },
                  )
                : SizedBox()
          ],
        ),
        isInfoHidden
            ? SizedBox(
                height: 0,
              )
            : Text(
                widget.subTitle,
                style: TextStyle(
                    color: Color(0XFF3C6E71), fontSize: 13, height: 1.5),
              ),
        !widget.hideDivider ? Divider() : SizedBox(),
      ],
    );
  }
}
