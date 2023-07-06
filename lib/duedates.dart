import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtracket_project/debts.dart';
import 'package:dtracket_project/editpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:quickalert/quickalert.dart';

class DuePage extends StatefulWidget {
  const DuePage({super.key});

  @override
  State<DuePage> createState() => _DuePageState();
}

class _DuePageState extends State<DuePage> {
  final currentUser = FirebaseAuth.instance;
  static DateTime now = new DateTime.now();
  String formatter = DateFormat('MM/dd/yyyy').format(now);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: ListView(
        children: [
          container(),
        ],
      ),
    );
  }

  Widget container() => ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          topbar(),
          dues(),
        ],
      );

  Widget topbar() => Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(60),
            bottomRight: Radius.circular(60),
          ),
        ),
        child: Column(
          children: [
            Text("Today's Due Dates",
                style: TextStyle(color: Colors.white, fontSize: 26)),
          ],
        ),
      );

  Stream<List<Debts>> readDueDate(due) => FirebaseFirestore.instance
      .collection('Persons')
      .where('user_id', isEqualTo: currentUser.currentUser!.uid)
      .where('dueDate', isEqualTo: due)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Debts.fromJson(
                doc.data(),
              ),
            )
            .toList(),
      );

  Container dues() {
    return Container(
      //height: 300,
      child: displayDueDates(formatter),
    );
  }

  Widget displayDueDates(due) => Container(
        child: StreamBuilder<List<Debts>>(
          stream: readDueDate(due),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong! ${snapshot.error}');
            } else if (snapshot.hasData) {
              final debts = snapshot.data!;

              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text('No Due Dates Today'),
                  ),
                );
              } else {
                return ListView(
                  shrinkWrap: true,
                  children: debts.map(debtlists).toList(),
                );
              }
            } else if (!snapshot.hasData) {
              return Center(child: Text('No Due Dates today'));
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      );

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

  Color color = const Color(0xFF30336b);
  Color colortitle = const Color(0xFFffdf7b);

  Widget debtlists(Debts debts) => Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          leading: debtavatar(debts.debt_pic),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debts.name,
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
                        '${debts.totalAmount}',
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
                            debts: debts,
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
                      dialogShow(debts.id);
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
              title: Text('Name: ${debts.name}',
                  style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: Text('Borrowed: ${debts.debt}',
                  style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: Text('Interest: ${debts.interest}%',
                  style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: Text('Total Amount to pay: ${debts.totalAmount}',
                  style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: Text('Due Date: ${debts.dueDate}',
                  style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: Text('Contact Number: ${debts.contactnumber}',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
  deleteDebt(String id) {
    final docPerson = FirebaseFirestore.instance.collection('Persons').doc(id);
    docPerson.delete();
    Navigator.pop(context);
  }
}
