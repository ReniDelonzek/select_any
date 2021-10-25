// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

enum SnackPlacement { LEFT, CENTER, RIGHT }

const double _singleLineVerticalPadding = 14.0;

// TODO(ianh): We should check if the given text and actions are going to fit on
// one line or not, and if they are, use the single-line layout, and if not, use
// the multiline layout, https://github.com/flutter/flutter/issues/32782
// See https://material.io/components/snackbars#specs, 'Longer Action Text' does
// not match spec.

const Duration _snackBarTransitionDuration = Duration(milliseconds: 250);
const Duration _snackBarDisplayDuration = Duration(milliseconds: 4000);
const Curve _snackBarHeightCurve = Curves.fastOutSlowIn;
const Curve _snackBarFadeInCurve =
    Interval(0.45, 1.0, curve: Curves.fastOutSlowIn);
const Curve _snackBarFadeOutCurve =
    Interval(0.72, 1.0, curve: Curves.fastOutSlowIn);

class MySnackBar extends StatefulWidget implements SnackBar {
  /// Creates a snack bar.
  ///
  /// The [content] argument must be non-null. The [elevation] must be null or
  /// non-negative.
  const MySnackBar(
      {Key key,
      @required this.content,
      this.backgroundColor,
      this.elevation,
      this.margin,
      this.padding,
      this.width,
      this.shape,
      this.behavior,
      this.action,
      this.duration = _snackBarDisplayDuration,
      this.animation,
      this.onVisible,
      this.placement})
      : assert(elevation == null || elevation >= 0.0),
        assert(content != null),
        assert(
          margin == null || behavior == SnackBarBehavior.floating,
          'Margin can only be used with floating behavior',
        ),
        assert(
          width == null || behavior == SnackBarBehavior.floating,
          'Width can only be used with floating behavior',
        ),
        assert(
          width == null || margin == null,
          'Width and margin can not be used together',
        ),
        assert(duration != null),
        assert(placement == null || behavior == SnackBarBehavior.floating,
            'Placement cant use with floating behavior'),
        super(key: key);

  final SnackPlacement placement;

  final Widget content;
  final Color backgroundColor;
  final double elevation;
  final EdgeInsetsGeometry margin;

  /// The amount of padding to apply to the snack bar's content and optional
  /// action.
  ///
  /// If this property is null, then the default depends on the [behavior] and
  /// the presence of an [action]. The start padding is 24 if [behavior] is
  /// [SnackBarBehavior.fixed] and 16 if it is [SnackBarBehavior.floating]. If
  /// there is no [action], the same padding is added to the end.
  final EdgeInsetsGeometry padding;

  /// The width of the snack bar.
  ///
  /// If width is specified, the snack bar will be centered horizontally in the
  /// available space. This property is only used when [behavior] is
  /// [SnackBarBehavior.floating]. It can not be used if [margin] is specified.
  ///
  /// If this property is null, then the snack bar will take up the full device
  /// width less the margin.
  final double width;

  /// The shape of the snack bar's [Material].
  ///
  /// Defines the snack bar's [Material.shape].
  ///
  /// If this property is null then [SnackBarThemeData.shape] of
  /// [ThemeData.snackBarTheme] is used. If that's null then the shape will
  /// depend on the [SnackBarBehavior]. For [SnackBarBehavior.fixed], no
  /// overriding shape is specified, so the [SnackBar] is rectangular. For
  /// [SnackBarBehavior.floating], it uses a [RoundedRectangleBorder] with a
  /// circular corner radius of 4.0.
  final ShapeBorder shape;

  /// This defines the behavior and location of the snack bar.
  ///
  /// Defines where a [SnackBar] should appear within a [Scaffold] and how its
  /// location should be adjusted when the scaffold also includes a
  /// [FloatingActionButton] or a [BottomNavigationBar]
  ///
  /// If this property is null, then [SnackBarThemeData.behavior] of
  /// [ThemeData.snackBarTheme] is used. If that is null, then the default is
  /// [SnackBarBehavior.fixed].
  final SnackBarBehavior behavior;

  /// (optional) An action that the user can take based on the snack bar.
  ///
  /// For example, the snack bar might let the user undo the operation that
  /// prompted the snackbar. Snack bars can have at most one action.
  ///
  /// The action should not be "dismiss" or "cancel".
  final SnackBarAction action;

  /// The amount of time the snack bar should be displayed.
  ///
  /// Defaults to 4.0s.
  ///
  /// See also:
  ///
  ///  * [ScaffoldMessengerState.removeCurrentSnackBar], which abruptly hides the
  ///    currently displayed snack bar, if any, and allows the next to be
  ///    displayed.
  ///  * <https://material.io/design/components/snackbars.html>
  final Duration duration;

  /// The animation driving the entrance and exit of the snack bar.
  final Animation<double> animation;

  /// Called the first time that the snackbar is visible within a [Scaffold].
  final VoidCallback onVisible;

  // API for ScaffoldMessengerState.showSnackBar():

  /// Creates an animation controller useful for driving a snack bar's entrance and exit animation.
  static AnimationController createAnimationController(
      {@required TickerProvider vsync}) {
    return AnimationController(
      duration: _snackBarTransitionDuration,
      debugLabel: 'SnackBar',
      vsync: vsync,
    );
  }

  /// Creates a copy of this snack bar but with the animation replaced with the given animation.
  ///
  /// If the original snack bar lacks a key, the newly created snack bar will
  /// use the given fallback key.
  SnackBar withAnimation(Animation<double> newAnimation, {Key fallbackKey}) {
    return MySnackBar(
      key: key ?? fallbackKey,
      content: content,
      backgroundColor: backgroundColor,
      elevation: elevation,
      margin: margin,
      padding: padding,
      width: width,
      shape: shape,
      behavior: behavior,
      action: action,
      duration: duration,
      animation: newAnimation,
      onVisible: onVisible,
    );
  }

  @override
  State<MySnackBar> createState() => _MySnackBarState();

  @override
  DismissDirection get dismissDirection => DismissDirection.down;
}

class _MySnackBarState extends State<MySnackBar> {
  bool _wasVisible = false;

  @override
  void initState() {
    super.initState();
    widget.animation.addStatusListener(_onAnimationStatusChanged);
  }

  @override
  void didUpdateWidget(SnackBar oldWidget) {
    if (widget.animation != oldWidget.animation) {
      oldWidget.animation.removeStatusListener(_onAnimationStatusChanged);
      widget.animation.addStatusListener(_onAnimationStatusChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    super.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus animationStatus) {
    switch (animationStatus) {
      case AnimationStatus.dismissed:
      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        break;
      case AnimationStatus.completed:
        if (widget.onVisible != null && !_wasVisible) {
          widget.onVisible();
        }
        _wasVisible = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    assert(widget.animation != null);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final SnackBarThemeData snackBarTheme = theme.snackBarTheme;
    final bool isThemeDark = theme.brightness == Brightness.dark;
    final Color buttonColor =
        isThemeDark ? colorScheme.primaryVariant : colorScheme.secondary;

    // SnackBar uses a theme that is the opposite brightness from
    // the surrounding theme.
    final Brightness brightness =
        isThemeDark ? Brightness.light : Brightness.dark;
    final Color themeBackgroundColor = isThemeDark
        ? colorScheme.onSurface
        : Color.alphaBlend(
            colorScheme.onSurface.withOpacity(0.80), colorScheme.surface);
    final ThemeData inverseTheme = theme.copyWith(
      colorScheme: ColorScheme(
        primary: colorScheme.onPrimary,
        primaryVariant: colorScheme.onPrimary,
        // For the button color, the spec says it should be primaryVariant, but for
        // backward compatibility on light themes we are leaving it as secondary.
        secondary: buttonColor,
        secondaryVariant: colorScheme.onSecondary,
        surface: colorScheme.onSurface,
        background: themeBackgroundColor,
        error: colorScheme.onError,
        onPrimary: colorScheme.primary,
        onSecondary: colorScheme.secondary,
        onSurface: colorScheme.surface,
        onBackground: colorScheme.background,
        onError: colorScheme.error,
        brightness: brightness,
      ),
    );

    final TextStyle contentTextStyle = snackBarTheme.contentTextStyle ??
        ThemeData(brightness: brightness).textTheme.subtitle1;
    final SnackBarBehavior snackBarBehavior =
        widget.behavior ?? snackBarTheme.behavior ?? SnackBarBehavior.fixed;
    final bool isFloatingSnackBar =
        snackBarBehavior == SnackBarBehavior.floating;
    final double horizontalPadding = isFloatingSnackBar ? 16.0 : 24.0;
    final EdgeInsetsGeometry padding = widget.padding ??
        EdgeInsetsDirectional.only(
            start: horizontalPadding,
            end: widget.action != null ? 0 : horizontalPadding);

    final double actionHorizontalMargin =
        (widget.padding?.resolve(TextDirection.ltr)?.right ??
                horizontalPadding) /
            2;

    final CurvedAnimation heightAnimation =
        CurvedAnimation(parent: widget.animation, curve: _snackBarHeightCurve);
    final CurvedAnimation fadeInAnimation =
        CurvedAnimation(parent: widget.animation, curve: _snackBarFadeInCurve);
    final CurvedAnimation fadeOutAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: _snackBarFadeOutCurve,
      reverseCurve: const Threshold(0.0),
    );

    Widget snackBar = Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          isFloatingSnackBar
              ? Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: _singleLineVerticalPadding),
                    child: DefaultTextStyle(
                      style: contentTextStyle,
                      child: widget.content,
                    ),
                  ),
                )
              : Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: _singleLineVerticalPadding),
                    child: DefaultTextStyle(
                      style: contentTextStyle,
                      child: widget.content,
                    ),
                  ),
                ),
          if (widget.action != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: actionHorizontalMargin),
              child: TextButtonTheme(
                data: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    primary: buttonColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                  ),
                ),
                child: widget.action,
              ),
            ),
        ],
      ),
    );

    if (!isFloatingSnackBar) {
      snackBar = SafeArea(
        top: false,
        child: snackBar,
      );
    }

    final double elevation = widget.elevation ?? snackBarTheme.elevation ?? 6.0;
    final Color backgroundColor = widget.backgroundColor ??
        snackBarTheme.backgroundColor ??
        inverseTheme.colorScheme.background;
    final ShapeBorder shape = widget.shape ??
        snackBarTheme.shape ??
        (isFloatingSnackBar
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))
            : null);

    snackBar = Material(
      shape: shape,
      elevation: elevation,
      color: backgroundColor,
      child: Theme(
        data: inverseTheme,
        child: mediaQueryData.accessibleNavigation
            ? snackBar
            : FadeTransition(
                opacity: fadeOutAnimation,
                child: snackBar,
              ),
      ),
    );

    if (isFloatingSnackBar) {
      const double topMargin = 5.0;
      const double bottomMargin = 10.0;
      // If width is provided, do not include horizontal margins.
      if (widget.width != null) {
        snackBar = Container(
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(top: topMargin, bottom: bottomMargin),
          width: widget.width,
          child: snackBar,
        );
      } else {
        const double horizontalMargin = 15.0;
        snackBar = Row(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Padding(
                  padding: widget.margin ??
                      const EdgeInsets.fromLTRB(
                        horizontalMargin,
                        topMargin,
                        horizontalMargin,
                        bottomMargin,
                      ),
                  child: snackBar),
            )
          ],
          mainAxisAlignment: widget.placement == SnackPlacement.CENTER
              ? MainAxisAlignment.center
              : widget.placement == SnackPlacement.RIGHT
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
        );
      }
      snackBar = SafeArea(
        top: false,
        bottom: false,
        child: snackBar,
      );
    }

    snackBar = Semantics(
      container: true,
      liveRegion: true,
      onDismiss: () {
        Scaffold.of(context)
            // ignore: deprecated_member_use
            .removeCurrentSnackBar(reason: SnackBarClosedReason.dismiss);
      },
      child: Dismissible(
        key: const Key('dismissible'),
        direction: DismissDirection.down,
        resizeDuration: null,
        onDismissed: (DismissDirection direction) {
          Scaffold.of(context)
              // ignore: deprecated_member_use
              .removeCurrentSnackBar(reason: SnackBarClosedReason.swipe);
        },
        child: snackBar,
      ),
    );

    Widget snackBarTransition;
    if (mediaQueryData.accessibleNavigation) {
      snackBarTransition = snackBar;
    } else if (isFloatingSnackBar) {
      snackBarTransition = FadeTransition(
        opacity: fadeInAnimation,
        child: snackBar,
      );
    } else {
      snackBarTransition = AnimatedBuilder(
        animation: heightAnimation,
        builder: (BuildContext context, Widget child) {
          return Align(
            alignment: AlignmentDirectional.topStart,
            heightFactor: heightAnimation.value,
            child: child,
          );
        },
        child: snackBar,
      );
    }

    return Hero(
      child: ClipRect(child: snackBarTransition),
      tag: '<SnackBar Hero tag - ${widget.content}>',
    );
  }
}
