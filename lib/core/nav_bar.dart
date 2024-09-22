import 'package:first_flutter/core/drawer.dart';
import 'package:first_flutter/core/home_screen.dart';
import 'package:first_flutter/core/personal_task.dart';
import 'package:flutter/material.dart';

class navBar extends StatefulWidget {
  const navBar({super.key});

  @override
  State<navBar> createState() => _navBarState();
}

class _navBarState extends State<navBar> {
  int _selectedItemIndex = 0;
  List appScreens = [
    const HomeScreen(),
    const PersonalTask(),
    const Center(child: Text("Team task")),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onTapSelections(int index) {
    setState(() {
      _selectedItemIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: true,
      drawer: const MyDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0E0E0),
        leading: IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu)),
      ),
      body: appScreens[_selectedItemIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTapSelections,
        currentIndex: _selectedItemIndex,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.task_rounded), label: "Task"),
          BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_rounded), label: "Team Task"),
        ],
      ),
    );
  }
}
