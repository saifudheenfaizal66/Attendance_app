import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DemoDataSeeder {
  static Future<void> addDemoHolidays(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Demo Holidays for 2024/2025
    final holidays = [
      {'name': 'Christmas', 'date': DateTime(2024, 12, 25)},
      {'name': 'New Year', 'date': DateTime(2025, 1, 1)},
      {'name': 'Republic Day', 'date': DateTime(2025, 1, 26)},
      {'name': 'Holi', 'date': DateTime(2025, 3, 14)},
      {'name': 'Independence Day', 'date': DateTime(2025, 8, 15)},
      {'name': 'Gandhi Jayanti', 'date': DateTime(2025, 10, 2)},
    ];

    for (var holiday in holidays) {
      final docRef = firestore.collection('holidays').doc();
      batch.set(docRef, {
        'name': holiday['name'],
        'date': Timestamp.fromDate(holiday['date'] as DateTime),
      });
    }

    try {
      await batch.commit();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo holidays added successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding holidays: $e')),
        );
      }
    }
  }
}
