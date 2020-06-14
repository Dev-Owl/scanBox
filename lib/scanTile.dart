import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scanbox/createDocument.dart';
import 'package:scanbox/database/database.dart';
import 'package:scanbox/database/scanViewModel.dart';

class ScanTile extends StatefulWidget {
  final Selectable<Scan> viewModel;
  final bool selectableModeActive;
  final VoidCallback longPress;
  final VoidCallback reloadData;
  const ScanTile({
    Key key,
    this.viewModel,
    this.selectableModeActive,
    this.longPress,
    this.reloadData,
  }) : super(key: key);

  @override
  _ScanTileState createState() => _ScanTileState();
}

class _ScanTileState extends State<ScanTile> {
  @override
  Widget build(BuildContext context) {
    final childs = <Widget>[
      Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          constraints: BoxConstraints.expand(height: 25),
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Text(_buildTitle(widget.viewModel.data.title ?? "No title"),
              style: Theme.of(context).textTheme.headline6),
        ),
      ),
    ];
    if (widget.selectableModeActive) {
      childs.add(Align(
        alignment: Alignment.topLeft,
        child: IconButton(
            icon: Icon(
              widget.viewModel.selected
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: Colors.green,
              size: 35,
            ),
            onPressed: () {
              setState(() {
                widget.viewModel.selected = !widget.viewModel.selected;
              });
            }),
      ));
    }

    return GestureDetector(
      onTap: () {
        if (widget.selectableModeActive) {
          setState(() {
            widget.viewModel.selected = !widget.viewModel.selected;
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateDocument(
                      scans: <Scan>[widget.viewModel.data],
                    )),
          ).then((value) => widget.reloadData());
        }
      },
      onLongPress: () {
        if (widget.selectableModeActive) {
          setState(() {
            widget.viewModel.selected = !widget.viewModel.selected;
          });
        } else {
          widget.longPress();
          setState(() {
            widget.viewModel.selected = !widget.viewModel.selected;
          });
        }
      },
      child: Container(
        constraints: BoxConstraints.expand(height: 80.0, width: 80),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(
              File(widget.viewModel.data.path),
            ),
            fit: BoxFit.contain,
          ),
        ),
        child: Stack(
          children: childs,
        ),
      ),
    );
  }

  String _buildTitle(String title) {
    if (title.length <= 18) {
      return title;
    }
    return "${title.substring(0, min(18, title.length))}...";
  }
}
