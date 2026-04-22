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

  late final Float32List _v2storage; // copy to local to speed access

  NotifyingVector2.zero() : super.zero() {
    _v2storage = super.storage;
  }

  factory NotifyingVector2.all(double v) => NotifyingVector2.zero()..splat(v);

  factory NotifyingVector2.copy(Vector2 v) =>
      NotifyingVector2.zero()..setFrom(v);

  @override
  void setValues(double x, double y) {
    if (_v2storage[0] == x && _v2storage[1] == y) return;
    super.setValues(x, y);
    if (_count > 0) _notifyListeners();
  }

  @override
  void setFrom(Vector2 other) {
    if (_v2storage[0] == other.x && _v2storage[1] == other.y) return;
    super.setFrom(other);
    if (_count > 0) _notifyListeners();
  }

  @override
  void setZero() {
    if (_v2storage[0] == 0 && _v2storage[1] == 0) return;
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
    if (_v2storage[0] == x) return;
    super.x = x;
    if (_count > 0) _notifyListeners();
  }

  @override
  set y(double y) {
    if (_v2storage[1] == y) return;
    super.y = y;
    if (_count > 0) _notifyListeners();
  }

  @override
  Float32List get storage {
    return super.storage.asUnmodifiableView();
  }

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

    // if (_notifyCount++ % 1000 == 0) _logr.always.log(() => 'NOTIFY-LISTENERS > $_notifyCount > $_count > ${caller(2)}');
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

abstract class _NotifyingVector2 extends Vector2 implements NotifyingVector2 {

  _NotifyingVector2.zero() : super.zero();

  StateError get _error => StateError('invalid call for $runtimeType');

  @override
  dynamic noSuchMethod(Invocation invocation) => throw _error;
}

/// A notifying vector that contains a required single listener
class SingleListenerNotifyingVector2 extends _NotifyingVector2 {

  VoidCallback? _listener;

  @override
  Float32List get storage => throw _error;

  @override
  late final Float32List _v2storage; // copy to local to speed access

  // static var _notifyCount = 0;
  SingleListenerNotifyingVector2(double x, double y): super.zero() {
    _v2storage = super.storage;
    setValues(x, y);
    // if (_notifyCount++ % 100 == 0) _logr.always.log(() => 'SINGLE-NOTIF-VECS > $_notifyCount > ${caller(2)}');
  }

  // factory SingleListenerNotifyingVector2({VoidCallback? listener, Vector2? copyFrom}): super.zero() {
  //   if (copyFrom != null) setFrom(copyFrom);
  //   if (listener != null) _listener = listener;
  //   _v2storage = super.storage;
  //   if (_notifyCount++ % 100 == 0) _logr.always.log(() => 'SINGLE-NOTIF-VECS > $_notifyCount > ${caller(2)}');
  // }

  @override
  void setValues(double x, double y) {
    if (_v2storage[0] == x && _v2storage[1] == y) return;
    super.setValues(x, y);
    _listener?.call();
  }

  @override
  void setFrom(Vector2 other) {
    if (_v2storage[0] == other.x && _v2storage[1] == other.y) return;
    super.setFrom(other);
    _listener?.call();
  }

  @override
  void setZero() {
    if (_v2storage[0] == 0 && _v2storage[1] == 0) return;
    super.setZero();
    _listener?.call();
  }


  @override
  void splat(double arg) {
    super.splat(arg);
    _listener?.call();
  }

  @override
  void operator []=(int i, double v) {
    super[i] = v;
    _listener?.call();
  }

  @override
  set length(double l) {
    super.length = l;
    _listener?.call();
  }

  @override
  double normalize() {
    final l = super.normalize();
    _listener?.call();
    return l;
  }

  @override
  void postmultiply(Matrix2 arg) {
    super.postmultiply(arg);
    _listener?.call();
  }

  @override
  void add(Vector2 arg) {
    super.add(arg);
    _listener?.call();
  }

  @override
  void addScaled(Vector2 arg, double factor) {
    super.addScaled(arg, factor);
    _listener?.call();
  }

  @override
  void sub(Vector2 arg) {
    super.sub(arg);
    _listener?.call();
  }

  @override
  void multiply(Vector2 arg) {
    super.multiply(arg);
    _listener?.call();
  }

  @override
  void divide(Vector2 arg) {
    super.divide(arg);
    _listener?.call();
  }

  @override
  void scale(double arg) {
    super.scale(arg);
    _listener?.call();
  }

  @override
  void negate() {
    super.negate();
    _listener?.call();
  }

  @override
  void absolute() {
    super.absolute();
    _listener?.call();
  }

  @override
  void clamp(Vector2 min, Vector2 max) {
    super.clamp(min, max);
    _listener?.call();
  }

  @override
  void clampScalar(double min, double max) {
    super.clampScalar(min, max);
    _listener?.call();
  }

  @override
  void floor() {
    super.floor();
    _listener?.call();
  }

  @override
  void ceil() {
    super.ceil();
    _listener?.call();
  }

  @override
  void round() {
    super.round();
    _listener?.call();
  }

  @override
  void roundToZero() {
    super.roundToZero();
    _listener?.call();
  }

  @override
  void copyFromArray(List<double> array, [int offset = 0]) {
    super.copyFromArray(array, offset);
    _listener?.call();
  }

  @override
  set xy(Vector2 arg) {
    super.xy = arg;
    _listener?.call();
  }

  @override
  set yx(Vector2 arg) {
    super.yx = arg;
    _listener?.call();
  }

  @override
  set x(double x) {
    if (_v2storage[0] == x) return;
    super.x = x;
    _listener?.call();
  }

  @override
  set y(double y) {
    if (_v2storage[1] == y) return;
    super.y = y;
    _listener?.call();
  }

  // @override
  // Float32List get storage => super.storage.asUnmodifiableView();

  static var _callbackHellCount = 0;

  @override
  void addListener(VoidCallback listener) {
    final t = _listener;
    if (t != null) {
      Telemetry().error('callback hell detected', fatal: false);
      // _listener = () {
      //   t();
      //   listener();
      //   _logr.always.log(() => 'COMPOUND LISTENERS > ${caller(4)}');
      // };
    }

    _listener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    if (listener != _listener) {
      throw StateError('invalid call to removeListener > $listener > $_listener');
    }
    _listener = null;
  }

  @override
  void dispose() {
    _listener = null;
  }
}


class ImmutableVector2 extends _NotifyingVector2 {

  // ignore: unused_field, unused_element
  static const _logr = Logr(true, prefix: 'immutable_vector2');

  static final ImmutableVector2 zero = ImmutableVector2._zero();
  static final ImmutableVector2 one = ImmutableVector2(1.0, 1.0);

  factory ImmutableVector2(double x, double y) =>
      ImmutableVector2._zero().._setValues(x, y);

  factory ImmutableVector2.divide(Vector2 vector, double divider) =>
      ImmutableVector2(vector.x / divider, vector.y / divider);

  factory ImmutableVector2.copy(Vector2 vector) =>
      ImmutableVector2(vector.x, vector.y);

  // static var _notifyCount = 0;
  ImmutableVector2._zero() : super.zero() {
    // if (_notifyCount++ % 100 == 0) _logr.always.log(() => 'IMMUTABLE-VECS > $_notifyCount > ${caller(4)}');
  }

  @override
  Float32List get storage => throw _error;

  void _setValues(double x_, double y_) =>
      super.setValues(x_, y_);

  NotifyingVector2 toMutable() => NotifyingVector2(x, y);

  @override
  void setValues(double x_, double y_) => throw _error;
  @override
  void setZero() => throw _error;
  @override
  void setFrom(Vector2 other) => throw _error;
  @override
  void splat(double arg) => throw _error;
  @override
  void operator []=(int i, double v) => throw _error;
  @override
  set length(double value) => throw _error;
  @override
  double normalize() => throw _error;
  @override
  double normalizeLength() => throw _error;
  @override
  void postmultiply(Matrix2 arg) => throw _error;
  @override
  void reflect(Vector2 normal) => throw _error;
  @override
  void add(Vector2 arg) => throw _error;
  @override
  void addScaled(Vector2 arg, double factor) => throw _error;
  @override
  void sub(Vector2 arg) => throw _error;
  @override
  void multiply(Vector2 arg) => throw _error;
  @override
  void divide(Vector2 arg) => throw _error;
  @override
  void scale(double arg) => throw _error;
  @override
  void negate() => throw _error;
  @override
  void absolute() => throw _error;
  @override
  void clamp(Vector2 min, Vector2 max) => throw _error;
  @override
  void clampScalar(double min, double max) => throw _error;
  @override
  void floor() => throw _error;
  @override
  void ceil() => throw _error;
  @override
  void round() => throw _error;
  @override
  void roundToZero() => throw _error;
  @override
  void copyFromArray(List<double> array, [int offset = 0]) => throw _error;
  @override
  set xy(Vector2 arg) => throw _error;
  @override
  set yx(Vector2 arg) => throw _error;
  @override
  set r(double arg) => throw _error;
  @override
  set g(double arg) => throw _error;
  @override
  set s(double arg) => throw _error;
  @override
  set t(double arg) => throw _error;
  @override
  set x(double arg) => throw _error;
  @override
  set y(double arg) => throw _error;
  @override
  set rg(Vector2 arg) => throw _error;
  @override
  set gr(Vector2 arg) => throw _error;
  @override
  set st(Vector2 arg) => throw _error;
  @override
  set ts(Vector2 arg) => throw _error;
}

