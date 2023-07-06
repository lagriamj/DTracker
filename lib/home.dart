import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtracket_project/addpage.dart';
import 'package:dtracket_project/debts.dart';
import 'package:dtracket_project/dueDates.dart';
import 'package:dtracket_project/updateprofile.dart';
//import 'package:dtracket_project/editpage.dart';
import 'package:dtracket_project/user.dart';
import 'package:dtracket_project/widgets/debtlist.dart';
//
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:quickalert/quickalert.dart';

import 'editpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //final FirebaseAuth auth = FirebaseAuth.instance;
  final currentUser = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  late DateTime _selectedDate;
  static DateTime now = new DateTime.now();
  String formatter = DateFormat('MM/dd/yyyy').format(now);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //image = "";
    //print('Due Date-->: ${formatter}');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Users? users;
    //final user = FirebaseAuth.instance.currentUser!;
    //DocumentReference doc_ref = FirebaseFirestore.instance.collection(''
    final user = FirebaseAuth.instance.currentUser!;
    Future.delayed(Duration.zero,
        () => showDueDateDialog(BuildContext, context, formatter));
    Future.delayed(Duration.zero, () => print('DUE DATE:--> ${formatter}'));
    return Scaffold(
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                displayUser(),
              ],
            ),
          ),
        ),
        //backgroundColor: color,
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
        ),
        elevation: 0,
        actions: [
          Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu),
            );
          }),
        ],
      ),
      /*floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddPage(),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),*/
      body: StreamBuilder<List<Users>>(
        stream: readUser(currentUser.currentUser!.email),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final debts = snapshot.data!;

            return ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: debts.map(homepage).toList(),
            );
          } else {
            return Center(
              child: SpinKitPouringHourGlassRefined(
                size: 60,
                color: colortitle,
              ),
            );
          }
        },
      ),
    );
  }

  Widget drawerList(Users user) => Container(
        padding: EdgeInsets.only(top: 15),
        child: Column(
          children: [
            menuItem(user),
          ],
        ),
      );

  Widget menuItem(Users user) => Material(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Container(
            margin: EdgeInsets.only(left: 20),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => DuePage()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 22,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text("Due Date",
                          style: TextStyle(color: Colors.black, fontSize: 20)),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProfilUpdate(users: user)));
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 22,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text("Profile",
                          style: TextStyle(color: Colors.black, fontSize: 20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget profile(Users user) => Material(
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfilUpdate(users: user)));
          },
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Container(
              margin: EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 22,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text("Profile",
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                ],
              ),
            ),
          ),
        ),
      );

  Widget drawer(Users user) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: color,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                profileavatar(user.image),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(user.name,
                            style:
                                TextStyle(color: Colors.white, fontSize: 24)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Text(user.email,
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                SizedBox(height: 5),
                Text(user.contactnumber,
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                SizedBox(height: 20),
              ],
            ),
          ),
          drawerList(user)
        ],
      );

  Widget displayUser() => Container(
        child: StreamBuilder<List<Users>>(
          stream: readUser(currentUser.currentUser!.email),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong! ${snapshot.error}');
            } else if (snapshot.hasData) {
              final users = snapshot.data!;

              return ListView(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                children: users.map(drawer).toList(),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );

  Widget homepage(Users user) => ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          topbar(user),
          horizItem(user),
          containerItem(user),
          SizedBox(height: 20),
        ],
      );

  Container containerItem(user) {
    return Container(
      width: 360,
      //height: 600,
      padding: const EdgeInsets.only(bottom: 20),
      child: displaydebts(user),
    );
  }

  Container horizItem(user) {
    return Container(
      height: 100,
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        //color: color,
        border: Border(
          bottom: BorderSide(
            color: color,
            width: 1,
          ),
        ),
        //borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: ListView(
        //shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(width: 3),
          Container(
            height: 65,
            width: 65,
            child: FloatingActionButton(
              backgroundColor: color,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddPage(),
                  ),
                );
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 5),
          displayDebtsPic(user),
        ],
      ),
    );
  }

  Widget displaydebts(user) => Container(
        child: StreamBuilder<List<Debts>>(
          stream: readDebts(user),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong! ${snapshot.error}');
            } else if (snapshot.hasData) {
              final users = snapshot.data!;
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text('No Entries Yet'),
                  ),
                );
              } else {
                return ListView(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  children: users.map(debtlists).toList(),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );

  Widget topbar(Users user) => Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.only(bottom: 30, left: 10, right: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(60),
            bottomRight: Radius.circular(60),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dashboard",
                          style: TextStyle(color: Colors.white, fontSize: 34)),
                    ],
                  ),
                ),
                SizedBox(width: 30),
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfilUpdate(users: user)));
                    },
                    child: profileImg(user.image),
                  ),
                ),
              ],
            ),
            //Image.asset('assets/images/applogo.png', height: 100, width: 100),
          ],
        ),
      );

  Widget profileavatar(avatar) => Container(
        width: 100.0,
        height: 100.0,
        margin: EdgeInsets.only(left: 10),
        padding: const EdgeInsets.all(2.0), // borde width
        decoration: new BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.white,
          ),
          //color: const Color(0xFFFFFFFF), // border color
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          //foregroundColor: Colors.white,
          //backgroundColor: Colors.blue ,
          radius: 18,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(avatar),
        ),
      );

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

  Stream<List<Debts>> readDebts(users) => FirebaseFirestore.instance
      //.where('id', isEqualTo: currentUser.currentUser!.uid)
      .collection('Persons')
      .where('user_id', isEqualTo: currentUser.currentUser!.uid)
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

  void showDueDateDialog(BuildContext, context, due) => Dialogs.materialDialog(
          context: context,
          color: Colors.white,
          msg: 'People who have due dates today',
          title: 'Due Date',
          actions: [
            Column(
              children: [
                dues(due),
                Container(
                  width: 100,
                  child: IconsButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: 'Close',
                    iconData: Icons.close,
                    color: Colors.red,
                    textStyle: TextStyle(color: Colors.white),
                    iconColor: Colors.white,
                  ),
                ),
              ],
            ),
          ]);

  Container dues(due) {
    return Container(
      //height: 300,
      child: displayDueDates(due),
    );
  }

  Widget dueDateList(Debts debts) => Container(
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${debts.name}',
                  style: TextStyle(color: Colors.black)),
              Row(
                children: [
                  Text('Amount to pay: '),
                  Text('${debts.totalAmount}',
                      style: TextStyle(color: Colors.red))
                ],
              ),
            ],
          ),
        ),
      );

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
                  children: debts.map(dueDateList).toList(),
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

  Widget profileImg(image) => Container(
        width: 70.0,
        height: 70.0,
        padding: const EdgeInsets.all(2.0), // borde width
        decoration: new BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.white,
          ),
          //color: const Color(0xFFFFFFFF), // border color
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          //foregroundColor: Colors.white,
          //backgroundColor: Colors.blue ,
          radius: 18,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage((image == "")
              ? "https://www.pngitem.com/pimgs/m/150-1503945_transparent-user-png-default-user-image-png-png.png"
              : image),
        ),
      );

  Stream<List<Users>> readUser(email) => FirebaseFirestore.instance
      .collection('Users')
      .where('email', isEqualTo: email)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => Users.fromJson(
                doc.data(),
              ),
            )
            .toList(),
      );

  Widget profileImg1(Debts debts) => GestureDetector(
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => EditPage(debts: debts)));
        },
        child: Container(
          width: 65.0,
          height: 65.0,
          padding: const EdgeInsets.all(2.0), // borde width
          decoration: new BoxDecoration(
            border: Border.all(
              width: 1,
              color: color,
            ),
            //color: const Color(0xFFFFFFFF), // border color
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            //foregroundColor: Colors.white,
            //backgroundColor: Colors.blue ,
            radius: 18,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage((debts.debt_pic == "")
                ? "https://image.pngaaa.com/117/4811117-small.png"
                : debts.debt_pic),
          ),
        ),
      );

  Widget horizDebtList(Debts debts) => Container(
        margin: EdgeInsets.symmetric(horizontal: 3),
        child: profileImg1(debts),
      );

  Widget displayDebtsPic(user) => Container(
        child: StreamBuilder<List<Debts>>(
          stream: readDebts(user),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong! ${snapshot.error}');
            } else if (snapshot.hasData) {
              final users = snapshot.data!;

              return ListView(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: users.map(horizDebtList).toList(),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );

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
}
