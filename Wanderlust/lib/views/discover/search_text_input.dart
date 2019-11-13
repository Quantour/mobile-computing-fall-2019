import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

//Interface for controlling input field and listen to events
class SearchTextInputFieldController {
  void Function() onFilterPressed;
  void Function(String input) onTextInputChanged;
  List<String> Function(String input) searchSuggestionBuilder;

  SearchTextInputFieldController({
    this.onFilterPressed,
    this.onTextInputChanged,
    this.searchSuggestionBuilder
  });
}

class SearchTextInputFieldWidget extends StatefulWidget {
  
  final SearchTextInputFieldController controller;

  final FocusNode focusNode = FocusNode();
  final Key key;
  

  SearchTextInputFieldWidget({
    this.controller,
    this.key
  }) : super(key: key);

  @override
  _SearchTextInputFieldWidgetState createState() => _SearchTextInputFieldWidgetState();
}

class _SearchTextInputFieldWidgetState extends State<SearchTextInputFieldWidget> {
  
  OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  String _currentInput = "";
  TextEditingController textEditingController = TextEditingController();
  
  /* initializes listener for change of "focus" of user input
  also shows and hides search recommondations */
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() {
        if (widget.focusNode.hasFocus) {
          this._overlayEntry = this._createOverlayEntry();
          Overlay.of(context).insert(this._overlayEntry);
        } else {
          this._overlayEntry.remove();
        }
      });
    });
  }

  void _onTextInputChanged(String text) {
    print("Changed Input to $text");
    widget.controller.onTextInputChanged(text);
    setState(() {
      //TODO: This line is never called!! why? 
      print("This Line is never called");
      this._overlayEntry.remove();
      this._overlayEntry = this._createOverlayEntry();
        Overlay.of(context).insert(this._overlayEntry);
      _currentInput = text;
    });
  }

  //Creates Box for search suggestions
  OverlayEntry _createOverlayEntry() {

    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var xOffset = renderBox.localToGlobal(Offset.zero).dx;
    List<String> searchSuggestions = widget.controller.searchSuggestionBuilder(_currentInput);
    if (searchSuggestions == null || searchSuggestions.length == 0)
      return null;

    //TODO: find better/safer way to calculate height variable 
    var overlayEntryHeight = MediaQuery.of(context).size.height-100
                            -MediaQuery.of(context).viewInsets.bottom
                            -size.height;
    overlayEntryHeight = overlayEntryHeight > 0 ? overlayEntryHeight : 0;
    overlayEntryHeight = 100;

    //This Box contains the list with the search results
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width+2*xOffset,
        child: CompositedTransformFollower(
          link: this._layerLink,
          showWhenUnlinked: false,
          offset: Offset(-this._layerLink.leader.offset.dx, size.height),
          child: Material(
            elevation: 4.0,
            child: Container(
                height: overlayEntryHeight,
                child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[

                  if (!(_currentInput == null || _currentInput == ""))
                    ListTile(
                      title: Text(_currentInput, style: TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        widget.focusNode.unfocus();
                        if (widget.controller.onTextInputChanged != null)
                          widget.controller.onTextInputChanged(_currentInput);
                      },
                    ),

                  for (String suggestion in searchSuggestions)
                    if (suggestion != _currentInput)
                      ListTile(
                        title: Text(suggestion),
                        onTap: () {
                          setState(() {
                            _currentInput = suggestion;
                            textEditingController.text = suggestion;
                            widget.focusNode.unfocus();
                          });
                          if (widget.controller.onTextInputChanged != null)
                            widget.controller.onTextInputChanged(suggestion);
                        },
                      ),

                ],
              ),

            )
          ),
        ),
      )
    );
  }

  //builds 
  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5)
      ),
      leading: IconButton(
          icon: Icon(Icons.filter_list, color: Theme.of(context).accentColor), 
          onPressed: () {
            widget.focusNode.unfocus();
            if (widget.controller.onFilterPressed != null)
              widget.controller.onFilterPressed();
          },
      ),
      backgroundColor: Colors.white,
      primary: false,
      title: CompositedTransformTarget(
        link: this._layerLink,
        child: TextField(
          onChanged: _onTextInputChanged,
          onSubmitted: _onTextInputChanged,
          
          controller: textEditingController,
          key: widget.key,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            hintText: "Search",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey)
          )
        )
      ),
      actions: <Widget>[
        //This Buttom clears all text from the input
        if (widget.focusNode.hasFocus)
          IconButton(
            icon: Icon(Icons.clear, color: Theme.of(context).accentColor),
            onPressed: () {
              textEditingController.text = "";
              _onTextInputChanged("");
            },
          ),

        //search button
        IconButton(
          icon: Icon(Icons.search, color: Theme.of(context).accentColor),
          onPressed: () {
            setState(() {
              widget.focusNode.unfocus();
              if (widget.controller.onTextInputChanged!=null)
                widget.controller.onTextInputChanged(_currentInput);
              });
          }
        ),
      ],
    );
  }
}

