import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  final Function onTap;
  final String buttonTitle;

  BottomButton({@required this.onTap, @required this.buttonTitle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Center(
          child: Text(
            buttonTitle,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
                color: Color(0xFFADAEBB)),
          ),
        ),
        color: Color(0xFF454A75),
        padding: EdgeInsets.only(bottom: 10.0),
        width: double.infinity,
        height: 70.0,
      ),
    );
  }
}
