
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'detail.dart';

class Items extends StatefulWidget {
  final String jsonFileName;

  const Items({super.key, required this.jsonFileName});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  List<dynamic> jsonData = [];
  late ScrollController _horizontalScrollController;
  
  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
    _loadJSONData();
  }
  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _loadJSONData() async {
    final String jsonString = await File('data/${widget.jsonFileName.toLowerCase()}.json').readAsString();
    setState(() {
      jsonData = json.decode(jsonString);
    });
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
          children: <Widget>[
            if (jsonData.isEmpty)
              Text(
                'Loading data...'
              )
            else
              Text(
                widget.jsonFileName,
                style: TextStyle(fontSize: 24),
              ),
              Expanded(
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  child: ListView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: [
                      ...jsonData.map((item) {
                        File imageFile = File('data/images/${widget.jsonFileName.toLowerCase()}/${item['image']}');
                        double imageWidth;
                        if (widget.jsonFileName == "Locations") {
                          imageWidth = 240;
                        } else {
                          imageWidth = 120;
                        }
                        return SizedBox(
                          width: imageWidth,
                          child: TextButton(
                            onPressed: () {showDetail(item, imageFile, imageWidth);},
                            child: Column(
                              mainAxisAlignment: .center,
                              children: [
                                Text(
                                  item['name'],
                                  textAlign: .center, 
                                  style: const TextStyle(fontSize: 16)
                                ),
                                Image.file(
                                  imageFile,
                                  width: imageWidth,
                                ),
                              ]
                            )
                          )
                        );
                      })
                    ],
                  ),
                )
              )
          ],
        ),
      )
    );
  }

  void showDetail(dynamic itemData, File imageFile, double imageWidth) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Detail(
            itemData: itemData, 
            imageFile: imageFile, 
            imageWidth: imageWidth
          )
        )
      );
  }
}