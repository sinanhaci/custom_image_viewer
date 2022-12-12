
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class OpenContainerWrapper<T> extends StatelessWidget {
  const OpenContainerWrapper({super.key, 
    required this.closedBuilder,
    required this.transitionType,
    required this.onClosed,
    required this.child,
    this.closedColor,
    this.middleColor,
    this.openColor,
    this.transitionDuration,
    this.clipBehavior,
    this.closedElevation,
    this.openElevation,
    this.openShape,
    this.closedShape,

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
  final double? closedElevation;
  final double? openElevation;
  final ShapeBorder? openShape;
  final ShapeBorder? closedShape;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<T>(
      closedElevation: closedElevation ?? 0,
      openElevation: openElevation ?? 0,
      openShape: openShape ?? const RoundedRectangleBorder(),
      closedShape: closedShape ?? const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
      transitionType: transitionType,
      openBuilder: (BuildContext context, VoidCallback _) {
        return child;
      },
      clipBehavior: clipBehavior ?? Clip.antiAlias,
      openColor: openColor ?? Colors.transparent,
      middleColor: middleColor ?? Colors.transparent,
      closedColor: closedColor ?? Colors.transparent,
      onClosed: onClosed,
      tappable: false,
      closedBuilder: closedBuilder,
      transitionDuration: transitionDuration ?? const Duration(milliseconds: 350),
      
    );
  }
}

