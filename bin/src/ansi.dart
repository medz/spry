import 'dart:io';

import 'package:coal/utils.dart';

bool get _tty => stdout.supportsAnsiEscapes;

String bold(String s) => _tty ? styleText(s, [TextStyle.bold]) : s;
String dim(String s) => _tty ? styleText(s, [TextStyle.dim]) : s;
String green(String s) =>
    _tty ? styleText(s, [TextStyle.green, TextStyle.bold]) : s;
String red(String s) =>
    _tty ? styleText(s, [TextStyle.red, TextStyle.bold]) : s;
String cyan(String s) =>
    _tty ? styleText(s, [TextStyle.cyan, TextStyle.bold]) : s;
String yellow(String s) => _tty ? styleText(s, [TextStyle.yellow]) : s;
String gray(String s) => _tty ? styleText(s, [TextStyle.gray]) : s;
