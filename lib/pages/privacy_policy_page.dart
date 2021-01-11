import 'package:ahmed_app/constants.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: AppBar(
                title: Text('Privacy Policy'),
                elevation: menuElevation,
                shape: appBarShape,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(8),
                shrinkWrap: true,
                children: [Text(privacyPolicy)],
              ),
            )
          ],
        ),
      ),
    );
  }
}
