import 'package:flutter/material.dart';

class UnclearNavigationBar extends StatelessWidget {
  const UnclearNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const <Widget>[
        NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
        NavigationDestination(icon: Icon(Icons.add_a_photo), label: 'Post'),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Friends',
        ),
      ],
    );
  }
}
