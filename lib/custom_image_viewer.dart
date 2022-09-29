library custom_image_viewer;

import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';


const _routeDuration = Duration(milliseconds: 300);

class CustomImageViewer<T> extends StatelessWidget {
  const CustomImageViewer({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.black,
    this.disposeLevel,
    required this.images,
    this.initialIndex = 0,
    this.boxFit = BoxFit.contain,
    this.buttonAlignment = Alignment.topRight,
    this.buttonPadding = const EdgeInsets.fromLTRB(0, 20, 20, 0),
    this.pageIndicatorAlignment = Alignment.bottomCenter,
    this.pageIndicatorPadding = const EdgeInsets.fromLTRB(0, 0, 0, 20),
    this.pageIndicatorTextStyle = const TextStyle(color: Colors.white),
    this.imageType = ImageType.networkLoading,
    this.customButton,
    this.openDuration = const Duration(milliseconds: 550),
    this.closeDuration = const Duration(milliseconds: 550),
    this.runWithOutOpeningImageDetail,
  }) : super(key: key);

  final Widget child;
  final Color backgroundColor;
  final DisposeLevel? disposeLevel;
  final List<T> images;
  final BoxFit boxFit;
  final Alignment buttonAlignment;
  final EdgeInsets buttonPadding;
  final Widget? customButton;
  final Alignment pageIndicatorAlignment;
  final TextStyle pageIndicatorTextStyle;
  final EdgeInsets pageIndicatorPadding;
  final ImageType imageType;
  final int initialIndex;
  final Duration openDuration;
  final Duration closeDuration;
  final Function? runWithOutOpeningImageDetail;

  @override
  Widget build(BuildContext context) {
    final UniqueKey tag = UniqueKey();
    return Hero(
      tag: tag,
      child: GestureDetector(
        onTap: () {
          if(runWithOutOpeningImageDetail != null){
            runWithOutOpeningImageDetail!();
          }
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              barrierColor: backgroundColor,
              transitionDuration: openDuration,
              reverseTransitionDuration: closeDuration,
              pageBuilder: (BuildContext context, _, __) {
                return CustomFullScreenImageViewer(
                  tag: tag,
                  backgroundColor: backgroundColor,
                  disposeLevel: disposeLevel,
                  images: images,
                  boxFit: boxFit,
                  buttonAlignment: buttonAlignment,
                  buttonPadding: buttonPadding,
                  customButton: customButton,
                  imageType: imageType,
                  initialIndex: initialIndex,
                  pageIndicatorAlignment: pageIndicatorAlignment,
                  pageIndicatorPadding: pageIndicatorPadding,
                  pageIndicatorTextStyle: pageIndicatorTextStyle,
                );
              },
            ),
          );
        },
        child: child,
      ),
    );
  }
}

enum DisposeLevel { high, medium, low }

enum ImageType { network, networkLoading, asset, memory, file }

enum ScaleLevel { off, x2, x3 }

class CustomFullScreenImageViewer<T> extends StatefulWidget {
  const CustomFullScreenImageViewer({
    Key? key,
    required this.tag,
    required this.backgroundColor,
    required this.disposeLevel,
    required this.imageType,
    required this.images,
    required this.initialIndex,
    required this.boxFit,
    required this.buttonAlignment,
    required this.buttonPadding,
    required this.pageIndicatorAlignment,
    required this.pageIndicatorPadding ,
    required this.pageIndicatorTextStyle,
    this.customButton,
  }) : super(key: key);

  final List<T> images;
  final int initialIndex;
  final Color backgroundColor;
  final DisposeLevel? disposeLevel;
  final UniqueKey tag;
  final ImageType imageType;
  final BoxFit boxFit;
  final Alignment buttonAlignment;
  final EdgeInsets buttonPadding;
  final Widget? customButton;
  final Alignment pageIndicatorAlignment;
  final TextStyle pageIndicatorTextStyle;
  final EdgeInsets pageIndicatorPadding;

  @override
  State<CustomFullScreenImageViewer> createState() => _CustomFullScreenImageViewerState();
}



class _CustomFullScreenImageViewerState extends State<CustomFullScreenImageViewer> {
  double? _initialPositionY = 0;
  double? _currentPositionY = 0;
  double _positionYDelta = 0;
  double _opacity = 1;
  double _disposeLimit = 150;
  late Duration _animationDuration;
  late PageController _pageController;
  late int _activePage;
  late TapDownDetails _doubleTapDetails;
  late TransformationController _transformationController;
  final double _minScale = 1.0;
  final double _maxScale = 5.0;
  ScaleLevel _scaleLevel = ScaleLevel.off;

  @override
  void initState() {
    super.initState();
    setDisposeLevel();
    _pageController = PageController(initialPage: widget.initialIndex);
    _activePage = widget.initialIndex;
    _transformationController = TransformationController();
    _animationDuration = Duration.zero;
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _transformationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPosition = 0 + max(_positionYDelta, -_positionYDelta) / 15;
    return Hero(
      tag: widget.tag,
      child: Scaffold(
          backgroundColor: widget.backgroundColor,
          body: Stack(
            children: [
              PageView.builder(
                onPageChanged: (index) {
                  setState(() {
                    _activePage = index;
                    _transformationController.value = Matrix4.identity();
                  });
                },
                controller: _pageController,
                itemCount: widget.images.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  var item = widget.images[index];
                  return Container(
                    color: widget.backgroundColor.withOpacity(_opacity),
                    constraints: BoxConstraints.expand(
                      height: MediaQuery.of(context).size.height,
                    ),
                    child: Stack(
                      children: <Widget>[
                        AnimatedPositioned(
                          duration: _animationDuration,
                          curve: Curves.bounceInOut,
                          top: 0 + _positionYDelta,
                          bottom: 0 - _positionYDelta,
                          left: horizontalPosition,
                          right: horizontalPosition,
                          child: GestureDetector(
                            onDoubleTapDown: _handleDoubleTapDown,
                            onDoubleTap: _handleDoubleTap,
                            child: InteractiveViewer(
                              transformationController:
                                  _transformationController,
                              minScale: _minScale,
                              maxScale: _maxScale,
                              key: const Key('image_interactive_viewer'),
                              panEnabled: false,
                              child:  KeymotionGestureDetector(
                                      onStart: (details) => _dragStart(details),
                                      onUpdate: (details) =>
                                          _dragUpdate(details),
                                      onEnd: (details) => _dragEnd(details),
                                      child: _getViewWidgetByImageType(item),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Align(
                alignment: widget.pageIndicatorAlignment,
                child: SafeArea(
                  child: Padding(
                    padding: widget.pageIndicatorPadding,
                    child: Text(
                      '${_activePage + 1}/${widget.images.length}',
                      style: widget.pageIndicatorTextStyle,
                    ),
                  ),
                ),
              ),
              _cancelButton(context),
            ],
          )),
    );
  }

  Widget _cancelButton(BuildContext context) {
    return widget.customButton ??
        Align(
          alignment: widget.buttonAlignment,
          child: Padding(
            padding: widget.buttonPadding,
            child: SafeArea(
              child: Material(
                color: const Color(0xff222222),
                shape: const CircleBorder(),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
  }

  Image _getViewWidgetByImageType(var image) {
    switch (widget.imageType) {
      case ImageType.networkLoading:
        return Image.network(
          image,
          fit: widget.boxFit,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.black,
                color: Colors.white,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        );
      case ImageType.memory:
        return Image.memory(
          image,
          fit: widget.boxFit,
        );
      case ImageType.file:
        return Image.file(
          image,
          fit: widget.boxFit,
        );
      case ImageType.asset:
        return Image.asset(
          image,
          fit: widget.boxFit,
        );
      case ImageType.network:
        return Image.network(
          image,
          fit: widget.boxFit,
        );
    }
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    final position = _doubleTapDetails.localPosition;
    switch (_scaleLevel) {
      case ScaleLevel.off:
        _transformationController.value = Matrix4.identity()
          ..translate(-position.dx, -position.dy)
          ..scale(2.0);
        _scaleLevel = ScaleLevel.x2;
        break;
      case ScaleLevel.x2:
        _transformationController.value = Matrix4.identity()
          ..translate(-position.dx * 2, -position.dy * 2)
          ..scale(3.0);
        _scaleLevel = ScaleLevel.x3;
        break;
      case ScaleLevel.x3:
        _transformationController.value = Matrix4.identity();
        _scaleLevel = ScaleLevel.off;
    }
    setState(() {});
  }

  void _dragUpdate(DragUpdateDetails details) {
    setState(() {
      _currentPositionY = details.globalPosition.dy;
      _positionYDelta = _currentPositionY! - _initialPositionY!;
      setOpacity();
    });
  }

  void _dragStart(DragStartDetails details) {
    setState(() {
      _initialPositionY = details.globalPosition.dy;
    });
  }

  _dragEnd(DragEndDetails details) {
    if (_positionYDelta > _disposeLimit || _positionYDelta < -_disposeLimit) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _animationDuration = _routeDuration;
        _opacity = 1;
        _positionYDelta = 0;
      });

      Future.delayed(_animationDuration).then((_) {
        setState(() {
          _animationDuration = Duration.zero;
        });
      });
    }
  }

  setDisposeLevel() {
    if (widget.disposeLevel == DisposeLevel.high) {
      _disposeLimit = 250;
    } else if (widget.disposeLevel == DisposeLevel.medium) {
      _disposeLimit = 150;
    } else {
      _disposeLimit = 50;
    }
  }
  setOpacity() {
    final double tmp = _positionYDelta < 0 ? 1 - ((_positionYDelta / 1000) * -1)
        : 1 - (_positionYDelta / 1000);
    if (tmp > 1) {
      _opacity = 1;
    } else if (tmp < 0) {
      _opacity = 0;
    } else {
      _opacity = tmp;
    }
  }
}

class KeymotionGestureDetector extends StatelessWidget {
  const KeymotionGestureDetector({
    Key? key,
    required this.child,
    this.onUpdate,
    this.onEnd,
    this.onStart,
  }) : super(key: key);

  final Widget child;
  final GestureDragUpdateCallback? onUpdate;
  final GestureDragEndCallback? onEnd;
  final GestureDragStartCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(gestures: <Type, GestureRecognizerFactory>{
      VerticalDragGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
        () => VerticalDragGestureRecognizer()
          ..onStart = onStart
          ..onUpdate = onUpdate
          ..onEnd = onEnd,
        (instance) {},
      ),
    }, child: child);
  }
}
