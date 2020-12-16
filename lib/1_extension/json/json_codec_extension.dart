
import 'dart:convert';
import 'package:flutter/material.dart';

extension JsonCodeExtension on JsonCodec {
  dynamic qlDecode(String source, {@required Object returnObj, dynamic defaultValue = '233'}) {
    if (source != null) return json.decode(source);
    if (returnObj == int) return defaultValue == '233' ? 0 : defaultValue;
    if (returnObj == bool) return defaultValue == '233' ? false : defaultValue;
    if (returnObj == List) return defaultValue == '233' ? [] : defaultValue;
    if (returnObj == Map)  return defaultValue == '233' ? {} : defaultValue;
    if (returnObj == String) return defaultValue == '233' ? ' ' : defaultValue;
    return defaultValue == '233' ? null : defaultValue;
  }
}