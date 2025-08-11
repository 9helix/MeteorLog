import 'package:flutter/material.dart';

class Cell extends StatelessWidget {
  final String title;
  Cell(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(title,
          style: TextStyle(
              color: Color(0xFFB71C1C),
              fontSize: 16,
              fontWeight: FontWeight.bold)),
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
                color: Color(0xFFB71C1C),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
