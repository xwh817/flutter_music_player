import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoControllerProvider with ChangeNotifier{
  VideoPlayerController controller;

  setController(VideoPlayerController controller){
    /* if (controller != null) {   // 把上一个停掉
        controller.pause();
        controller.dispose();
      } */
    this.controller = controller;
    //notifyListeners();
  }

  VideoPlayerController getController(){
    return this.controller;
  }

  // 判断参数是否是当前controller,如果是就把全局controller置空。
  bool clearController(VideoPlayerController itemController){
    bool isCurrentController = itemController!= null && itemController == this.controller;
    if (isCurrentController) {
      this.controller = null;
    }
    return isCurrentController;
  }

}