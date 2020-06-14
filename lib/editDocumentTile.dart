import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:scanbox/database/database.dart';

class EditDocumentTile extends StatefulWidget {
  final Scan scan;
  final bool singleMode;
  final int pageNumber;

  const EditDocumentTile(
      {Key key, this.scan, this.singleMode = true, this.pageNumber})
      : super(key: key);

  @override
  _EditDocumentTileState createState() => _EditDocumentTileState();
}

class _EditDocumentTileState extends State<EditDocumentTile> {
  bool editTitle = false;
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.scan.title ?? "No title";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.singleMode) {
      return buildSingleScanView(context);
    }
    return buildMultipleScanView(context);
  }

  Widget buildSingleScanView(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 50,
          left: 10,
          right: 10,
          bottom: 10,
          child: Image.file(
            File(widget.scan.path),
            alignment: Alignment.topLeft,
            fit: BoxFit.contain,
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            padding: EdgeInsets.all(10),
            constraints: BoxConstraints.expand(height: 50),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: editTitle
                ? titleEditWidget(context)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        controller.text ?? "No title",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Padding(padding: EdgeInsets.only(left: 8)),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => setState(() => editTitle = true),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget titleEditWidget(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: controller,
          ),
        ),
        Padding(padding: EdgeInsets.only(left: 8)),
        IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              final db = AppDb.get();
              db
                  .updateScan(widget.scan.copyWith(title: controller.text))
                  .then((value) => {
                        setState(() {
                          editTitle = false;
                        })
                      });
            }),
      ],
    );
  }

  Widget buildMultipleScanView(BuildContext context) {
    return ListTile(
      leading: Image.file(
        File(widget.scan.path),
      ),
      title: editTitle
          ? titleEditWidget(context)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Page ${widget.pageNumber}: " + controller.text ?? "No title",
                  style: Theme.of(context).textTheme.headline6,
                ),
                Padding(padding: EdgeInsets.only(left: 8)),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => setState(() => editTitle = true),
                ),
              ],
            ),
      onTap: () {
        OpenFile.open(widget.scan.path);
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
