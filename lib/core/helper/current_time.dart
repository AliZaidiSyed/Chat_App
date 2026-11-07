import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


String formatTime(dynamic timestamp) {
  if (timestamp == null) return '';

  DateTime? dateTime;
  if (timestamp is Timestamp) {
    dateTime = timestamp.toDate();
  } else if (timestamp is DateTime) {
    dateTime = timestamp;
  }

  if (dateTime == null) return '';
  return DateFormat('h:mm a').format(dateTime);
}


Widget currentTime(
    dynamic timestamp, {
      TextStyle? style,
    }) {
  return Text(
    formatTime(timestamp),
    style: style ??
        const TextStyle(
          fontSize: 11,
          color: Colors.grey,
        ),
  );
}