import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';

class JournalService {
  static const String _storageKey = 'journal_entries';

  // Get all journal entries
  Future<List<JournalEntry>> getAllEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString(_storageKey);

      if (entriesJson == null || entriesJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(entriesJson);
      return decoded.map((e) => JournalEntry.fromMap(e)).toList()
        ..sort(
            (a, b) => b.date.compareTo(a.date)); // Sort by date, newest first
    } catch (e) {
      return [];
    }
  }

  // Save a new entry
  Future<bool> saveEntry(JournalEntry entry) async {
    try {
      final entries = await getAllEntries();
      entries.add(entry);
      return await _saveAllEntries(entries);
    } catch (e) {
      return false;
    }
  }

  // Update an existing entry
  Future<bool> updateEntry(JournalEntry updatedEntry) async {
    try {
      final entries = await getAllEntries();
      final index = entries.indexWhere((e) => e.id == updatedEntry.id);

      if (index != -1) {
        entries[index] = updatedEntry;
        return await _saveAllEntries(entries);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Delete an entry
  Future<bool> deleteEntry(String id) async {
    try {
      final entries = await getAllEntries();
      entries.removeWhere((e) => e.id == id);
      return await _saveAllEntries(entries);
    } catch (e) {
      return false;
    }
  }

  // Get entry by ID
  Future<JournalEntry?> getEntryById(String id) async {
    try {
      final entries = await getAllEntries();
      return entries.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get entries by mood
  Future<List<JournalEntry>> getEntriesByMood(String mood) async {
    try {
      final entries = await getAllEntries();
      return entries.where((e) => e.mood == mood).toList();
    } catch (e) {
      return [];
    }
  }

  // Get entries by date range
  Future<List<JournalEntry>> getEntriesByDateRange(
      DateTime start, DateTime end) async {
    try {
      final entries = await getAllEntries();
      return entries.where((e) {
        return e.date.isAfter(start.subtract(const Duration(days: 1))) &&
            e.date.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Private method to save all entries
  Future<bool> _saveAllEntries(List<JournalEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedEntries = entries.map((e) => e.toMap()).toList();
      final jsonString = jsonEncode(encodedEntries);
      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  // Clear all entries (for testing or reset)
  Future<bool> clearAllEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (e) {
      return false;
    }
  }
}
