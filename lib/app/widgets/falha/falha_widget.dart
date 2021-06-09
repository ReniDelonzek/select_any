import 'package:flutter/material.dart';
import 'package:msk_utils/utils/utils_platform.dart';

class FalhaWidget extends StatelessWidget {
  final String mensagem;
  final Object error;

  FalhaWidget(this.mensagem, {this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'images/icon_fail.png',
            width: 100,
            height: 100,
            package: 'select_any',
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Oops',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(UtilsPlatform.isDebug && error != null
                ? error.toString()
                : mensagem),
          )
        ],
      ),
    );
  }
}
