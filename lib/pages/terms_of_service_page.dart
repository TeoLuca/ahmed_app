import 'package:ahmed_app/constants.dart';
import 'package:flutter/material.dart';

class TermsOfServicePage extends StatefulWidget {
  @override
  _TermsOfServicePageState createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: AppBar(
                title: Text('Terms of Service'),
                elevation: menuElevation,
                shape: appBarShape,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(8),
                shrinkWrap: true,
                children: [Text(termsOfService)],
              ),
            )
          ],
        ),
      ),
    );
  }
}
