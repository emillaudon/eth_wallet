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

  double ethUSDPrice;

  List<Wallet> wallets = [];
  List<Widget> boxes = [];
  List<Widget> walletButtons = [];

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
    drawTransactionBoxes(wallets[0]);
    initializeWalletButtons();
  }

  void updateWalletVariables(Wallet wallet) async {
    double balance = await netWorkingBrain.getEthBalance(wallet.walletAddress);
    wallet.updateBalance(balance);
    setState(() {
      currentWallet = wallet;
    });
  }

  void changeCurrentWallet(walletNumber) async {
    if (currentWallet.walletNumber != walletNumber) {
      setState(() {
        currentWallet = null;
        boxes.clear();
        boxes.insert(0, SizedBox(height: 200.0));
        boxes.insert(
            (1),
            SpinKitDoubleBounce(
              color: Colors.white,
              size: 50.0,
            ));
      });
      var balance = await netWorkingBrain
          .getEthBalance(wallets[walletNumber].walletAddress);
      wallets[walletNumber].updateBalance(balance);
      setState(() {
        currentWallet = wallets[walletNumber];
      });

      drawTransactionBoxes(currentWallet);
      //netWorkingBrain.getTransactions(wallets[walletNumber]);
    }
  }

  void initializeWalletButtons() {
    walletButtons.clear();
    walletButtons = [
      RaisedButton(
        color: Color(0xFF454A75),
        disabledColor: Color(0xFF454A75),
        child: Text(currentWallet.walletName),
        onPressed: () {
          changeCurrentWallet(0);
        },
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
          insertWalletButton(wallet);
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

  void insertWalletButton(wallet) {
    setState(() {
      walletButtons.insert(
          walletButtons.length - 1,
          RaisedButton(
            color: Color(0xFF454A75),
            disabledColor: Color(0xFF454A75),
            child: Text(wallet.walletName),
            onPressed: () {
              changeCurrentWallet(wallet.walletNumber);
            },
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text("Delete Wallet?"),
                        backgroundColor: Color(0xFF1D1E33),
                        content:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Text("Do you want to delete ${wallet.walletName}?"),
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
                              deleteWallet(wallet);
                            },
                          ),
                        ],
                        elevation: 24.0,
                      ));
            },
          ));
    });
  }

  void deleteWallet(wallet) {
    setState(() {
      wallets.remove(wallet);
      walletButtons.removeAt(wallet.walletNumber);
    });
    netWorkingBrain.deleteWallet(wallet);
  }

  Future copyAddress(context) async {
    ClipboardManager.copyToClipBoard(currentWallet.walletAddress)
        .then((result) {
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
    setState(() {
      walletButtons.insert(
          0,
          SpinKitDoubleBounce(
            color: Colors.white,
            size: 10.0,
          ));
    });
    setState(() async {
      var newWallet =
          await netWorkingBrain.createNewWallet(name, currentWallet);
      wallets.add(newWallet);
      walletButtons.removeAt(0);
      insertWalletButton(newWallet);
    });
  }

  void changeWalletName(String newName) async {
    setState(() {
      nameEditWidget = SpinKitDoubleBounce(
        color: Colors.white,
        size: 15.0,
      );
    });

    var response = await netWorkingBrain.changeWalletName(
        newName, currentWallet.walletAddress);

    print(response.statusCode);
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

      var newBalancesponse =
          await netWorkingBrain.perFormTransactionAndReturnNewBalance(
              currentWallet.walletNumber, transactionData);

      if (newBalancesponse.statusCode == 201) {
        setState(() {
          updateBalance(newBalancesponse);
        });
        drawTransactionBoxes(currentWallet);
      }
    }
  }

  void updateBalance(response) {
    var data = json.decode(response.body);
    setState(() {
      currentWallet.updateBalance(double.parse(data));
    });
  }

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

  Future<void> drawTransactionBoxes(Wallet wallet) async {
    List transactions = await netWorkingBrain.getTransactions(wallet);
    boxes.clear();
    if (transactions.length != 0) {
      transactions.forEach((transaction) {
        setState(() {
          boxes.add(SizedBox(
            height: 30.0,
          ));
          boxes.add(drawTransactionBox(transaction, boxes.length));
        });
      });
    } else {
      setState(() {
        boxes.clear();
      });
    }
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
                        GestureDetector(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 15.0),
                                Text(
                                  '${currentWallet != null ? currentWallet.walletName : "- -"}',
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
              onRefresh: () async {
                drawTransactionBoxes(currentWallet);
                var balance = await netWorkingBrain
                    .getEthBalance(currentWallet.walletAddress);
                setState(() {
                  currentWallet.updateBalance(balance);
                });
              },
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
