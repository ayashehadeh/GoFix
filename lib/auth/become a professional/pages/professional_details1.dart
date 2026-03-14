import 'package:flutter/material.dart';

class ProfessionalDetailsPage extends StatefulWidget {
  final VoidCallback onContinue;

  const ProfessionalDetailsPage({super.key, required this.onContinue});

  @override
  State<ProfessionalDetailsPage> createState() =>
      _ProfessionalDetailsPageState();
}

class _ProfessionalDetailsPageState extends State<ProfessionalDetailsPage> {
  String? selectedCategory;
  String? selectedExperience;

  final List<String> categories = [
    "Plumbing Services",
    "Electrical Work",
    "AC Repair",
    "Carpentry",
    "Painting",
    "Cleaning",
    "Moving Services",
    "Appliance Repair",
  ];

  final List<String> experienceOptions = [
    "Less than a year",
    "One year",
    "More than Two years",
    "Five years or more",
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),

          const Text(
            "Ready to go pro, Hazim?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF062B4D),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Professional Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF062B4D),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Service category",
            style: TextStyle(fontSize: 18, color: Color(0xFF062B4D)),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: selectedCategory,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade300,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            icon: const Icon(Icons.work_outline, color: Color(0xFF062B4D)),
            items: categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
            hint: const Text(
              'Select a category',
              style: TextStyle(fontSize: 15, color: Color(0xFF062B4D)),
            ),
          ),

          const SizedBox(height: 25),
          const Divider(),
          const SizedBox(height: 10),

          const Text(
            "Experience years",
            style: TextStyle(fontSize: 18, color: Color(0xFF062B4D)),
          ),

          const SizedBox(height: 10),

          ...experienceOptions
              .map(
                (exp) => RadioListTile<String>(
                  title: Text(exp),
                  value: exp,
                  groupValue: selectedExperience,
                  onChanged: (value) {
                    setState(() {
                      selectedExperience = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              )
              .toList(),

          const Divider(),
          const SizedBox(height: 15),

          const Text(
            "Work description",
            style: TextStyle(fontSize: 18, color: Color(0xFF062B4D)),
          ),

          const SizedBox(height: 8),

          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade300,
              suffixIcon: const Icon(
                Icons.description_outlined,
                color: Color(0xFF062B4D),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: "Describe your professional experience...",
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: widget.onContinue,
              child: const Text(
                "Continue",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import '../pages/professional_details2.dart';

class ProfessionalDetailsPage extends StatefulWidget {
  const ProfessionalDetailsPage({super.key});

  @override
  State<ProfessionalDetailsPage> createState() =>
      _ProfessionalDetailsPageState();
}

class _ProfessionalDetailsPageState extends State<ProfessionalDetailsPage> {
  String? selectedCategory;
  String? selectedExperience;

  final List<String> categories = [
    "Plumbing Services",
    "Electrical Work",
    "AC Repair",
    "Carpentry",
    "Painting",
    "Cleaning",
    "Moving Services",
    "Appliance Repair",
  ];

  final List<String> experienceOptions = [
    "Less than a year",
    "One year",
    "More than Two years",
    "Five years or more",
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          const Text(
            "Ready to go pro, Hazim?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF062B4D),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Professional Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF062B4D),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            "Service category",
            style: TextStyle(fontSize: 18, color: Color(0xFF062B4D)),
          ),
          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: selectedCategory,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade300,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            icon: const Icon(Icons.work_outline, color: Color(0xFF062B4D)),
            items: categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
            hint: const Text(
              'Select a category',
              style: TextStyle(fontSize: 15, color: Color(0xFF062B4D)),
            ),
          ),

          const SizedBox(height: 25),
          const Divider(),

          const SizedBox(height: 10),

          const Text(
            "Experience years",
            style: TextStyle(fontSize: 18, color: Color(0xFF062B4D)),
          ),
          const SizedBox(height: 10),

          ...experienceOptions
              .map(
                (exp) => RadioListTile<String>(
                  title: Text(exp),
                  value: exp,
                  groupValue: selectedExperience,
                  onChanged: (value) {
                    setState(() {
                      selectedExperience = value;
                    });
                  },
                  dense: false,
                  contentPadding: EdgeInsets.zero,
                ),
              )
              .toList(),

          const Divider(),
          const SizedBox(height: 15),

          const Text(
            "Work description",
            style: TextStyle(fontSize: 18, color: Color(0xFF062B4D)),
          ),
          const SizedBox(height: 8),

          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade300,
              suffixIcon: const Icon(
                Icons.description_outlined,
                color: Color(0xFF062B4D),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: "Describe your professional experience...",
              hintStyle: TextStyle(fontSize: 15, color: Color(0xFF062B4D)),
            ),
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PageTwo()),
                );
              },
              child: const Text(
                "Continue",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
*/
