import 'dart:io';

import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:scanbox/confirmDialog.dart';
import 'package:scanbox/createDocument.dart';
import 'package:scanbox/database/database.dart';
import 'package:scanbox/database/scanViewModel.dart';
import 'package:scanbox/scanTile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanBox',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'ScanBox'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final db = AppDb.get();
  ScanViewModel viewModel;
  bool loading = true;

  Future loaddata() async {
    viewModel = ScanViewModel(
        (await db.getAllScans().get()).map((e) => Selectable(e)).toList());
    final removeList = List<int>();
    for (var element in viewModel.scans) {
      if (!(await File(element.data.path).exists())) {
        removeList.add(element.data.id);
      }
    }
    if (removeList.length > 0) {
      await db.deleteRecordsById(removeList);
      viewModel.scans
          .removeWhere((element) => removeList.contains(element.data.id));
    }
  }

  void reloadData() {
    setState(() {
      loading = true;
    });
    loaddata().then((value) => setState(() => loading = false));
  }

  @override
  void initState() {
    super.initState();
    loaddata().then((value) => setState(() => loading = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: viewModel?.selectableModeActive ?? false
            ? <Widget>[
                IconButton(
                    icon: Icon(Icons.done_all),
                    onPressed: () {
                      setState(() {
                        viewModel.scans
                            .forEach((element) => element.selected = true);
                      });
                    }),
                IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      viewModel.scans
                          .forEach((element) => element.selected = false);
                      setState(() {
                        viewModel.selectableModeActive = false;
                      });
                    }),
                IconButton(
                    icon: Icon(Icons.delete_forever),
                    onPressed: () {
                      setState(() {
                        final markedRecords = viewModel.scans
                            .where((element) => element.selected)
                            .length;
                        if (markedRecords == 0) {
                          return;
                        }
                        ConfirmDialog("Please confirm",
                            "You want to delete all $markedRecords scans?", () {
                          final deleteList = viewModel.scans
                              .where((element) => element.selected)
                              .map((e) => e.data.id)
                              .toList();
                          setState(() {
                            loading = true;
                          });
                          db.deleteRecordsById(deleteList).then((value) {
                            loaddata().then(
                                (value) => setState(() => loading = false));
                          });
                        }).show(context);
                      });
                    })
              ]
            : null,
      ),
      body: buildBody(context),
      floatingActionButton: getFloatingButtons(context),
    );
  }

  Widget getFloatingButtons(BuildContext context) {
    if (loading) {
      return null;
    }
    final addButton = FloatingActionButton(
      onPressed: () async {
        final imagePath = await EdgeDetection.detectEdge;
        if (imagePath != null) {
          if (await File(imagePath).exists()) {
            final newID = await db.insertNewScan(ScansCompanion.insert(
                path: imagePath, created: DateTime.now()));
            setState(() {
              //Reload the tiles
              viewModel.scans.add(
                Selectable<Scan>(
                  Scan(
                    id: newID,
                    path: imagePath,
                    created: DateTime.now(),
                  ),
                ),
              );
            });
          }
        }
      },
      tooltip: 'Scan',
      child: Icon(Icons.add),
    );
    if (viewModel.selectableModeActive) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateDocument(
                          scans: viewModel.scans
                              .where((element) => element.selected)
                              .map((e) => e.data)
                              .toList(),
                        )),
              );
              reloadData();
            },
            child: Icon(Icons.send),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          addButton
        ],
      );
    } else {
      return addButton;
    }
  }

  Widget buildBody(BuildContext context) {
    if (!loading) {
      if (viewModel.scans.isEmpty) {
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "No scans",
              style: Theme.of(context).textTheme.headline2,
            ),
            Padding(padding: EdgeInsets.only(top: 15)),
            Icon(
              Icons.scanner,
              size: 50,
            ),
            Padding(padding: EdgeInsets.only(top: 15)),
            Text(
              'Tap + to start scanning...',
              style: Theme.of(context).textTheme.headline5,
            )
          ],
        ));
      }

      return GridView.count(
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 2,
        padding: EdgeInsets.all(10),
        // Generate 100 widgets that display their index in the List.
        children: viewModel.scans
            .map((scan) => ScanTile(
                  viewModel: scan,
                  selectableModeActive: viewModel.selectableModeActive,
                  longPress: _longPressedChild,
                  reloadData : reloadData
                ))
            .toList(),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  void _longPressedChild() {
    if (viewModel.selectableModeActive) {
      return;
    }
    setState(() {
      viewModel.selectableModeActive = true;
    });
  }
}
