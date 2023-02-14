import 'package:flutter/material.dart';

class HoldHelp {
  Object _hold;

  bool get canRun => _hold == null;

  void lock() => _lock();

  void unLock() => _hold = null;

  Object _lock() {
    final hold = UniqueKey();

    _hold = hold;

    return hold;
  }

  void _unLock(Object hold) {
    if (_hold == hold) unLock();
  }

  Future<T> lockByAsync<T>(Future<T> future) async {
    final lock = _lock();

    try {
      return await future;
    } finally {
      _unLock(lock);
    }
  }

  Future<T> unLockByErr<T>(Future<T> future) async {
    final lock = _lock();

    try {
      return await future;
    } catch (e) {
      _unLock(lock);

      rethrow;
    }
  }
}
