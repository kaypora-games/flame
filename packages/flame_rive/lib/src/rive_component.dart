// ignore_for_file: always_put_control_body_on_new_line

import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:plato/plato.dart';
import 'package:rive/math.dart';
import 'package:rive/rive.dart';

const _logr = Logr.always(prefix: 'rive-component');

final class LogicGate {
  final LogicPositionComponent _component;
  LogicGate._(this._component);

  ActualGate get _actual => _component.actual;
  bool get _defaultScale => _component.defaultScale;
  double get _masterScale => _component.masterScale;

  ImmutableVector2 get position => _defaultScale ?
    ImmutableVector2.copy(_actual.position) :
    ImmutableVector2.divide(_actual.position, _masterScale);

  ImmutableVector2 get scale => _defaultScale ?
    ImmutableVector2.copy(_actual.scale) :
    ImmutableVector2.divide(_actual.scale, _masterScale);

  double get x => _defaultScale ?
    _actual.x :
    _actual.x / _masterScale;

  double get y => _defaultScale ?
    _actual.y :
    _actual.y / _masterScale;

  ImmutableVector2 get size => _defaultScale ?
    ImmutableVector2.copy(_actual.scale) :
    ImmutableVector2.divide(_actual.size, _masterScale);
}

final class ActualGate {
  final LogicPositionComponent _component;
  const ActualGate._(this._component);

  NotifyingVector2 get position => _component.transform.position;
  NotifyingVector2 get scale => _component.transform.scale;
  double get x => _component.transform.x;
  double get y => _component.transform.y;
  NotifyingVector2 get size => _component._sizeSuper;
}

/// A position component that introduces logic coordinates and a master scale
/// This is necessary to work in different scales for the drawing coordinates but preserving the same logic coordinates.
abstract class LogicPositionComponent
    extends PositionComponent {

  /// Master scale provided in constructor
  final double masterScale;

  /// True is scale = 1
  final bool defaultScale;

  LogicPositionComponent({
    required this.masterScale,
    super.position,
    super.size,
    super.scale,
    super.angle = 0.0,
    super.nativeAngle = 0,
    super.anchor = Anchor.topLeft,
    super.children,
    super.priority,
    super.key,
  }):
        defaultScale = masterScale == 1.0 {
    actual = ActualGate._(this);
    logic = LogicGate._(this);
  }

  late final ActualGate actual;
  late final LogicGate logic;

  @override
  set position(Vector2 position) =>
      super.position = defaultScale ? position : position * masterScale;

  @override
  set scale(Vector2 scale) =>
      super.scale = defaultScale ? scale : scale * masterScale;

  @override
  @nonVirtual
  set x(double x) =>
      super.x = defaultScale ? x : x * masterScale;

  @override
  @nonVirtual
  set y(double y) =>
      super.y = defaultScale ? y : y * masterScale;

  @override
  @nonVirtual
  set size(Vector2 size) =>
      super.size = defaultScale ? size :size * masterScale;

  NotifyingVector2 get _sizeSuper => super.size;

  // Uncomment me to make sure no app logic is accessing any of the methods below
  // These methods must be invoked via .actual or .logic properties
  // void _checkCaller() {
  //   final c = caller(1);
  //   if (c.contains('bfut') || c.contains('plato') || c.contains('stokanal')) {
  //     if (Randoms().hit(0.1)) {
  //       _logr.dump(maxFrames: 10, () => 'review call');
  //     }
  //   }
  // }
  // @override
  // NotifyingVector2 get position {
  //   _checkCaller();
  //   return super.position;
  // }
  // @override
  // NotifyingVector2 get scale {
  //   _checkCaller();
  //   return super.scale;
  // }
  // @override
  // double get x {
  //   _checkCaller();
  //   return super.x;
  // }
  // @override
  // double get y {
  //   _checkCaller();
  //   return super.y;
  // }
  // @override
  // NotifyingVector2 get size {
  //   _checkCaller();
  //   return super.size;
  // }
}

class RiveComponent
    extends LogicPositionComponent {

  final Artboard artboard;
  final RiveArtboardRenderer _renderer;
  late Size _renderSize;

  RiveComponent({
    required this.artboard,
    required this.debugLabel,
    required super.masterScale,
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
  }) : _renderer = RiveArtboardRenderer(
    antialiasing: antialiasing,
    fit: fit,
    alignment: alignment,
    artboard: artboard,
  ),
        super(size: (size ?? Vector2(artboard.width, artboard.height)) * masterScale) {

    super.size.addListener(_updateRenderSize);
    _updateRenderSize();

    // _logr.log(() => 'RIVE-COMPONENT > $runtimeType ${debugLabel.fileNameWithoutExtension}');
  }

  final String debugLabel;

  /// Similar to [positionOf()], but applies to any anchor point within
  /// the component
  @override
  Vector2 positionOfAnchor(Anchor anchor) {
    if (anchor == super.anchor) {
      return actual.position;
    }
    final size = actual.size;
    return positionOf(Vector2(anchor.x * size.x, anchor.y * size.y));
  }

  void _updateRenderSize() => _renderSize = actual.size.toSize();

  @override
  void render(Canvas canvas) =>
      _renderer.render(canvas, _renderSize);

  @override
  void update(double dt) {
    _renderer.advance(dt);
    if (!_renderer.artboard.advanceSane) { // can be ignored as this is present in fork of rive project
      _logr.info('ARTBOARD-ADVANCE-FAILED > $debugLabel');
    }
  }
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