import 'package:flutter/material.dart';

class SmoothNavigator {
  // Push a new route with a smooth animation
  static Future<T?> push<T extends Object?>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300), // Animation duration
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Define your custom transition here
          const begin = Offset(1.0, 0.0); // Slide in from the right
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  // Pop the current route with a smooth animation
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }

  // Push a new route and remove all previous routes until the predicate returns true
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
      BuildContext context,
      Widget page,
      RoutePredicate predicate,
      ) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide in from the right
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
      predicate,
    );
  }

  // Replace the current route with a new route and smooth animation
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
      BuildContext context,
      Widget page,
      ) {
    return Navigator.of(context).pushReplacement<T, TO>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide in from the right
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  // Push a named route with a smooth animation
  static Future<T?> pushNamed<T extends Object?>(
      BuildContext context,
      String routeName, {
        Object? arguments,
      }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  // Push a named route and remove all previous routes until the predicate returns true
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
      BuildContext context,
      String routeName,
      RoutePredicate predicate, {
        Object? arguments,
      }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }
}