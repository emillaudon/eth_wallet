import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  String mnemonic = '';
  List mnemonicWords = [];

  @override
  void initState() {
    super.initState();
    var wordPaid = WordPair.random();
    mnemonic = wordPaid.asLowerCase;
  }

  Text generateTextBoxes(int index) {
    return mnemonicWords[index];
  }

  void generateMnemonic() {
    String newMnemonic = '';
    for (int i = 0; i < 12; i++) {
      var wordPair = WordPair.random();
      String nmnemonic = wordPair.asPascalCase;
      newMnemonic += " ${nmnemonic}";
      mnemonicWords.add(Text(
        nmnemonic,
        style: TextStyle(fontSize: 20.0),
      ));
    }
    setState(() {
      mnemonic = newMnemonic;
      print(mnemonic);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 150.0),
            Center(
              child: Container(
                child: Text(mnemonic),
                height: 300.0,
                width: 380.0,
                decoration: BoxDecoration(
                    color: Color(0xFF0A0E21),
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
              ),
            ),
            SizedBox(height: 50.0),
            ButtonTheme(
              height: 50,
              minWidth: 200.0,
              child: RaisedButton(
                color: Color(0xFF454A75),
                disabledColor: Color(0xFF454A75),
                child: Text(
                  'Generate Mnemonic',
                  style: TextStyle(fontSize: 20.0),
                ),
                onPressed: () {
                  setState(() {
                    generateMnemonic();
                  });
                },
              ),
            ),
            SizedBox(height: 25.0),
            ButtonTheme(
              height: 50,
              minWidth: 200.0,
              child: RaisedButton(
                color: Color(0xFF454A75),
                disabledColor: Color(0xFF454A75),
                child: Text(
                  'Accept',
                  style: TextStyle(fontSize: 20.0),
                ),
                onPressed: () {
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
