import 'package:flutter/material.dart';
import 'package:flutter_music_player/model/Lyric.dart';

class LyricPage extends StatefulWidget {
  final Lyric lyric;
  final int position;
  LyricPage({Key key, this.lyric, this.position}) : super(key: key);

  @override
  _LyricPageState createState() => _LyricPageState();
}

final double itemHeight = 30.0;

class _LyricPageState extends State<LyricPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lyric == null) {
      return Container();
    }
    
    int currentIndex = _getCurrentIndex();
    LyricItem currentItem = widget.lyric.items[currentIndex];

    //_style.color =
    return CustomScrollView(
      shrinkWrap: true,
      //controller: new ScrollController(initialScrollOffset: currentIndex * itemHeight),
      slivers: <Widget>[
        //Text(widget.lyric.getItemsString(), style: _style,)
        SliverList(
          delegate: SliverChildListDelegate(
            widget.lyric.items.map((item) {
            TextStyle _style;
            if (item == currentItem) {
              //scrollController.animateTo(currentIndex * 20.0);
              _style = TextStyle(fontSize: 13.0, color: Colors.white);
            } else {
              _style = TextStyle(fontSize: 13.0, color: Colors.white60);
            }
            return Container(
              height: itemHeight,
              child:Text(
                item.content,
                textAlign: TextAlign.center,
                style: _style,
            ));
          }).toList()),
        ),
      ],
    );
  }

  int _getCurrentIndex() {
    
    int index = 0;
    for(LyricItem item in widget.lyric.items) {
      if (widget.position * 1000 <= item.position) {
        index = index - 1;
        if(index < 0){
          index = 0;
        }
        break;
      }
      index++;
    }
    return index;
  }
}
