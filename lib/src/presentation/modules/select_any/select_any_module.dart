import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/widgets.dart';
import 'package:select_any/src/data/models/models.dart';

import 'select_any_controller.dart';
import 'select_any_page.dart';

/// [overrideDefaultBackButtonVisibility] if not null overrides [showBackButton] value
class SelectAnyModule extends ModuleWidget {
  final Map? data;
  final SelectModel? model;
  final SelectAnyController? controller;
  final bool showBackButton;
  final bool? overrideDefaultBackButtonVisibility;

  SelectAnyModule(
    this.model, {
    this.data,
    this.controller,
    this.showBackButton = true,
    this.overrideDefaultBackButtonVisibility,
  });

  @override
  List<Bloc> get blocs => [];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => SelectAnyPage(
        this.model,
        data: this.data,
        controller: controller,
        showBackButton: showBackButton,
        overrideDefaultBackButtonVisibility:
            overrideDefaultBackButtonVisibility,
      );
}
