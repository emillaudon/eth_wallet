import 'send_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../widgets/transaction_box.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/bottom_button.dart';
import '../constants/apis.dart';
import 'package:clipboard_manager/clipboard_manager.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> boxes = [];
  double ethBalance;
  double ethUSDPrice;
  String address = walletAddress;
  String uSDPriceURL = 'https://api.coinpaprika.com/v1/tickers/eth-ethereum';

  @override
  void initState() {
    super.initState();
    boxes.insert(0, SizedBox(height: 200.0));
    boxes.insert(
        (1),
        SpinKitDoubleBounce(
          color: Colors.white,
          size: 50.0,
        ));
    initialize();
  }

  onTransactionBoxTap(int index) {
    print('tes ${index}');
    TransactionBox transactionBox = boxes[index];
    print(transactionBox.getNote());
    setState(() {
      transactionBox.setNote(' ');
    });
    print(transactionBox.note);
  }

  void initialize() async {
    await getEthBalance();
    await getAndUpdateUSDPrice();
    drawTransactionBoxes();
  }

  void getEthBalance() async {
    var response = await http.get(balanceEndPoint);
    var data = json.decode(response.body);
    var ethBalanceData = double.parse(data['balanceData']['balance']);
    ethBalance = ethBalanceData;
  }

  void getAndUpdateUSDPrice() async {
    var response = await http.get(uSDPriceURL);
    var data = json.decode(response.body);
    print(data['quotes']['USD']['price']);
    ethUSDPrice = data['quotes']['USD']['price'];
  }

  Future copyAddress(context) async {
    ClipboardManager.copyToClipBoard(walletAddress).then((result) {
      final snackBar = SnackBar(
        content: Text(
          'Address Copied to Clipboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {},
        ),
      );

      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  void sendButtonPressed() async {
    var transactionData =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SendPage();
    }));
    if (transactionData != null) {
      setState(() {
        boxes.insert(
            (0),
            SpinKitDoubleBounce(
              color: Colors.white,
              size: 50.0,
            ));
        boxes.insert((0), Center(child: Text('Sending...')));
      });

      print(boxes.length);
      print('clicked');

      var response = await http.post(sendEndPoint, body: {
        "address": "${transactionData['address']}",
        "amount": "${transactionData['amount']}",
        "note":
            "${transactionData['note'] != null ? transactionData['note'] : 'null'}"
      });

      if (response.statusCode == 201) {
        setState(() {
          updateBalance(response);
        });
        drawTransactionBoxes();
      }
    }
  }

  void updateBalance(response) {
    var data = json.decode(response.body);
    setState(() {
      ethBalance = double.parse(data);
    });
  }

  Future getJsonData() async {
    String URL = transactionsEndPoint;
    var response = await http.get(URL);
    var data = json.decode(response.body);
    return data;
  }

  double calculateEthToUSD(double ethToCalculate) {
    return ethToCalculate * ethUSDPrice;
  }

  void drawTemporaryTransactionBox(double value) {
    boxes.insert(0, SizedBox(height: 30.0));
  }

  Widget drawTransactionBox(direction, transactionValueInEth,
      transactionValueInUSD, hash, timeStamp, note, index) {
    return TransactionBox(direction, transactionValueInEth,
        transactionValueInUSD, hash, timeStamp, note, index);
  }

  Future<void> drawTransactionBoxes() async {
    var jsonData = await getJsonData();
    var jsonList = jsonData as List;

    jsonList.sort((a, b) => (b['transactionData']['time'] as int)
        .compareTo(a['transactionData']['time'] as int));
    setState(() {
      boxes.clear();
    });

    jsonList.forEach((transaction) {
      String direction =
          transaction['transactionData']['receivingAddress'] as String !=
                  walletAddress.toLowerCase()
              ? 'Sent'
              : 'Received';
      double transactionValueInEth =
          double.parse(transaction['transactionData']['amount']);
      double transactionValueInUSD = calculateEthToUSD(transactionValueInEth);
      String hash = transaction['transactionData']['hash'];
      int timeStamp = transaction['transactionData']['time'];
      String note = transaction['transactionData']['note'];
      setState(() {
        boxes.add(SizedBox(
          height: 30.0,
        ));
        boxes.add(drawTransactionBox(direction, transactionValueInEth,
            transactionValueInUSD, hash, timeStamp, note, boxes.length));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Image(
                      image: AssetImage('images/eth.png'),
                      height: 90.0,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'My Wallet',
                          style: TextStyle(
                              fontSize: 25.0, color: Color(0xFF8D8E98)),
                        ),
                        Text(
                          '${ethBalance != null ? ethBalance.toStringAsFixed(2) : "- -"} Eth',
                          style: TextStyle(
                              fontSize: 21.0, color: Color(0xFF71727E)),
                        ),
                        Text(
                          '${ethBalance != null ? calculateEthToUSD(ethBalance).toStringAsFixed(2) : "- -"} USD',
                          style: TextStyle(
                              fontSize: 21.0, color: Color(0xFF71727E)),
                        ),
                        SizedBox(height: 5.0),
                        Builder(
                          builder: (ctx) => GestureDetector(
                            onTap: () async {
                              copyAddress(ctx);
                            },
                            child: Center(
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Copy Address',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic),
                                    ),
                                    Icon(
                                      Icons.content_copy,
                                      size: 12.0,
                                      color: Colors.grey,
                                    )
                                  ]),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ]),
            height: 200.0,
            decoration: BoxDecoration(
              color: Color(0xFF0A0E21),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => drawTransactionBoxes(),
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: boxes.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    print(index);
                    return boxes[index];
                  }),
            ),
          ),
          BottomButton(
            onTap: () async {
              sendButtonPressed();
            },
            buttonTitle: 'SEND ETH',
          ),
        ],
      ),
    );
  }
}

/*
ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: boxes.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return boxes[index];
                }),


                ListView(
              padding: EdgeInsets.zero,
              children: boxes.toList(),
            ),
 */
