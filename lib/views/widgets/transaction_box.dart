import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionBox extends StatelessWidget {
  String direction;
  double transactionValueInEth;
  double transactionValueInUSD;
  String hash;
  int timeStamp;
  String note;
  int index;

  TransactionBox(
      this.direction,
      this.transactionValueInEth,
      this.transactionValueInUSD,
      this.hash,
      this.timeStamp,
      this.note,
      this.index);

  String formatTimestamp(int timestamp) {
    var format = new DateFormat('d MMM, hh:mm a');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    return format.format(date);
  }

  String formatHash(String hash) {
    String formattedHash = hash.substring(0, 20);

    return formattedHash;
  }

  String getNote() {
    return this.note;
  }

  void setNote(String note) {
    this.note = note;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '  $direction',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18.0, color: Color(0xFF71727E)),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '  $transactionValueInEth Eth',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 15.0, color: Color(0xFF71727E)),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '  ${transactionValueInUSD.toStringAsFixed(2)} USD',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 15.0, color: Color(0xFF71727E)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${formatTimestamp(this.timeStamp)}   ',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18.0, color: Color(0xFF71727E)),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ' ${formatHash(hash)}...',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 15.0, color: Color(0xFF71727E)),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(
                            Icons.edit,
                            size: 15.0,
                            color: Colors.grey,
                          ),
                          Text(
                            ' ${note != 'null' ? note : 'Note'}    ',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 15.0, color: Color(0xFF71727E)),
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      height: 120.0,
      decoration: BoxDecoration(
        color: Color(0xFF0A0E21),
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
    );
  }
}

/*
showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: Text('hej'),
                                content: Text('hejhej'),
                                actions: [
                                  FlatButton(
                                    child: Text('Yes'),
                                    onPressed: Navigator.of(context).pop(),
                                  ),
                                ],
                              ));
 */
