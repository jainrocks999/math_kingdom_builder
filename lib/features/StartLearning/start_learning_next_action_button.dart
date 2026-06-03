import 'package:flutter/material.dart';

import 'start_learning_navigation.dart';

class StartLearningNextActionButton extends StatefulWidget {
  const StartLearningNextActionButton({
    super.key,
    required this.currentRoute,
    required this.onPrepareNavigation,
    required this.builder,
  });

  final String currentRoute;
  final VoidCallback onPrepareNavigation;
  final Widget Function(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) builder;

  @override
  State<StartLearningNextActionButton> createState() =>
      _StartLearningNextActionButtonState();
}

class _StartLearningNextActionButtonState
    extends State<StartLearningNextActionButton> {
  late Future<String> _labelFuture;

  @override
  void initState() {
    super.initState();
    _labelFuture = StartLearningNavigation.nextActionLabel(widget.currentRoute);
  }

  Future<void> _handleTap() async {
    await StartLearningNavigation.goToNextLearning(
      context,
      currentRoute: widget.currentRoute,
      beforeNavigate: widget.onPrepareNavigation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _labelFuture,
      builder: (context, snapshot) {
        return widget.builder(
          context,
          snapshot.data ?? 'Next Learning',
          () {
            _handleTap();
          },
        );
      },
    );
  }
}
