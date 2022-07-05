import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class OverRidStack extends Stack {
  OverRidStack({
    Key? key,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection? textDirection,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
    List<Widget> children = const <Widget>[],
  }) : super(
    key: key,
    alignment: alignment,
    textDirection: textDirection,
    fit: fit,
    clipBehavior: clipBehavior,
    children: children,
  );

  @override
  RenderStack createRenderObject(BuildContext context) {
    return OverRidRenderStack(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.of(context),
      fit: fit,
      clipBehavior: clipBehavior,
    );
  }
}

class OverRidRenderStack extends RenderStack {
  OverRidRenderStack({
    List<RenderBox>? children,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection? textDirection,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
  }) : super(
    children: children,
    alignment: alignment,
    textDirection: textDirection,
    fit: fit,
    clipBehavior: clipBehavior,
  );

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}