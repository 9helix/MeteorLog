import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meteor_log/colors.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Cell extends StatelessWidget {
  final String title;
  Cell(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(title,
          style:
              TextStyle(color: red, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class LinkCell extends StatelessWidget {
  final String title;
  final String url;
  LinkCell(this.title, this.url);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: RichText(
        text: TextSpan(
            text: title,
            style: TextStyle(
                color: red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrlString(url);
              }),
      ),
    );
  }
}

class CenteredCell extends StatelessWidget {
  final String title;
  CenteredCell(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Center(
        child: Text(title,
            style: TextStyle(
                color: red, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
