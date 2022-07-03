import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
import 'package:syntax_highlighter/syntax_highlighter.dart';

class HighLight extends md.SyntaxHighlighter {
  @override
  TextSpan format(String source) {
    final SyntaxHighlighterStyle style =
        SyntaxHighlighterStyle.lightThemeStyle();
    return TextSpan(
        // style: const TextStyle(
        //   fontSize: 12.0,
        //   fontFamily: 'monospace',
        // ),
        children: <TextSpan>[DartSyntaxHighlighter(style).format(source)]);
  }
}
