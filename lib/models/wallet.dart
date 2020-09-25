class Wallet {
  String walletName;
  String walletAddress;
  String mnemonic;

  int walletNumber;
  double balance;

  var transactions = [];

  Wallet(
      {this.walletAddress, this.walletNumber, this.walletName, this.mnemonic});

  updateBalance(newBalance) {
    this.balance = newBalance;
  }

  updateName(newName) {
    this.walletName = newName;
  }
}
