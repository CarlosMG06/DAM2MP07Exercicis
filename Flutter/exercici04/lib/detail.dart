
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
class Detail extends StatefulWidget {
  final dynamic itemData;
  final File imageFile;
  final double imageWidth;

  const Detail({super.key, required this.itemData, required this.imageFile, required this.imageWidth});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail>{
  late dynamic item;
  late File imageFile;
  late double imageWidth;

  @override
  void initState() {
    super.initState();
    item = widget.itemData;
    imageFile = widget.imageFile;
    imageWidth = widget.imageWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Deltarune DB')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(item["name"], style: TextStyle(fontSize: 24)),
            Image.file(
              imageFile,
              width: imageWidth
            ),
            SizedBox(
              width: 400,
              child: Text(item["description"])
            )
          ],
        )
      )
    );
  }

}