import 'package:flutter/material.dart';
import '../pages/stakeholder3/page1.dart';
import '../pages/stakeholder3/page2.dart';
import '../pages/stakeholder3/page3.dart';

class Stakeholder3Dashboard extends StatefulWidget {
  @override
  _Stakeholder3DashboardState createState() => _Stakeholder3DashboardState();
}

class _Stakeholder3DashboardState extends State<Stakeholder3Dashboard> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    Stakeholder3Page1(),
    Stakeholder3Page2(),
    Stakeholder3Page3(),
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