import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../pages/in_queue.dart';

class PageThree extends StatefulWidget {
  const PageThree({super.key});

  @override
  State<PageThree> createState() => _PageThreeState();
}

class _PageThreeState extends State<PageThree> {
  final ImagePicker picker = ImagePicker();

  File? profileImage;
  File? idImage;
  File? certificationImage;
  File? conductImage;

  File? getImageByType(String type) {
    switch (type) {
      case "Upload Profile picture":
        return profileImage;
      case "Upload ID":
        return idImage;
      case "Upload certification":
        return certificationImage;
      case "Certificate of good conduct":
        return conductImage;
      default:
        return null;
    }
  }

  void setImageByType(String type, File image) {
    setState(() {
      switch (type) {
        case "Upload Profile picture":
          profileImage = image;
          break;
        case "Upload ID":
          idImage = image;
          break;
        case "Upload certification":
          certificationImage = image;
          break;
        case "Certificate of good conduct":
          conductImage = image;
          break;
      }
    });
  }

  void showUploadSheet(String title) {
    File? tempImage = getImageByType(title);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return Container(
                    height: 350,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF062B4D),
                          ),
                        ),
                        const SizedBox(height: 30),

                        GestureDetector(
                          onTap: () async {
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );

                            if (image != null) {
                              setModalState(() {
                                tempImage = File(image.path);
                              });
                            }
                          },
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF062B4D),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: tempImage == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.upload_file,
                                        size: 40,
                                        color: Color(0xFF062B4D),
                                      ),
                                      SizedBox(height: 10),
                                      Text("Tap to choose a photo"),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(
                                      tempImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                          ),
                        ),

                        const Spacer(),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: () {
                            if (tempImage != null) {
                              setImageByType(title, tempImage!);
                            }
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Save Photo",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget uploadRow(String text) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 18, color: Color(0xFF062B4D)),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => showUploadSheet(text),
              child: const Icon(
                Icons.chevron_right,
                color: Color(0xFF062B4D),
                size: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),

          uploadRow("Upload Profile picture"),

          uploadRow("Upload ID"),

          uploadRow("Upload certification"),

          uploadRow("Certificate of good conduct"),
          SizedBox(height: 250),

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
                  MaterialPageRoute(builder: (context) => const InQueue()),
                );
              },
              child: const Text(
                "Done",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
