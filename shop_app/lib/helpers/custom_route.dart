import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({
    WidgetBuilder builder,
    RouteSettings settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // if (settings.isInitialRoute) { // no idea...
    // }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
    // TODO: implement buildTransitions
    // return super
    //     .buildTransitions(context, animation, secondaryAnimation, child);
 