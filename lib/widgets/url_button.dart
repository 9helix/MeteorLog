import 'package:flutter/material.dart';
import 'package:meteor_log/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlButton extends StatefulWidget {
  const UrlButton({super.key});

  @override
  State<UrlButton> createState() => _UrlButtonState();
}

class _UrlButtonState extends State<UrlButton> {
  //Observation upload link
  Uri _url = Uri.parse(
      'https://www.imo.net/members/imo_observation/upload_observation');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _launchUrl,
      style: TextButton.styleFrom(
        foregroundColor: red, // foreground
      ),
      child: Text("SUBMIT", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
