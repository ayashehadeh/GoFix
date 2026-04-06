import 'package:flutter/material.dart';

class PageTwo extends StatefulWidget {
  final VoidCallback onContinue;

  const PageTwo({super.key, required this.onContinue});

  @override
  State<PageTwo> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<PageTwo> {
  List<String> services = [
    "Pipe Installation",
    "Pipe Repair",
    "Leak Repairs",
    "Bathroom Fixtures",
    "Water Heater Service",
    "Drain Unclogging",
    "Faucet Repair",
  ];

  String? selectedService;
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Services & Pricing",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF062B4D),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Tap a service to add it, then set your price.",
                style: TextStyle(color: Color(0xFF062B4D), fontSize: 13),
              ),

              const SizedBox(height: 20),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3.5,
                ),
                itemBuilder: (context, index) {
                  final service = services[index];
                  bool isSelected = selectedService == service;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedService = service;
                        priceController.clear();
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xff1F3A5F)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(service),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              if (selectedService != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(selectedService!)),

                      SizedBox(
                        width: 70,
                        height: 40,
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            //hintText: "JD",
                            filled: true,
                            fillColor: const Color(0xffF4F6F8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      const Text(
                        "JD",
                        style: TextStyle(
                          color: Color(0xFF062B4D),
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(width: 10),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedService = null;
                            priceController.clear();
                          });
                        },
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

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
            ],
          ),
        ),
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import '../pages/professional_details3.dart';

class PageTwo extends StatefulWidget {
  const PageTwo({super.key});

  @override
  State<PageTwo> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<PageTwo> {
  List<String> services = [
    "Pipe Installation",
    "Pipe Repair",
    "Leak Repairs",
    "Bathroom Fixtures",
    "Water Heater Service",
    "Drain Unclogging",
    "Faucet Repair",
  ];

  String? selectedService;
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Services & Pricing",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              const Text(
                "Tap a service to add it, then set your price.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 20),

              /// SERVICES GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3.5,
                ),
                itemBuilder: (context, index) {
                  final service = services[index];
                  bool isSelected = selectedService == service;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedService = service;
                        priceController.clear();
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xff1F3A5F)
                              : Colors.grey.shade300,
                          width: 1.3,
                        ),
                      ),
                      child: Text(
                        service,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              const Text(
                "Your Service",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 12),

              /// SELECTED SERVICE + PRICE INPUT
              if (selectedService != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedService!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),

                      /// PRICE FIELD
                      SizedBox(
                        width: 90,
                        height: 40,
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "JD",
                            filled: true,
                            fillColor: const Color(0xffF4F6F8),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedService = null;
                            priceController.clear();
                          });
                        },
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              /// CONTINUE BUTTON
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
                    if (selectedService != null &&
                        priceController.text.isNotEmpty) {
                      print(
                        "Service: $selectedService, Price: ${priceController.text} JD",
                      );
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PageThree(),
                      ),
                    );
                  },
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
            ],
          ),
        ),
      ),
    );
  }
}
*/