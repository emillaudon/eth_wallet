import 'package:eth_wallet/views/constants/apis.dart';

import 'send_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../widgets/transaction_box.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/bottom_button.dart';
import '../constants/api_handler.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:eth_wallet/models/wallet.dart';
import 'package:eth_wallet/models/networking_brain.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NetWorkingBrain netWorkingBrain = NetWorkingBrain();
  Wallet currentWallet;

  //double ethBalance;
  double ethUSDPrice;

  //String address;
  //String walletName = '- -';

  List<Wallet> wallets = [];
  List<Widget> boxes = [];
  List<Widget> walletButtons = [];
  //int walletNumber;

  //String uSDPriceURL = 'https://api.coinpaprika.com/v1/tickers/eth-ethereum';
  Widget nameEditWidget = Icon(
    Icons.edit,
    size: 15.0,
    color: Colors.grey,
  );

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

  void initialize() async {
    wallets = await netWorkingBrain.getWalletNamesAndNumber();
    ethUSDPrice = await netWorkingBrain.getUSDPrice();
    await updateWalletVariables(wallets[0]);
    //ethBalance = await netWorkingBrain.getEthBalance(wallets[0].walletAddress);
    drawTransactionBoxes(wallets[0]);
    initializeWalletButtons();
  }

  void updateWalletVariables(wallet) async {
    double balance = await netWorkingBrain.getEthBalance(wallet.walletAddress);
    wallet.updateBalance(balance);
    setState(() {
      currentWallet = wallet;
      //walletName = currentWallet.walletName;
    });
  }

  void initializeWalletButtons() {
    walletButtons.clear();
    walletButtons = [
      RaisedButton(
        color: Color(0xFF454A75),
        disabledColor: Color(0xFF454A75),
        child: Text(currentWallet.walletName),
        onPressed: () {},
      ),
      RaisedButton(
          color: Color(0xFF454A75),
          disabledColor: Color(0xFF454A75),
          child: Icon(Icons.add),
          onPressed: () {
            var myNameController = TextEditingController();
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text("Create New Wallet"),
                      backgroundColor: Color(0xFF1D1E33),
                      content:
                          Column(mainAxisSize: MainAxisSize.min, children: [
                        Text("Choose Name of new Wallet, maximum 9 letters."),
                        TextField(
                          controller: myNameController,
                          maxLength: 9,
                          decoration: InputDecoration(hintText: 'Name'),
                        )
                      ]),
                      actions: [
                        FlatButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                        FlatButton(
                          child: Text('Accept'),
                          onPressed: () {
                            Navigator.pop(context);
                            createNewWalletWithName(myNameController.text);
                            myNameController.dispose();
                          },
                        ),
                      ],
                      elevation: 24.0,
                    ));
          })
    ];
    if (wallets.length > 0) {
      wallets.forEach((wallet) {
        if (wallet.walletNumber != 0) {
          insertWalletButton(wallet.walletName);
        }
      });
    }
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

  /*
  void getWalletNamesAndNumber() async {
    var response = await http.get(walletsEndPoint);
    var data = json.decode(response.body) as List;
    data.forEach((wallet) {
      wallets.add(Wallet(
          walletNumber: wallet['numberData']['number'],
          walletName: wallet['nameData']['name'],
          walletAddress: wallet['id']));
    });
    wallets.sort((a, b) => (a.walletNumber).compareTo(b.walletNumber));

    walletName = wallets[0].walletName;
  }
   */

  /*
  void getEthBalance() async {
    //TODO: use wallet number
    var response = await http.get(balanceEndPoint);i
    var data = json.decode(response.body);
    var ethBalanceData = double.parse(data['balanceData']['balance']);
    ethBalance = ethBalanceData;
  }
   */
/*
  void getAndUpdateUSDPrice() async {
    var response = await http.get(uSDPriceURL);
    var data = json.decode(response.body);
    ethUSDPrice = data['quotes']['USD']['price'];
  }

 */

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

  void createNewWalletWithName(String name) {
    setState(() async {
      var newWallet = await netWorkingBrain.createNewWallet(name);
      wallets.add(newWallet);
      insertWalletButton(newWallet.walletName);
    });
  }

  void insertWalletButton(name) {
    setState(() {
      walletButtons.insert(
          walletButtons.length - 1,
          RaisedButton(
            color: Color(0xFF454A75),
            disabledColor: Color(0xFF454A75),
            child: Text(name),
            onPressed: () {},
          ));
    });
  }

  void changeWalletName(String newName) async {
    setState(() {
      nameEditWidget = SpinKitDoubleBounce(
        color: Colors.white,
        size: 15.0,
      );
    });

    var response =
        await http.put(changeWalletNameEndPoint, body: {"newName": newName});

    if (response.statusCode == 200) {
      setState(() {
        currentWallet.updateName(newName);
      });

      setState(() {
        nameEditWidget = Icon(
          Icons.edit,
          size: 15.0,
          color: Colors.grey,
        );
        initializeWalletButtons();
      });
    }
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

      var newBalancesponse = await netWorkingBrain
          .perFormTransactionAndReturnNewBalance(transactionData);

      if (newBalancesponse.statusCode == 201) {
        setState(() {
          updateBalance(newBalancesponse);
        });
        drawTransactionBoxes(wallets[0].walletNumber);
      }
    }
  }

  void updateBalance(response) {
    var data = json.decode(response.body);
    setState(() {
      currentWallet.updateBalance(double.parse(data));
    });
  }

  /*
  Future getJsonData() async {
    String URL = transactionsEndPoint;
    var response = await http.get(URL);
    var data = json.decode(response.body);
    return data;
  }
   */

  double calculateEthToUSD(double ethToCalculate) {
    return ethToCalculate * ethUSDPrice;
  }

  void drawTemporaryTransactionBox(double value) {
    boxes.insert(0, SizedBox(height: 30.0));
  }

  Widget drawTransactionBox(transaction, index) {
    return TransactionBox(
        transaction.direction,
        transaction.transactionValueInEth,
        transaction.transactionValueInUSD,
        transaction.hash,
        transaction.timeStamp,
        transaction.note,
        index);
  }

  Future<void> drawTransactionBoxes(wallet) async {
    List transactions = await netWorkingBrain.getTransactions(wallet);
    boxes.clear();
    transactions.forEach((transaction) {
      setState(() {
        boxes.add(SizedBox(
          height: 30.0,
        ));
        boxes.add(drawTransactionBox(transaction, boxes.length));
      });
    });
  }

  /*
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

   */

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
                        GestureDetector(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 15.0),
                                Text(
                                  '${currentWallet != null ? currentWallet.balance.toStringAsFixed(2) : "- -"}',
                                  style: TextStyle(
                                      fontSize: 25.0, color: Color(0xFF8D8E98)),
                                ),
                                nameEditWidget,
                              ]),
                          onTap: () {
                            var myNameController = TextEditingController();
                            setState(() {
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                        title: Text("Change Name"),
                                        backgroundColor: Color(0xFF1D1E33),
                                        content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                  "Change Name of Wallet, maximum 9 letters."),
                                              TextField(
                                                controller: myNameController,
                                                maxLength: 9,
                                                decoration: InputDecoration(
                                                    hintText: 'New Name'),
                                              )
                                            ]),
                                        actions: [
                                          FlatButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }),
                                          FlatButton(
                                            child: Text('Accept'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              changeWalletName(
                                                  myNameController.text);
                                              myNameController.dispose();
                                            },
                                          ),
                                        ],
                                        elevation: 24.0,
                                      ));
                            });
                          },
                        ),
                        Text(
                          '${currentWallet != null ? currentWallet.balance.toStringAsFixed(2) : "- -"} Eth',
                          style: TextStyle(
                              fontSize: 21.0, color: Color(0xFF71727E)),
                        ),
                        Text(
                          '${currentWallet != null ? calculateEthToUSD(currentWallet.balance).toStringAsFixed(2) : "- -"} USD',
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
                    child: Container(
                        height: 150.0,
                        child: Center(
                            child: Container(
                          width: 100.0,
                          child: ListView.builder(
                              padding: EdgeInsets.only(top: 10.0),
                              itemCount: walletButtons.length,
                              itemBuilder: (BuildContext ctxt, int index) {
                                print(index);
                                return walletButtons[index];
                              }),
                        ))),
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
              onRefresh: () => drawTransactionBoxes(wallets[0].walletNumber),
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
