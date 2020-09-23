import 'file:///G:/Programming/API/Projekt/eth_wallet/lib/views/widgets/bottom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class SendPage extends StatefulWidget {
  @override
  _SendPageState createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final myAddressController = TextEditingController();
  final myAmountController = TextEditingController();
  final myNoteController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myAddressController.dispose();
    myNoteController.dispose();
    myAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Container(
          margin:
              EdgeInsets.only(left: 10.0, right: 10.0, top: 30.0, bottom: 20.0),
          decoration: BoxDecoration(
              color: Color(0xFF0A0E21),
              borderRadius: BorderRadius.circular(30.0)),
          child: Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '   Send Ether',
                          style: TextStyle(
                              fontSize: 35.0, color: Color(0xFF71727E)),
                        ),
                        SizedBox(
                          width: 50.0,
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 20.0),
                              child: Image(
                                image: AssetImage('images/eth.png'),
                                height: 40.0,
                              ),
                            ),
                          ),
                        ),
                      ]),
                ),
                SizedBox(height: 40.0),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: TextField(
                    controller: myAddressController,
                    cursorColor: Colors.purple,
                    decoration: InputDecoration(
                        hintText: 'Address', border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(height: 40.0),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: TextField(
                    controller: myAmountController,
                    cursorColor: Colors.purple,
                    decoration: InputDecoration(
                        hintText: 'Amount', border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(height: 40.0),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: TextField(
                    controller: myNoteController,
                    cursorColor: Colors.purple,
                    decoration: InputDecoration(
                        hintText: 'Note',
                        border: OutlineInputBorder(),
                        helperText: 'Optional',
                        helperStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w100)),
                  ),
                ),
                SizedBox(height: 291.0),
              ],
            ),
          ),
        ),
        BottomButton(
          buttonTitle: 'Send',
          onTap: () {
            var transactionData = Map();
            transactionData['address'] = myAddressController.text;
            transactionData['amount'] =
                myAmountController.text.replaceAll(',', '.');
            transactionData['note'] = myNoteController.text;

            Navigator.pop(context, transactionData);
          },
        )
      ]),
    );
  }
}
