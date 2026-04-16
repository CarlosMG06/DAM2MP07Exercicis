import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'items.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deltarune DB'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Categories',
              style: TextStyle(fontSize: 24),
            ),
            const Row(
              children: [
                TextButton(
                  onPressed: showItems("characters"),
                  child: Text('Characters')
                ),
                TextButton(
                  onPressed: showItems("locations"),
                  child: Text('Locations')
                ),
                TextButton(
                  onPressed: showItems("songs"),
                  child: Text('Songs')
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
  
  VoidCallback? showItems(String dataToShow) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Items(dataToShow)),
      );
  }
}