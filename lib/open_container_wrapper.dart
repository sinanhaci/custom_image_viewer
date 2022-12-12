
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class OpenContainerWrapper<T> extends StatelessWidget {
  const OpenContainerWrapper({super.key, 
    required this.closedBuilder,
    required this.transitionType,
    required this.onClosed,
    required this.child,
    this.closedColor = Colors.transparent,
    this.middleColor = Colors.transparent,
    this.openColor = Colors.transparent,
    this.transitionDuration = const Duration(milliseconds: 350),
    this.clipBehavior = Clip.antiAlias
  });

  final CloseContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;
  final ClosedCallback<T?> onClosed;
  final Widget child;
  final Color? closedColor;
  final Color? middleColor;
  final Color? openColor;
  final Duration? transitionDuration;
  final Clip? clipBehavior;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<T>(
      transitionType: transitionType,
      openBuilder: (BuildContext context, VoidCallback _) {
        return child;
      },
      clipBehavior: clipBehavior!,
      openColor: openColor!,
      middleColor: middleColor,
      closedElevation: 0,
      closedColor: closedColor!,
      onClosed: onClosed,
      tappable: false,
      closedBuilder: closedBuilder,
      transitionDuration: transitionDuration!,
      
    );
  }
}

