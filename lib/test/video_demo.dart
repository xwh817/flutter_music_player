// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoDemo extends StatefulWidget {
  String url;
  VideoDemo({Key key, this.url}) : super(key: key);

  @override
  _VideoDemoState createState() => _VideoDemoState();
}

class _VideoDemoState extends State<VideoDemo>
    with SingleTickerProviderStateMixin {
  VideoPlayerController controller;
  bool isDisposed = false;

  Future<void> initController(
      VideoPlayerController controller, String name) async {
    print(
        '> VideoDemo initController "${widget.url}" ${isDisposed ? "DISPOSED" : ""}');
    //controller.setLooping(true);
    //controller.setVolume(0.0);
    controller.play();
    await controller.initialize();
    if (mounted) {
      print(
          '< VideoDemo initController "$name" done ${isDisposed ? "DISPOSED" : ""}');
      setState(() {});
    } else {
      print('not mounted!!');
    }
  }

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.network(widget.url);

    initController(controller, 'bee');
  }

  @override
  void dispose() {
    print('> VideoDemo dispose');
    isDisposed = true;
    controller.dispose();
    print('< VideoDemo dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
      ),
      body: GestureDetector(
        onTap: () => pushFullScreenWidget(context),
        child: _buildInlineVideo(),
      ),
    );
  }

  Widget _buildInlineVideo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
      child: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Hero(
            tag: controller,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenVideo() {
    return Center(
        child: AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Hero(
        tag: controller,
        child: VideoPlayer(controller),
      ),
    ));
  }

  void pushFullScreenWidget(context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    final TransitionRoute<void> route = PageRouteBuilder<void>(
        settings: RouteSettings(name: "Test"),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _buildFullScreenVideo());

    route.completed.then((void value) {
      //controller.setVolume(0.0);
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    });

    //controller.setVolume(1.0);
    Navigator.of(context).push(route);
  }
}
