import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CicularIndicator extends StatefulWidget {
  const CicularIndicator({Key? key}) : super(key: key);

  @override
  State<CicularIndicator> createState() => _CicularIndicatorState();
}

class _CicularIndicatorState extends State<CicularIndicator> {
  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 50.0,
      lineWidth: 13.0,
      animation: false,
      percent: 0.01,
      center: Text(
        "70.0%",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.purple,
    );
  }
}
