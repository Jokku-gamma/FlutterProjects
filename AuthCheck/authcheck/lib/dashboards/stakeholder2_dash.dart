import 'package:flutter/material.dart';
import '../pages/stakeholder2/page1.dart';
import '../pages/stakeholder2/page2.dart';
import '../pages/stakeholder2/page3.dart';

class Stakeholder2Dashboard extends StatefulWidget {
  @override
  _Stakeholder2DashboardState createState() => _Stakeholder2DashboardState();
}

class _Stakeholder2DashboardState extends State<Stakeholder2Dashboard> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    Stakeholder2Page1(),
    Stakeholder2Page2(),
    Stakeholder2Page3(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Page1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Page2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Page3',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}