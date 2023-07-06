class Debts {
  String id;
  String user_id;
  final String name;
  final num debt;
  final num interest;
  final num totalAmount;
  final String dueDate;
  final String debt_pic;
  final String contactnumber;

  Debts({
    required this.id,
    required this.user_id,
    required this.name,
    required this.debt,
    required this.interest,
    required this.totalAmount,
    required this.dueDate,
    required this.debt_pic,
    required this.contactnumber,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': user_id,
        'name': name,
        'debt': debt,
        'interest': interest,
        'totalAmount': totalAmount,
        'dueDate': dueDate,
        'debt_pic': debt_pic,
        'contactnumber': contactnumber,
      };

  static Debts fromJson(Map<String, dynamic> json) => Debts(
        id: json['id'],
        user_id: json['user_id'],
        name: json['name'],
        debt: json['debt'],
        interest: json['interest'],
        totalAmount: json['totalAmount'],
        dueDate: json['dueDate'],
        debt_pic: json['debt_pic'],
        contactnumber: json['contactnumber'],
      );
}
