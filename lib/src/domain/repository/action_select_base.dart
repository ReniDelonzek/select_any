import 'package:flutter/material.dart';

import '../entities/button_position.dart';

abstract class ActionSelectBase {
  final ButtonPosition Function(int typeScreen)? buttonPosition;

  ActionSelectBase({this.buttonPosition});

  Widget build(ButtonPosition position, void Function()? onTap);
}
