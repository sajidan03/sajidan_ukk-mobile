import 'package:flutter/material.dart';

class Contoh extends StatelessWidget {
  const Contoh({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(child: Image(image: AssetImage('images.jpg'))),
            Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Oeschinen Lake Campground',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Kandersteg, Switzerland'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange),
                          SizedBox(width: 6),
                          Text('41'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.call, color: Colors.purple),
                          SizedBox(height: 10),
                          Text('Call', style: TextStyle(color: Colors.purple)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.navigation, color: Colors.purple),
                          SizedBox(height: 10),
                          Text(
                            'Navigation',
                            style: TextStyle(color: Colors.purple),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.share, color: Colors.purple),
                          SizedBox(height: 10),
                          Text('Share', style: TextStyle(color: Colors.purple)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Lorem impsum sit dolor amet'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
