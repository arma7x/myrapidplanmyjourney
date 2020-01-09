import 'package:flutter/material.dart';

mixin FragmentUtils {

  void showloadingDialog(bool show, BuildContext ctx) {
    if (show == true) {
      showDialog(
        barrierDismissible: false,
        context: ctx,
        builder: (BuildContext _) {
          return AlertDialog(
            content: Container(child: new LinearProgressIndicator()),
          );
        },
      );
    } else {
      Navigator.of(ctx).pop();
    }
  }

}
