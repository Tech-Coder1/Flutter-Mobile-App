import 'package:flutter/material.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  final List<Map<String, dynamic>> _courses = const [
    {
      'title': 'Flutter Development',
      'duration': '8 weeks',
      'level': 'Beginner',
      'description': 'Learn to build beautiful mobile apps with Flutter',
      'enrolled': false,
    },
    {
      'title': 'Advanced Dart Programming',
      'duration': '6 weeks',
      'level': 'Intermediate',
      'description': 'Master advanced concepts in Dart programming',
      'enrolled': true,
    },
    {
      'title': 'UI/UX Design Principles',
      'duration': '4 weeks',
      'level': 'Beginner',
      'description': 'Learn the fundamentals of user interface design',
      'enrolled': false,
    },
    {
      'title': 'Mobile App Architecture',
      'duration': '10 weeks',
      'level': 'Advanced',
      'description': 'Design scalable and maintainable mobile applications',
      'enrolled': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Courses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course['title'],
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getLevelColor(course['level']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course['level'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Text(
                        'Duration: ${course['duration']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    course['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF374151),
                        ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: course['enrolled'] ? null : () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: course['enrolled'] ? Colors.grey : const Color(0xFF4169E1),
                      ),
                      child: Text(course['enrolled'] ? 'Enrolled' : 'Enroll Now'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return const Color(0xFF4169E1);
    }
  }
}