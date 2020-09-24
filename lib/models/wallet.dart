class Wallet {
  String walletName;
  int walletNumber;
  double balance;
  String walletAddress;
  var transactions = [];

  Wallet({this.walletAddress, this.walletNumber, this.walletName});

  updateBalance(newBalance) {
    this.balance = newBalance;
  }

  updateName(newName) {
    this.walletName = newName;
  }
}
