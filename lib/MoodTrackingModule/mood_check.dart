import 'package:flutter/material.dart';
import 'models/mood_model.dart';

class QuickMoodCheck extends StatelessWidget {
  final Function(Mood) onMoodSelected;
  final String? selectedEmoji;

  const QuickMoodCheck({
    super.key,
    required this.onMoodSelected,
    this.selectedEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurple.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.insights),
                SizedBox(width: 8),
                Text(
                  'Quick Mood Check',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MoodButton(
                    mood: Mood(name: 'Great', emoji: '😊', timestamp: DateTime.now()),
                    onMoodSelected: onMoodSelected,
                    isSelected: selectedEmoji == '😊'),
                MoodButton(
                    mood: Mood(name: 'Good', emoji: '🙂', timestamp: DateTime.now()),
                    onMoodSelected: onMoodSelected,
                    isSelected: selectedEmoji == '🙂'),
                MoodButton(
                    mood: Mood(name: 'Okay', emoji: '😐', timestamp: DateTime.now()),
                    onMoodSelected: onMoodSelected,
                    isSelected: selectedEmoji == '😐'),
                MoodButton(
                    mood: Mood(name: 'Low', emoji: '😟', timestamp: DateTime.now()),
                    onMoodSelected: onMoodSelected,
                    isSelected: selectedEmoji == '😟'),
                MoodButton(
                    mood: Mood(name: 'Tough', emoji: '😢', timestamp: DateTime.now()),
                    onMoodSelected: onMoodSelected,
                    isSelected: selectedEmoji == '😢'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MoodButton extends StatelessWidget {
  final Mood mood;
  final Function(Mood) onMoodSelected;
  final bool isSelected;

  const MoodButton({
    super.key,
    required this.mood,
    required this.onMoodSelected,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onMoodSelected(mood.copyWith(timestamp: DateTime.now())),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: const Color(0xFF2196F3), width: 3)
                  : null,
              color: isSelected ? const Color(0xFF2196F3).withOpacity(0.1) : null,
            ),
            child: Center(
              child: Text(
                mood.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mood.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF2196F3) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

extension MoodCopyWith on Mood {
  Mood copyWith({String? emoji, String? name, DateTime? timestamp}) {
    return Mood(
      emoji: emoji ?? this.emoji,
      name: name ?? this.name,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
