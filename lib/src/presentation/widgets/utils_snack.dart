import 'package:flutter/material.dart';
import 'package:msk_utils/msk_utils.dart';

import 'my_snack_bar.dart';

showSnackMessage(BuildContext context, String message) {
  if (UtilsPlatform.isMobile) {
    ScaffoldMessenger.maybeOf(context)!.showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
  } else {
    ScaffoldMessenger.maybeOf(context)!.showSnackBar(MySnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
