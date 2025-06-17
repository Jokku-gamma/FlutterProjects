import 'package:flutter/material.dart';
import '../pages/stakeholder1/page1.dart';
import '../pages/stakeholder1/page2.dart';
import '../pages/stakeholder1/page3.dart';

class Stakeholder1Dashboard extends StatefulWidget {
  @override
  _Stakeholder1DashboardState createState() => _Stakeholder1DashboardState();
}

class _Stakeholder1DashboardState extends State<Stakeholder1Dashboard> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    Stakeholder1Page1(),
    Stakeholder1Page2(),
    Stakeholder1Page3(),
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