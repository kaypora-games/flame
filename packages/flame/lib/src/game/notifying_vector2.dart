// ignore_for_file: always_put_control_body_on_new_line

import 'package:flutter/foundation.dart';
import 'package:plato/plato.dart';
import 'package:vector_math/vector_math.dart';

// ignore: unused_element
const _logr = Logr(true, prefix: 'notifying_vector2');

/// Extension of the standard [Vector2] class, implementing the [ChangeNotifier]
/// functionality. This allows any interested party to be notified when the
/// value of this vector changes.
///
/// This class can be used as a regular [Vector2] class. However, if you do
/// subscribe to notifications, don't forget to eventually unsubscribe in
/// order to avoid resource leaks.
///
/// Direct modification of this vector's [storage] is not allowed.
class NotifyingVector2 extends Vector2 { // with ChangeNotifier {

  factory NotifyingVector2(double x, double y) =>
      NotifyingVector2.zero()..setValues(x, y);

  NotifyingVector2.zero() : super.zero();

  factory NotifyingVector2.all(double v) => NotifyingVector2.zero()..splat(v);

  factory NotifyingVector2.copy(Vector2 v) =>
      NotifyingVector2.zero()..setFrom(v);

  @override
  void setValues(double x, double y) {
    if (this.x == x && this.y == y) return;
    super.setValues(x, y);
    if (_count > 0) _notifyListeners();
  }

  @override
  void setFrom(Vector2 other) {
    if (this == other) return; // greatly reduce the number of unnecessary calls
    super.setFrom(other);
    if (_count > 0) _notifyListeners();
  }

  @override
  void setZero() {
    super.setZero();
    if (_count > 0) _notifyListeners();
  }

  @override
  void splat(double arg) {
    super.splat(arg);
    if (_count > 0) _notifyListeners();
  }

  @override
  void operator []=(int i, double v) {
    super[i] = v;
    if (_count > 0) _notifyListeners();
  }

  @override
  set length(double l) {
    super.length = l;
    if (_count > 0) _notifyListeners();
  }

  @override
  double normalize() {
    final l = super.normalize();
    if (_count > 0) _notifyListeners();
    return l;
  }

  @override
  void postmultiply(Matrix2 arg) {
    super.postmultiply(arg);
    if (_count > 0) _notifyListeners();
  }

  @override
  void add(Vector2 arg) {
    super.add(arg);
    if (_count > 0) _notifyListeners();
  }

  @override
  void addScaled(Vector2 arg, double factor) {
    super.addScaled(arg, factor);
    if (_count > 0) _notifyListeners();
  }

  @override
  void sub(Vector2 arg) {
    super.sub(arg);
    if (_count > 0) _notifyListeners();
  }

  @override
  void multiply(Vector2 arg) {
    super.multiply(arg);
    if (_count > 0) _notifyListeners();
  }

  @override
  void divide(Vector2 arg) {
    super.divide(arg);
    if (_count > 0) _notifyListeners();
  }

  @override
  void scale(double arg) {
    super.scale(arg);
    if (_count > 0) _notifyListeners();
  }

  @override
  void negate() {
    super.negate();
    if (_count > 0) _notifyListeners();
  }

  @override
  void absolute() {
    super.absolute();
    if (_count > 0) _notifyListeners();
  }

  @override
  void clamp(Vector2 min, Vector2 max) {
    super.clamp(min, max);
    if (_count > 0) _notifyListeners();
  }

  @override
  void clampScalar(double min, double max) {
    super.clampScalar(min, max);
    if (_count > 0) _notifyListeners();
  }

  @override
  void floor() {
    super.floor();
    if (_count > 0) _notifyListeners();
  }

  @override
  void ceil() {
    super.ceil();
    if (_count > 0) _notifyListeners();
  }

  @override
  void round() {
    super.round();
    if (_count > 0) _notifyListeners();
  }

  @override
  void roundToZero() {
    super.roundToZero();
    if (_count > 0) _notifyListeners();
  }

  @override
  void copyFromArray(List<double> array, [int offset = 0]) {
    super.copyFromArray(array, offset);
    if (_count > 0) _notifyListeners();
  }

  @override
  set xy(Vector2 arg) {
    super.xy = arg;
    if (_count > 0) _notifyListeners();
  }

  @override
  set yx(Vector2 arg) {
    super.yx = arg;
    if (_count > 0) _notifyListeners();
  }

  @override
  set x(double x) {
    if (this.x == x) return;
    super.x = x;
    if (_count > 0) _notifyListeners();
  }

  @override
  set y(double y) {
    if (this.y == y) return;
    super.y = y;
    if (_count > 0) _notifyListeners();
  }

  @override
  Float32List get storage => super.storage.asUnmodifiableView();

  // copied from ChangeNotifier

  int _count = 0;
  static final List<VoidCallback?> _emptyListeners = List<VoidCallback?>.filled(0, null);
  List<VoidCallback?> _listeners = _emptyListeners;
  int _notificationCallStackDepth = 0;
  int _reentrantlyRemovedListeners = 0;

  void addListener(VoidCallback listener) { // copied as it is from ChangeNotifier

    if (_count == _listeners.length) {
      if (_count == 0) {
        _listeners = List<VoidCallback?>.filled(1, null);
      } else {
        final newListeners = List<VoidCallback?>.filled(_listeners.length + 1, null);
        for (var i = 0; i < _count; i++) {
          newListeners[i] = _listeners[i];
        }
        _listeners = newListeners;
      }
    }
    _listeners[_count++] = listener;

  }

  void _removeAt(int index) { // copied as it is from ChangeNotifier
    _count -= 1;
    if (_count * 2 <= _listeners.length) {
      final newListeners = List<VoidCallback?>.filled(_count, null);
      for (var i = 0; i < index; i++) {
        newListeners[i] = _listeners[i];
      }
      for (var i = index; i < _count; i++) {
        newListeners[i] = _listeners[i + 1];
      }
      _listeners = newListeners;
    } else {
      for (var i = index; i < _count; i++) {
        _listeners[i] = _listeners[i + 1];
      }
      _listeners[_count] = null;
    }
  }

  void removeListener(VoidCallback listener) { // copied as it is from ChangeNotifier
    for (var i = 0; i < _count; i++) {
      final listenerAtIndex = _listeners[i];
      if (listenerAtIndex == listener) {
        if (_notificationCallStackDepth > 0) {
          _listeners[i] = null;
          _reentrantlyRemovedListeners++;
        } else {
          _removeAt(i);
        }
        break;
      }
    }
  }

  void dispose() { // copied as it is from ChangeNotifier
    _listeners = _emptyListeners;
    _count = 0;
  }

  // static var _notifyCount = 0;
  void _notifyListeners() { // copied as it is from ChangeNotifier

    // if (_notifyCount++ % 100 == 0) _logr.always.log(() => 'NOTIFY-LISTENERS > $_notifyCount > $_count > ${caller(2)}');
    // if (_count == 0) return;

    _notificationCallStackDepth++;

    final end = _count;
    for (var i = 0; i < end; i++) {
      try {
        _listeners[i]?.call();
      } catch (exception, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'foundation library',
            context: ErrorDescription('while dispatching notifications for $runtimeType'),
          ),
        );
      }
    }

    _notificationCallStackDepth--;

    if (_notificationCallStackDepth == 0 && _reentrantlyRemovedListeners > 0) {
      final newLength = _count - _reentrantlyRemovedListeners;
      if (newLength * 2 <= _listeners.length) {
        final newListeners = List<VoidCallback?>.filled(newLength, null);

        var newIndex = 0;
        for (var i = 0; i < _count; i++) {
          final listener = _listeners[i];
          if (listener != null) {
            newListeners[newIndex++] = listener;
          }
        }

        _listeners = newListeners;
      } else {
        for (var i = 0; i < newLength; i += 1) {
          if (_listeners[i] == null) {
            var swapIndex = i + 1;
            while (_listeners[swapIndex] == null) {
              swapIndex += 1;
            }
            _listeners[i] = _listeners[swapIndex];
            _listeners[swapIndex] = null;
          }
        }
      }

      _reentrantlyRemovedListeners = 0;
      _count = newLength;
    }
  }

}
