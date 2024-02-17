import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class TimepickerWidget extends StatefulWidget {
  const TimepickerWidget({
    this.labelText,
    this.suffixIcon,
    this.controller,
    this.filled,
    this.decoration,
    this.enabled,
    this.validator,
    this.hintStyle,
    this.hintText,
    this.textStyle,
    this.onConfirm,
    this.currentTime,
    this.fillColor,
  });
  final String? labelText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool? filled;
  final InputDecoration? decoration;
  final bool? enabled;
  final FormFieldValidator? validator;
  final TextStyle? hintStyle;
  final String? hintText;
  final TextStyle? textStyle;
  final Function(DateTime)? onConfirm;
  // final DateChangedCallback? onConfirm;

  final DateTime? currentTime;
  final Color? fillColor;
  @override
  _TimepickerWidgetState createState() => _TimepickerWidgetState();
}

class _TimepickerWidgetState extends State<TimepickerWidget> {
  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: (FormFieldState state) {
        return DateTimeField(
          style: widget.textStyle,
          textAlign: TextAlign.start,
          enabled: widget.enabled ?? true,
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: TextInputType.datetime,
          format: DateFormat("dd-MM-yyyy", 'en_US'),
          resetIcon: null,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8),
            suffixIcon: widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            fillColor: widget.fillColor,
            filled: true,
            hintStyle: widget.hintStyle,
            hintText: widget.hintText,
          ),
          onShowPicker: (context, currentValue) async {
            final selectedTime = await DatePicker.showDatePicker(
              context,
              theme: DatePickerTheme(
                containerHeight: 200.0,
                itemHeight: 40,
              ),
              currentTime: widget.currentTime,
              showTitleActions: true,
              minTime: DateTime.now(),
              locale: LocaleType.en,
              onChanged: (time) {},
              onConfirm: widget.onConfirm,
            );
            if (selectedTime != null) {
              int hour = selectedTime.hour;
              TimeOfDay pickedTime = TimeOfDay(hour: hour, minute: 00);
              setState(() {});
              return DateTimeField.combine(selectedTime, pickedTime);
            } else {}
            return null;
          },
        );
      },
    );
  }
}
