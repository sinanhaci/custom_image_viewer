import 'package:custom_image_viewer/custom_image_viewer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CustomImageViewerTest());
}

class CustomImageViewerTest extends StatelessWidget {
  const CustomImageViewerTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomImageViewer Example'),
      ),
      body: PageView.builder(
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: PageView.builder(
              itemCount: imageList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                var image = imageList[index];
                return CustomImageViewer(
                  initialIndex: index,
                  images: imageList,
                  child: Image.network(image),
                );
              },
            ),
          );
        },
      ),
    );
  }

  final List<String> imageList = [
    'https://picsum.photos/536/354',
    'https://picsum.photos/id/1084/536/354?grayscale',
    'https://picsum.photos/seed/picsum/536/354'
  ];
}
