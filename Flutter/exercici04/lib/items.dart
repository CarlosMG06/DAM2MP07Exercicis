
import 'package:flutter/material.dart';

class Items extends StatefulWidget {
  const Items(this.dataToShow, {super.key});

  final String dataToShow;

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deltarune DB'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Items',
              style: TextStyle(fontSize: 24),
            ),
            // Get items from json and show them in a list
            Lis
          ],
        ),
      )
    );
  }
}