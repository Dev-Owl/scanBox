import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scanbox/database/database.dart';
import 'package:scanbox/editDocumentTile.dart';
import 'package:scanbox/processing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CreateDocument extends StatefulWidget {
  final List<Scan> scans;

  const CreateDocument({Key key, this.scans}) : super(key: key);

  @override
  _CreateDocumentState createState() => _CreateDocumentState();
}

class _CreateDocumentState extends State<CreateDocument> {
  bool singleView;

  @override
  Widget build(BuildContext context) {
    singleView = widget.scans.length == 1;
    return Scaffold(
      appBar: AppBar(
        title: Text("Create PDF"),
      ),
      body: buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.storage,
          ].request();
          showDialog(
            context: context,
            builder: (c) => Processing(
              subTitle: "PDF generation",
            ),
          );
          if (!statuses[Permission.storage].isGranted) {
            Navigator.pop(context);
            return;
          }
          //Creat PDF
          final pdf = pw.Document();
          widget.scans.forEach((singleScan) {
            final image = PdfImage.file(
              pdf.document,
              bytes: io.File(singleScan.path).readAsBytesSync(),
            );
            pdf.addPage(
              pw.Page(
                  margin: pw.EdgeInsets.all(5),
                  pageFormat: PdfPageFormat.a4,
                  build: (pw.Context context) {
                    return pw.Center(child: pw.Image(image));
                  }),
            );
          });
          final dir = await getExternalStorageDirectory();
          var targetDir =
              await io.Directory('${dir.path}/scanBox').create(recursive: true);
          final file = io.File(
            join(targetDir.path,
                '${DateTime.now().millisecondsSinceEpoch.toString()}_scanBox.pdf'),
          );
          await file.writeAsBytes(pdf.save());
          //Hide dialog
          Navigator.pop(context);
          //Open pdf
          OpenFile.open(file.path);
        },
        child: Icon(
          Icons.save,
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    if (widget.scans.length > 1) {
      var pageCounter = 0;
      return ReorderableListView(
          header: Padding(
            child: Text(
              "Long press to change order",
              style: Theme.of(context).textTheme.headline5,
            ),
            padding: EdgeInsets.only(bottom: 5),
          ),
          padding: EdgeInsets.all(5),
          children: widget.scans.map((e) {
            pageCounter++;
            return Padding(
              key: ValueKey(e),
              child: EditDocumentTile(
                scan: e,
                singleMode: false,
                pageNumber: pageCounter,
              ),
              padding: EdgeInsets.only(top: 5),
            );
          }).toList(),
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final tmp = widget.scans.removeAt(oldIndex);
            widget.scans.insert(newIndex, tmp);
            setState(() {});
          });
    } else {
      return EditDocumentTile(
        scan: widget.scans.first,
        singleMode: true,
      );
    }
  }
}
