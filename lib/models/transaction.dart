class Transaction {
  String direction;
  double transactionValueInEth;
  double transactionValueInUSD;
  String hash;
  int timeStamp;
  String note;

  Transaction(
      {this.direction,
      this.transactionValueInEth,
      this.transactionValueInUSD,
      this.hash,
      this.timeStamp,
      this.note});
}
