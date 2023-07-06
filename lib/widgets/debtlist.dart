import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtracket_project/debts.dart';
import 'package:dtracket_project/editpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:quickalert/quickalert.dart';

class DebtList extends StatefulWidget {
  const DebtList({super.key, required this.debts});

  final Debts debts;

  @override
  State<DebtList> createState() => _DebtListState();
}

class _DebtListState extends State<DebtList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        leading: debtavatar(widget.debts.debt_pic),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.debts.name,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Amount to pay: ',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    Text(
                      '${widget.debts.totalAmount}',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ],
            ),
            //Text('11/22/22'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditPage(
                          debts: widget.debts,
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    dialogShow(widget.debts.id);
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          ListTile(
            title: Text('Name: ${widget.debts.name}',
                style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            title: Text('Borrowed: ${widget.debts.debt}',
                style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            title: Text('Interest: ${widget.debts.interest}%',
                style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            title: Text('Total Amount to pay: ${widget.debts.totalAmount}',
                style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            title: Text('Due Date: ${widget.debts.dueDate}',
                style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            title: Text('Contact Number: ${widget.debts.contactnumber}',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void dialogShow(String id) => Dialogs.bottomMaterialDialog(
          msg: 'Are you sure? you can\'t undo this action',
          title: 'Delete Confirmation',
          context: context,
          actions: [
            IconsOutlineButton(
              onPressed: () {
                Navigator.pop(context);
              },
              text: 'Cancel',
              iconData: Icons.cancel_outlined,
              textStyle: TextStyle(color: Colors.grey),
              iconColor: Colors.grey,
            ),
            IconsButton(
              onPressed: () {
                deleteDebt(id);
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.success,
                  text: 'Deleted Successfully!',
                );
              },
              text: 'Delete',
              iconData: Icons.delete,
              color: Colors.red,
              textStyle: TextStyle(color: Colors.white),
              iconColor: Colors.white,
            ),
          ]);

  deleteDebt(String id) {
    final docPerson = FirebaseFirestore.instance.collection('Persons').doc(id);
    docPerson.delete();
    Navigator.pop(context);
  }

  Color color = const Color(0xFF30336b);
  Color colortitle = const Color(0xFFffdf7b);

  Widget debtavatar(avatar) => Container(
        width: 40.0,
        height: 40.0,
        padding: const EdgeInsets.all(2.0), // borde width
        decoration: new BoxDecoration(
          border: Border.all(
            width: 1,
            color: colortitle,
          ),
          //color: const Color(0xFFFFFFFF), // border color
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          //foregroundColor: Colors.white,
          //backgroundColor: Colors.blue ,
          radius: 18,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage((avatar == "")
              ? "https://image.pngaaa.com/117/4811117-small.png"
              : avatar),
        ),
      );
}
