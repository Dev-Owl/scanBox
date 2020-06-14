import 'package:flutter/material.dart';

class Processing extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool endless;
  final double progress;

  Processing(
      {this.title = "Please wait",
      this.subTitle = "Loading",
      this.endless = true,
      this.progress = 0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.headline5,
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            child: CircularProgressIndicator(
              value: endless ? null : progress,
            ),
          ),
          Text(
            subTitle,
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      ),
    );
  }
}
