import 'package:flutter/material.dart';

enum UserMode { guest, customer, restaurant }

class AppSession extends ChangeNotifier {
  UserMode _mode = UserMode.guest;

  UserMode get mode => _mode;

  bool get isAuthenticated => _mode != UserMode.guest;

  void switchMode(UserMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }
}

class AppSessionScope extends InheritedNotifier<AppSession> {
  const AppSessionScope({required AppSession notifier, required super.child, super.key})
      : super(notifier: notifier);

  static AppSession watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppSessionScope>();
    assert(scope != null, 'AppSessionScope não encontrado.');
    return scope!.notifier!;
  }

  static AppSession read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppSessionScope>();
    final scope = element?.widget as AppSessionScope?;
    assert(scope != null, 'AppSessionScope não encontrado.');
    return scope!.notifier!;
  }
}
