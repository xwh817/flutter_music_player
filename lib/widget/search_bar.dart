import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final bool enable;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  SearchBar({
    Key key,
    this.enable: true,
    this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  
  bool showClear = false;

  @override
  void initState() {
    /* if (widget.defaultText != null) {
      setState(() {
        widget.controller.text = widget.defaultText;
      });
    } */
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.0,
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.search, size: 22.0, color: Colors.green),
          Expanded(
            child: TextField(
                enabled: widget.enable,
                controller: widget.controller,
                onChanged: _onChanged,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.bottom,
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                    fontWeight: FontWeight.w300),
                //输入文本的样式
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(3.5),
                  border: InputBorder.none,
                  hintText: '请输入歌名或歌手名',
                  hintStyle: TextStyle(fontSize: 14),
                )),
          ),
          InkWell(
            child:Icon(showClear? Icons.clear : Icons.mic, size: 22.0, color: Colors.green),
            onTap: (){
              if (showClear) {
                widget.controller.clear();
              } else {

              }
            }
          ),
        ],
      ),
    );
  }

  
  _onChanged(String text) {
    if (text.length > 0) {
      setState(() {
        showClear = true;
      });
    } else {
      setState(() {
        showClear = false;
      });
    }

    if (widget.onChanged != null) {
      widget.onChanged(text);
    }
  }

}
