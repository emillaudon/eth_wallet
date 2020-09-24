import 'dart:convert';
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

  Future perFormTransactionAndReturnNewBalance(transactionData) async {
    var newBalance = await http.post(apiHandler.sendEndPoint(), body: {
      "address": "${transactionData['address']}",
      "amount": "${transactionData['amount']}",
      "note":
          "${transactionData['note'] != null ? transactionData['note'] : 'null'}"
    });
    return newBalance;
  }

  Future createNewWallet(name) async {
    var response = await http
        .post(apiHandler.createNewWalletEndPoint(), body: {"walletName": name});
    var data = json.decode(response.body);
    print(data);
    return Wallet(
        walletName: data['name'] as String,
        walletNumber: data['number'] as int,
        walletAddress: data['address'] as String);
  }

  Future getTransactions(wallet) async {
    List transactions = [];
    String URL = apiHandler.transactionsEndPoint(wallet.walletNumber);
    var response = await http.get(URL);
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
    return transactions;
  }

  double calculateEthToUSD(double ethToCalculate) {
    return ethToCalculate * uSDPrice;
  }
}
