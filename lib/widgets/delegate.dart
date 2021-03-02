import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/models/documents/nodes/leaf.dart';
import 'package:flutter_quill/widgets/text_selection.dart';

import 'editor.dart';

typedef EmbedBuilder = Widget Function(BuildContext context, Embed node);

abstract class EditorTextSelectionGestureDetectorBuilderDelegate {
  GlobalKey<EditorState> getEditableTextKey();

  bool getForcePressEnabled();

  bool getSelectionEnabled();
}

class EditorTextSelectionGestureDetectorBuilder {
  final EditorTextSelectionGestureDetectorBuilderDelegate delegate;
  bool shouldShowSelectionToolbar = true;

  EditorTextSelectionGestureDetectorBuilder(this.delegate)
      : assert(delegate != null);

  EditorState getEditor() {
    return delegate.getEditableTextKey().currentState;
  }

  RenderEditor getRenderEditor() {
    return this.getEditor().getRenderEditor();
  }

  onTapDown(TapDownDetails details) {
    getRenderEditor().handleTapDown(details);

    PointerDeviceKind kind = details.kind;
    shouldShowSelectionToolbar = kind == null ||
        kind == PointerDeviceKind.touch ||
        kind == PointerDeviceKind.stylus;
  }

  onForcePressStart(ForcePressDetails details) {
    assert(delegate.getForcePressEnabled());
    shouldShowSelectionToolbar = true;
    if (delegate.getSelectionEnabled()) {
      getRenderEditor().selectWordsInRange(
        details.globalPosition,
        null,
        SelectionChangedCause.forcePress,
      );
    }
  }

  onForcePressEnd(ForcePressDetails details) {
    assert(delegate.getForcePressEnabled());
    getRenderEditor().selectWordsInRange(
      details.globalPosition,
      null,
      SelectionChangedCause.forcePress,
    );
    if (shouldShowSelectionToolbar) {
      getEditor().showToolbar();
    }
  }

  onSingleTapUp(TapUpDetails details) {
    if (delegate.getSelectionEnabled()) {
      getRenderEditor().selectWordEdge(SelectionChangedCause.tap);
    }
  }

  onSingleTapCancel() {}

  onSingleLongTapStart(LongPressStartDetails details) {
    if (delegate.getSelectionEnabled()) {
      getRenderEditor().selectPositionAt(
        details.globalPosition,
        null,
        SelectionChangedCause.longPress,
      );
    }
  }

  onSingleLongTapMoveUpdate(LongPressMoveUpdateDetails details) {
    if (delegate.getSelectionEnabled()) {
      getRenderEditor().selectPositionAt(
        details.globalPosition,
        null,
        SelectionChangedCause.longPress,
      );
    }
  }

  onSingleLongTapEnd(LongPressEndDetails details) {
    if (shouldShowSelectionToolbar) {
      getEditor().showToolbar();
    }
  }

  onDoubleTapDown(TapDownDetails details) {
    if (delegate.getSelectionEnabled()) {
      getRenderEditor().selectWord(SelectionChangedCause.tap);
      if (shouldShowSelectionToolbar) {
        getEditor().showToolbar();
      }
    }
  }

  onDragSelectionStart(DragStartDetails details) {
    getRenderEditor().selectPositionAt(
      details.globalPosition,
      null,
      SelectionChangedCause.drag,
    );
  }

  onDragSelectionUpdate(
      DragStartDetails startDetails, DragUpdateDetails updateDetails) {
    getRenderEditor().selectPositionAt(
      startDetails.globalPosition,
      updateDetails.globalPosition,
      SelectionChangedCause.drag,
    );
  }

  onDragSelectionEnd(DragEndDetails details) {}

  Widget build(HitTestBehavior behavior, Widget child) {
    return EditorTextSelectionGestureDetector(
      onTapDown: onTapDown,
      onForcePressStart:
          delegate.getForcePressEnabled() ? onForcePressStart : null,
      onForcePressEnd: delegate.getForcePressEnabled() ? onForcePressEnd : null,
      onSingleTapUp: onSingleTapUp,
      onSingleTapCancel: onSingleTapCancel,
      onSingleLongTapStart: onSingleLongTapStart,
      onSingleLongTapMoveUpdate: onSingleLongTapMoveUpdate,
      onSingleLongTapEnd: onSingleLongTapEnd,
      onDoubleTapDown: onDoubleTapDown,
      onDragSelectionStart: onDragSelectionStart,
      onDragSelectionUpdate: onDragSelectionUpdate,
      onDragSelectionEnd: onDragSelectionEnd,
      behavior: behavior,
      child: child,
    );
  }
}
