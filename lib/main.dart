import 'package:flutter/material.dart';
import 'main_page.dart';

void main() => runApp(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Momnori Author App'),
          ),
          body: MainPage(),
        ),
      ),
    );
