import 'package:flutter/material.dart';

class InternshipsScreen extends StatelessWidget {
  const InternshipsScreen({super.key});

  final List<Map<String, dynamic>> _internships = const [
    {
      'role': 'Flutter Developer Intern',
      'company': 'TechCorp',
      'location': 'Remote',
      'type': 'Remote',
      'description': 'Work on exciting mobile app projects using Flutter',
    },
    {
      'role': 'UI/UX Design Intern',
      'company': 'DesignStudio',
      'location': 'New York, NY',
      'type': 'Hybrid',
      'description': 'Create beautiful user interfaces for web and mobile',
    },
    {
      'role': 'Backend Developer Intern',
      'company': 'DataSys',
      'location': 'San Francisco, CA',
      'type': 'On-site',
      'description': 'Build robust backend systems with modern technologies',
    },
    {
      'role': 'Data Analyst Intern',
      'company': 'AnalyticsPro',
      'location': 'Remote',
      'type': 'Remote',
      'description': 'Analyze data and create insightful reports',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internship Opportunities'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: _internships.length,
        itemBuilder: (context, index) {
          final internship = _internships[index];
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              internship['role'],
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              internship['company'],
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF4169E1),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getTypeColor(internship['type']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          internship['type'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Text(
                        internship['location'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    internship['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF374151),
                        ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/application_form');
                      },
                      child: const Text('Apply Now'),
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Remote':
        return Colors.green;
      case 'Hybrid':
        return Colors.orange;
      case 'On-site':
        return const Color(0xFF4169E1);
      default:
        return Colors.grey;
    }
  }
}