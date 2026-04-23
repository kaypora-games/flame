// ignore_for_file: always_put_control_body_on_new_line

import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:plato/plato.dart';
import 'package:rive/math.dart';
import 'package:rive/rive.dart';

const _logr = Logr.always(prefix: 'rive-component');

// mixin LogicPositionComponent on PositionComponent {
//
//   ImmutableVector2 get positionLogic => position.toImmutable();
//
//   double get xLogic => x;
//   double get yLogic => y;
//
//   ImmutableVector2 get sizeLogic => size.toImmutable();
//
//   NotifyingVector2 get sizeSuper => size;
//
//   ImmutableVector2 get scaleLogic => scale.toImmutable();
// }

// extension PositionComponentExtension on PositionComponent {

  // ImmutableVector2 get positionLogic {
  //   final t = this;
  //   if (t is RiveComponent) {
  //     return t.positionLogic;
  //   } else {
  //     return position.toImmutable();
  //   }
  // }
  //
  // double get xLogic {
  //   final t = this;
  //   if (t is RiveComponent) {
  //     return t.xLogic;
  //   } else {
  //     return x;
  //   }
  // }
  //
  // double get yLogic {
  //   final t = this;
  //   if (t is RiveComponent) {
  //     return t.yLogic;
  //   } else {
  //     return y;
  //   }
  // }
  //
  // ImmutableVector2 get sizeLogic {
  //   final t = this;
  //   if (t is RiveComponent) {
  //     return t.sizeLogic;
  //   } else {
  //     return size.toImmutable();
  //   }
  // }
  //
  // NotifyingVector2 get sizeSuper {
  //   final t = this;
  //   if (t is RiveComponent) {
  //     return t.sizeSuper;
  //   } else {
  //     return size;
  //   }
  // }
  //
  // ImmutableVector2 get scaleLogic {
  //   final t = this;
  //   if (t is RiveComponent) {
  //     return t.scaleLogic;
  //   } else {
  //     return scale.toImmutable();
  //   }
  // }
// }

class RiveComponent
    extends PositionComponent {

  final Artboard artboard;
  final RiveArtboardRenderer _renderer;
  late Size _renderSize;

  RiveComponent({
    required this.artboard,
    this.masterScale = 1.0,
    bool antialiasing = true,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    super.position,
    /// The logical size of the component.
    /// Default value is ArtboardSize
    Vector2? size,
    super.scale,
    super.angle = 0.0,
    super.anchor = Anchor.topLeft,
    super.children,
    super.priority,
    super.key,
    required this.debugName,
  }) : _renderer = RiveArtboardRenderer(
    antialiasing: antialiasing,
    fit: fit,
    alignment: alignment,
    artboard: artboard,
  ),
        super(size: (size ?? Vector2(artboard.width, artboard.height)) * masterScale) {

    super.size.addListener(_updateRenderSize);
    _updateRenderSize();

    transform.addListener(_onTransformChanged); // added to update logic vectors
  }

  @override
  final double masterScale;

  late final _defaultScale = masterScale == 1.0;

  final String debugName;

  @override
  set position(Vector2 position) {
    super.position = position * masterScale;
    // if (debugId?.contains('fan_crowd_line')??false) _logr.log(() => 'RIVE-COMPONENT > POSITION > $position >> ${positionSuper}');
  }

  // @override
  // NotifyingVector2 get position {
  //   // if (LogicPositionComponent.testingAccess && testAccess) _logr.log(() => 'REVIEW $runtimeType call to position > ${StackTrace.current}');
  //   return super.position;
  // }

  @override
  set scale(Vector2 scale) {
    super.scale = scale * masterScale;
    // if (debugId?.contains('fan_crowd_line')??false) _logr.log(() => 'RIVE-COMPONENT > SCALE > $scale >> ${scaleSuper}');
  }

  // @override
  // NotifyingVector2 get scale {
  //   // if (LogicPositionComponent.testingAccess && testAccess) _logr.log(() => 'REVIEW $runtimeType call to scale > ${StackTrace.current}');
  //   return super.scale;
  // }

  @override
  set x(double x) {
    super.x = x * masterScale;
    // if (debugId?.contains('fan_crowd_line')??false) _logr.log(() => 'RIVE-COMPONENT > X > $x >> ${this.x}');
  }

  // @override
  // double get x {
  //   // if (LogicPositionComponent.testingAccess && testAccess) _logr.log(() => 'REVIEW $runtimeType call to x > ${StackTrace.current}');
  //   return super.x;
  // }

  @override
  set y(double y) {
    super.y = y * masterScale;
    // if (debugId?.contains('fan_crowd_line')??false) _logr.log(() => 'RIVE-COMPONENT > Y > $y >> ${this.y}');
  }

  // @override
  // double get y {
  //   // if (LogicPositionComponent.testingAccess && testAccess) _logr.log(() => 'REVIEW $runtimeType call to y > ${StackTrace.current}');
  //   return super.y;
  // }

  @override
  set size(Vector2 size) {
    super.size = size * masterScale;
    // if (debugId?.contains('fan_crowd_line')??false) _logr.log(() => 'RIVE-COMPONENT > SIZE > $size >> ${this.size}');
  }

  // @override
  // NotifyingVector2 get size {
  //   // if (LogicPositionComponent.testingAccess && testAccess) _logr.log(() => 'REVIEW $runtimeType call to size > ${StackTrace.current}');
  //   return super.size;
  // }

  @override
  set center(Vector2 point) {

    final p = positionLogic; // retrieve position neutralizing master scale
    final c = center;
    position = p + point - c; // set position to new center

    // if (debugId?.contains('fan_crowd_line')??false) _logr.log(() => 'RIVE-COMPONENT > CENTER > $p $point $c >> $positionLogic >> $positionSuper');
  }

  /// Similar to [positionOf()], but applies to any anchor point within
  /// the component
  @override
  Vector2 positionOfAnchor(Anchor anchor) {
    if (anchor == super.anchor) {
      return positionSuper;
    }
    final size = sizeSuper;
    return positionOf(Vector2(anchor.x * size.x, anchor.y * size.y));
  }

  void _updateRenderSize() => _renderSize = sizeSuper.toSize();

  @override
  void render(Canvas canvas) =>
      _renderer.render(canvas, _renderSize);

  @override
  void update(double dt) {
    _renderer.advance(dt);
    if (!_renderer.artboard.advanceSane) { // can be ignored as this is present in fork of rive project
      _logr.info('ARTBOARD-ADVANCE-FAILED > $debugName');
    }
  }


  // copied from LogicPositionComponent

  void _onTransformChanged() {
    _scaleLogic = _positionLogic = null; // force rebuild of logic vectors
  }

  ImmutableVector2? _positionLogic;
  /// Get logic position (ignoring master scale)
  @override
  NotifyingVector2 get positionLogic {
    if (_defaultScale) return super.position;
    return _positionLogic ??= ImmutableVector2.divide(super.position, masterScale);
  }

  // @override
  // NotifyingVector2 get positionSuper => super.position;

  ImmutableVector2? _scaleLogic;
  /// Get logic scale (ignoring master scale)
  @override
  NotifyingVector2 get scaleLogic {
    if (_defaultScale) return super.scale;
    return _scaleLogic ??= ImmutableVector2.divide(super.scale, masterScale);
  }

  // @override
  // NotifyingVector2 get scaleSuper => super.scale;

  /// Get x logic (ignoring master scale)
  @override
  double get xLogic => super.x / masterScale;
  // @override
  // double get xLogic => positionLogic.x;

  // double get xSuper => super.x;

  /// Get y logic (ignoring master scale)
  @override
  double get yLogic => super.y / masterScale;
  // @override
  // double get yLogic => positionLogic.y;

  // double get ySuper => super.y;

  /// Get logic size (ignoring master scale)
  @override
  NotifyingVector2 get sizeLogic {
    if (_defaultScale) return super.size;
    return ImmutableVector2.divide(super.size, masterScale);
  }

  // @override
  // NotifyingVector2 get sizeSuper => super.size;

  // /// Activate this on debug to validate access to position properties size, scale, x, y and position.
  // /// This is very CPU intensive, so never push to production
  // // ignore: dead_code
  // static const testingAccess = false && kDebugMode;
  //
  // static final _testedAccesses = <String>{};
  //
  // /// Test if the stack trace involves a child project or Rive Component, for debug reasons only
  // bool get testAccess {
  //   final s = StackTrace.current.toString();
  //
  //   if (s.split('#') // split by lines
  //       .whereNot((t) => t.contains('FieldChildComponent') || t.contains('MatchGame.update')) // ignore FieldChildComponent
  //       .where((t) => t.contains(runtimeType.toString()) || t.contains('bfut_2')  || t.contains('RiveComponent'))
  //       .isNotEmpty) {
  //     if (_testedAccesses.add(s)) {
  //
  //       s.split('#') // split by lines
  //           .where((t) => t.contains('FieldChildComponent') || t.contains('MatchGame.update')) // ignore FieldChildComponent
  //           .forEach((t) => _logr.log(() => t));
  //
  //       s.split('#') // split by lines
  //           .where((t) => !t.contains('FieldChildComponent')) // ignore FieldChildComponent
  //           .where((t) => t.contains(runtimeType.toString()) || t.contains('bfut_2')  || t.contains('RiveComponent'))
  //           .forEach((t) => _logr.log(() => t));
  //
  //       _logr.warn(() => 'TEST-ACCESS > ${_testedAccesses.length}');
  //       return true;
  //     }
  //   }
  //   return false;
  // }
}

class RiveArtboardRenderer {
  final Artboard artboard;
  final bool antialiasing;
  final BoxFit fit;
  final Alignment alignment;

  RiveArtboardRenderer({
    required this.antialiasing,
    required this.fit,
    required this.alignment,
    required this.artboard,
  }) {
    artboard.antialiasing = antialiasing;
  }

  void advance(double dt) =>
      artboard.advance(dt, nested: true);

  late final aabb = AABB.fromValues(0, 0, artboard.width, artboard.height);

  void render(Canvas canvas, Size size) =>
      _paint(canvas, aabb, size);

  final _transform = Mat2D();
  final _center = Mat2D();

  void _paint(Canvas canvas, AABB bounds, Size size) {
    const position = Offset.zero;

    final contentWidth = bounds[2] - bounds[0];
    final contentHeight = bounds[3] - bounds[1];

    if (contentWidth == 0 || contentHeight == 0) {
      return;
    }

    final x =
        -1 * bounds[0] -
            contentWidth / 2.0 -
            (alignment.x * contentWidth / 2.0);
    final y =
        -1 * bounds[1] -
            contentHeight / 2.0 -
            (alignment.y * contentHeight / 2.0);

    var scaleX = 1.0;
    var scaleY = 1.0;

    canvas.save();
    if (artboard.clip) {
      canvas.clipRect(position & size);
    }

    switch (fit) {
      case BoxFit.fill:
        scaleX = size.width / contentWidth;
        scaleY = size.height / contentHeight;
      case BoxFit.contain:
        final minScale = min(
          size.width / contentWidth,
          size.height / contentHeight,
        );
        scaleX = scaleY = minScale;
      case BoxFit.cover:
        final maxScale = max(
          size.width / contentWidth,
          size.height / contentHeight,
        );
        scaleX = scaleY = maxScale;
      case BoxFit.fitHeight:
        final minScale = size.height / contentHeight;
        scaleX = scaleY = minScale;
      case BoxFit.fitWidth:
        final minScale = size.width / contentWidth;
        scaleX = scaleY = minScale;
      case BoxFit.none:
        scaleX = scaleY = 1.0;
      case BoxFit.scaleDown:
        final minScale = min(
          size.width / contentWidth,
          size.height / contentHeight,
        );
        scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
    }

    Mat2D.setIdentity(_transform);
    _transform[4] = size.width / 2.0 + (alignment.x * size.width / 2.0);
    _transform[5] = size.height / 2.0 + (alignment.y * size.height / 2.0);
    Mat2D.scale(_transform, _transform, Vec2D.fromValues(scaleX, scaleY));
    Mat2D.setIdentity(_center);
    _center[4] = x;
    _center[5] = y;
    Mat2D.multiply(_transform, _transform, _center);

    canvas.translate(
      size.width / 2.0 + (alignment.x * size.width / 2.0),
      size.height / 2.0 + (alignment.y * size.height / 2.0),
    );

    canvas.scale(scaleX, scaleY);
    canvas.translate(x, y);

    artboard.draw(canvas);
    canvas.restore();
  }
}

/// Loads the Artboard from the specified Rive File.
///
/// When [artboardName] is not null it returns the artboard with the specified
/// name, an assertion is triggered if no artboard with that name exists in the
/// file.
Future<Artboard> loadArtboard(
    FutureOr<RiveFile> file, {
      String? artboardName,
    }) async {
  final loaded = await file;
  if (artboardName == null) {
    return loaded.mainArtboard.instance();
  } else {
    final artboard = loaded.artboardByName(artboardName)?.instance();
    assert(
    artboard != null,
    'No artboard with the specified name exists in the RiveFile',
    );
    return artboard!;
  }
}