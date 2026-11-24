import 'package:flutter/material.dart';
import "./feed.dart";

class ScreenExplore extends StatefulWidget {
  const ScreenExplore({super.key});

  @override
  State<ScreenExplore> createState() => _ScreenExploreState();
}

class _ScreenExploreState extends State<ScreenExplore> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Latest posts', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Feed(),
            ],
          ),
        ),
      ),
    );
  }
}
