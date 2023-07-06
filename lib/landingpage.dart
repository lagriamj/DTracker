import 'package:dtracket_project/addpage.dart';
import 'package:dtracket_project/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:quickalert/quickalert.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    //Future.delayed(Duration.zero, () => loginSuccess());
    return Container(
      decoration: BoxDecoration(
        color: color,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dtracker',
                              style: GoogleFonts.robotoMono(
                                fontSize: 26,
                                letterSpacing: 1.0,
                                color: color,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Welcome!',
                              style: GoogleFonts.robotoMono(
                                fontSize: 30,
                                letterSpacing: 1.0,
                                color: color,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          ],
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          margin: EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/applogo.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: Lottie.asset('assets/images/lazydog.json',
                      height: 200, width: 200),
                ),
                /*SizedBox(
                  height: 250,
                ),*/
                Column(
                  children: [
                    Text(
                      'Welcome',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    Text(
                      '${user.email}!',
                      style: TextStyle(color: colortitle, fontSize: 24),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: 300,
                  margin: const EdgeInsets.only(top: 15, bottom: 10),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => AddPage()));
                    },
                    icon: Icon(
                      Icons.edit,
                      color: color,
                    ),
                    label: Text(
                      "Add New",
                      style: TextStyle(
                        //fontWeight: FontWeight.w900,
                        color: color,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  margin: const EdgeInsets.only(top: 5, bottom: 10),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => HomePage()));
                    },
                    icon: Icon(
                      Icons.list_rounded,
                      color: color,
                    ),
                    label: Text(
                      "View List",
                      style: TextStyle(
                        //fontWeight: FontWeight.w900,
                        color: color,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  margin: const EdgeInsets.only(top: 5, bottom: 10),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: () {
                      dialogShow();
                    },
                    icon: Icon(
                      Icons.logout_rounded,
                      color: color,
                    ),
                    label: Text(
                      "Logout",
                      style: TextStyle(
                        //fontWeight: FontWeight.w900,
                        color: color,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color color = const Color(0xFF30336b);
  Color colortitle = const Color(0xFFffdf7b);

  Widget btn(label, icon) => Container(
        width: 300,
        margin: const EdgeInsets.only(top: 15, bottom: 10),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            backgroundColor: colortitle,
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          onPressed: () {
            //updateDebts(widget.debts.id);
            //uploadFile();
          },
          icon: Icon(
            icon,
            color: color,
          ),
          label: Text(
            label,
            style: TextStyle(
              //fontWeight: FontWeight.w900,
              color: color,
              fontSize: 18,
            ),
          ),
        ),
      );

  void loginSuccess() => QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: 'Logged In Successfully!',
      );

  void dialogShow() => Dialogs.materialDialog(
          msg: 'Are you sure? you can\'t undo this action',
          title: 'Logout Confirmation',
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
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.success,
                  text: 'Logged Out Successfully!',
                );
              },
              text: 'Logout',
              iconData: Icons.logout_rounded,
              color: Colors.red,
              textStyle: TextStyle(color: Colors.white),
              iconColor: Colors.white,
            ),
          ]);
}
