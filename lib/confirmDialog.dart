import 'package:flutter/material.dart';

class ConfirmDialog {
  final String title;
  final Widget body;
  final String bodyText;
  final bool allowDismiss;
  final bool showConfirm;
  final bool showCancel;
  final VoidCallback confirm;
  final VoidCallback cancel;
  final String cancelText;
  final String confirmtext;
  final List<Widget> customActions;

  ConfirmDialog(this.title, this.bodyText, this.confirm,
      {this.body,
      this.cancel,
      this.allowDismiss = true,
      this.showConfirm = true,
      this.showCancel = true,
      this.customActions,
      this.cancelText = "CANCEL",
      this.confirmtext = "CONFIRM"});

  Widget _buildBody() {
    if (body != null) {
      return body;
    } else {
      return Text(bodyText);
    }
  }

  List<Widget> _generateActions(BuildContext context) {
    var defaultActions = <Widget>[
      showCancel
          ? FlatButton(
              child: new Text(cancelText),
              onPressed: () {
                if (cancel != null) {
                  cancel();
                }
                Navigator.of(context).pop(false);
              },
            )
          : null,
      showConfirm
          ? FlatButton(
              child: new Text(confirmtext),
              onPressed: () {
                if (confirm != null) {
                  confirm();
                }
                Navigator.of(context).pop(true);
              },
            )
          : null,
    ];

    if (customActions == null || customActions.isEmpty) {
      return defaultActions;
    } else {
      customActions.addAll(defaultActions);
    }
    return customActions;
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        child: AlertDialog(
          title: Text(title),
          content: _buildBody(),
          actions: _generateActions(context),
        ),
        onWillPop: () async {
          if (allowDismiss) {
            if (cancel != null) {
              cancel();
            }
            return true;
          }
          return false;
        });
  }

  Future show(BuildContext context) {
    return showDialog(
      context: context,
      child: build(context),
      barrierDismissible: allowDismiss,
    );
  }
}
