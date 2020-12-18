import 'package:flutter/material.dart';
import '../web_detail.dart';
import '../call_to_action/call_to_action.dart';

class HomeContentsDesktop extends StatelessWidget {
  final Function endDrawer;

  HomeContentsDesktop(this.endDrawer);
  @override
  Widget build(BuildContext context) {
    Function dummy;
    return SingleChildScrollView(
          child: Column(
          children: [
            Row(
              children: [
                WebDetail(),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CallToAction('Join Waiting',dummy),
                    SizedBox(
                      height: 30,
                    ),
                    CallToAction('   Chating    ', endDrawer),
                  ],
                ))
              ],
            ),
          ],
       
      ),
    );
  }
}
