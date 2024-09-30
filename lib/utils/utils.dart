import 'package:flutter/material.dart';

String? uValidator({
  @required value,
  bool isRequared = false,
  bool isEmail = false,
  int? minLength,
  String? match,
}) {
  if (isRequared) {
    if (value.isEmpty) {
      return 'Required';
    }
  }
  if (isEmail) {
    if (!value.contains('@') || !value.contains('.')) {
      return 'Invalid Email';
    }
  }

  if (minLength != null) {
    if (value.length < minLength) {
      return 'Min $minLength character';
    }
  }

  if (match != null) {
    if (value != match) {
      return 'Not Match';
    }
  }

  return null;
}
