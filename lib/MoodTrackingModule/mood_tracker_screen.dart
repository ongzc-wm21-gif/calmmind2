import 'package:flutter/material.dart';
import '../database/supabase_service.dart';
import 'models/mood_model.dart';
import 'models/daily_record_model.dart';
import 'daily_habits.dart';
import 'happy_moments.dart';
import 'mood_check.dart';
import 'overview_chart.dart';
import 'phq9_test_screen.dart';
import 'progress_bar.dart';
import 'sleep_energy_tracker.dart';
import 'stress_level_slider.dart';
import 'timeline.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  List<Mood> _moods = [];
  double _progress = 0.4; // Initial progress
  List<DailyRecord> _records = [];
  bool _isLoading = true;
  String? _selectedMoodEmoji; // Track selected mood emoji for today

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadTodayMood();
  }

  Future<void> _loadTodayMood() async {
    try {
      final todayMood = await SupabaseService.instance.getTodayMood();
      if (mounted && todayMood != null) {
        setState(() {
          _selectedMoodEmoji = todayMood.emoji;
        });
      }
    } catch (e) {
      print('Error loading today mood: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final dbHelper = SupabaseService.instance;
    final moods = await dbHelper.getMoods();
    final records = await dbHelper.getDailyRecords();
    
    print('_loadData: Loaded ${records.length} daily records');
    if (records.isNotEmpty) {
      print('_loadData: First record - date: ${records.first.date}, stress: ${records.first.stressLevel}, sleep: ${records.first.sleepQuality}, energy: ${records.first.energyLevel}');
      print('_loadData: Last record - date: ${records.last.date}, stress: ${records.last.stressLevel}, sleep: ${records.last.sleepQuality}, energy: ${records.last.energyLevel}');
    }
    
    setState(() {
      _moods = moods;
      _records = records;
      _isLoading = false;
    });
    
    print('_loadData: State updated with ${_records.length} records');
  }

  Future<void> _onMoodSelected(Mood mood) async {
    try {
      // Use upsert to update if mood exists for today, otherwise insert
      await SupabaseService.instance.upsertMood(mood);
      
      // Update selected mood emoji
      setState(() {
        _selectedMoodEmoji = mood.emoji;
      });
      
      // Reload data
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedMoodEmoji == mood.emoji && _moods.isNotEmpty && _moods.first.emoji == mood.emoji
                ? 'Mood updated: ${mood.name}'
                : 'Mood recorded: ${mood.name}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error saving mood: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving mood: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onProgressChanged(double progress) {
    setState(() {
      _progress = progress;
    });
  }

  Future<void> _updateDailyRecord({
    double? stressLevel,
    int? sleepQuality,
    int? energyLevel,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day); // Normalize to midnight
      final todayRecordIndex = _records.indexWhere((record) =>
          record.date.year == today.year &&
          record.date.month == today.month &&
          record.date.day == today.day);

      DailyRecord record;
      if (todayRecordIndex != -1) {
        final oldRecord = _records[todayRecordIndex];
        record = DailyRecord(
          date: oldRecord.date,
          stressLevel: stressLevel ?? oldRecord.stressLevel,
          sleepQuality: sleepQuality ?? oldRecord.sleepQuality,
          energyLevel: energyLevel ?? oldRecord.energyLevel,
        );
        print('Updating existing record - stress: ${record.stressLevel}, sleep: ${record.sleepQuality}, energy: ${record.energyLevel}');
      } else {
        record = DailyRecord(
          date: today,
          stressLevel: stressLevel ?? 5.0, // Default value
          sleepQuality: sleepQuality ?? 1, // Default value
          energyLevel: energyLevel ?? 1, // Default value
        );
        print('Creating new record - stress: ${record.stressLevel}, sleep: ${record.sleepQuality}, energy: ${record.energyLevel}');
      }
      await SupabaseService.instance.upsertDailyRecord(record);
      
      // Reload data to update the graph
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily record updated successfully'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating daily record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating record: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Blue Header (matching HomePage style)
            _buildHeader(),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const PHQ9TestScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.psychology),
                              label: const Text('Take PHQ-9 Test'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            QuickMoodCheck(
                              onMoodSelected: _onMoodSelected,
                              selectedEmoji: _selectedMoodEmoji,
                            ),
                            const SizedBox(height: 16),
                            Timeline(moods: _moods),
                            const SizedBox(height: 16),
                            StressLevelSlider(
                              onStressChanged: (value) =>
                                  _updateDailyRecord(stressLevel: value),
                            ),
                            const SizedBox(height: 16),
                            SleepEnergyTracker(
                              onSleepChanged: (value) =>
                                  _updateDailyRecord(sleepQuality: value),
                              onEnergyChanged: (value) =>
                                  _updateDailyRecord(energyLevel: value),
                            ),
                            const SizedBox(height: 16),
                            OverviewChart(records: _records),
                            const SizedBox(height: 16),
                            ProgressBar(progress: _progress),
                            const SizedBox(height: 16),
                            DailyHabits(onProgressChanged: _onProgressChanged),
                            const SizedBox(height: 16),
                            const HappyMoments(),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF2196F3), // Blue
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Row(
            children: [
              Icon(Icons.favorite, color: Colors.purple, size: 24),
              SizedBox(width: 8),
              Text(
                'Mood Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }
}

