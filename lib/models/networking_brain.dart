import 'dart:convert';
import 'package:eth_wallet/views/constants/apis.dart';
import 'package:http/http.dart' as http;
import 'package:eth_wallet/models/wallet.dart';
import 'package:eth_wallet/views/constants/api_handler.dart';
import 'package:eth_wallet/models/transaction.dart';

class NetWorkingBrain {
  ApiHandler apiHandler = ApiHandler();
  double uSDPrice;

  Future getWalletNamesAndNumber() async {
    var wallets = <Wallet>[];
    var response = await http.get(apiHandler.walletsEndPoint());
    var data = json.decode(response.body) as List;
    data.forEach((wallet) {
      wallets.add(Wallet(
          mnemonic: wallet['mnemonicData']['mnemonic'],
          walletNumber: wallet['numberData']['number'],
          walletName: wallet['nameData']['name'],
          walletAddress: wallet['id']));
    });
    wallets.sort((a, b) => (a.walletNumber).compareTo(b.walletNumber));

    return wallets;
  }

  Future<double> getEthBalance(walletAddress) async {
    var response = await http.get(apiHandler.balanceEndPoint(walletAddress));
    var data = json.decode(response.body);
    var ethBalanceData = double.parse(data['balanceData']['balance']);
    return ethBalanceData;
  }

  Future getUSDPrice() async {
    var response = await http.get(apiHandler.uSDPriceURL());
    var data = json.decode(response.body);
    uSDPrice = data['quotes']['USD']['price'];
    return data['quotes']['USD']['price'];
  }

  Future perFormTransactionAndReturnNewBalance(
      walletNumber, transactionData) async {
    var newBalance = await http.post(apiHandler.sendEndPoint(), body: {
      "walletNumber": "${walletNumber}",
      "recipient": "${transactionData['address']}",
      "amount": "${transactionData['amount']}",
      "note":
          "${transactionData['note'] != null ? transactionData['note'] : 'null'}"
    });
    return newBalance;
  }

  Future createNewWallet(String name, Wallet wallet) async {
    var response = await http.post(apiHandler.createNewWalletEndPoint(),
        body: {"walletName": name, "mnemonic": "${wallet.mnemonic}"});
    var data = json.decode(response.body);
    print(data);
    return Wallet(
        walletName: data['name'] as String,
        walletNumber: data['number'] as int,
        walletAddress: data['address'] as String,
        mnemonic: data['mnemonic'] as String);
  }

  Future changeWalletName(newName, walletAddress) async {
    return await http.put(apiHandler.changeWalletNameEndPoint(walletAddress),
        body: {"newName": newName});
  }

  void deleteWallet(wallet) async {
    await http.delete(apiHandler.deleteWalletEndPoint(wallet.walletAddress));
  }

  Future getTransactions(Wallet wallet) async {
    List transactions = [];
    String URL = apiHandler.transactionsEndPoint(wallet.walletNumber);
    var response = await http.get(URL);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      var jsonList = jsonData as List;

      jsonList.sort((a, b) => (b['transactionData']['time'] as int)
          .compareTo(a['transactionData']['time'] as int));

      jsonList.forEach((transaction) {
        String direction =
            transaction['transactionData']['receivingAddress'] as String !=
                    wallet.walletAddress.toLowerCase()
                ? 'Sent'
                : 'Received';
        double transactionValueInEth =
            double.parse(transaction['transactionData']['amount']);
        double transactionValueInUSD = calculateEthToUSD(transactionValueInEth);
        String hash = transaction['transactionData']['hash'];
        int timeStamp = transaction['transactionData']['time'];
        String note = transaction['transactionData']['note'];

        transactions.add(Transaction(
            direction: direction,
            transactionValueInEth: transactionValueInEth,
            transactionValueInUSD: transactionValueInUSD,
            hash: hash,
            timeStamp: timeStamp,
            note: note));
      });
    }
    print(transactions);
    return transactions;
  }

  double calculateEthToUSD(double ethToCalculate) {
    return ethToCalculate * uSDPrice;
  }
}
