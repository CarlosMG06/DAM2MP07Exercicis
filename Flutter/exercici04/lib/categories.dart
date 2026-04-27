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
        title: Center(child: Text('Deltarune DB')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: <Widget>[
            const Text(
              'Categories',
              style: TextStyle(fontSize: 24),
            ),
            Row(
              mainAxisAlignment: .center,
              children: [
                TextButton(
                  onPressed: () {showItems('Characters');},
                  child: const Text('Characters')
                ),
                TextButton(
                  onPressed: () {showItems('Locations');},
                  child: const Text('Locations')
                ),
                TextButton(
                  onPressed: () {showItems('Enemies');},
                  child: const Text('Enemies')
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
  
  void showItems(String jsonFileName) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Items(jsonFileName: jsonFileName))
      );
  }
}