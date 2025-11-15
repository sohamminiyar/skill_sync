import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:skillsync/pages/broadcast_screen.dart';
import 'package:skillsync/resources/firestore_methods.dart';
import 'package:skillsync/responsive/responsive.dart';
import 'package:skillsync/utils/colors.dart';
import 'package:skillsync/utils/utils.dart';
import 'package:skillsync/widgets/custom_button.dart';
import 'package:skillsync/widgets/custom_textfiled.dart';

class GoLiveScreen extends StatefulWidget {
  static const String routeName = '/golive'; // Route name for navigation

  const GoLiveScreen({super.key});

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final TextEditingController _titleController = TextEditingController();
  Uint8List? image;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  goLiveStream() async {
    String channelId = await FirestoreMethods()
        .startLiveStream(context, _titleController.text, image);

    if (channelId.isNotEmpty) {
      showSnackBar(context, 'Livestream Started Successfully');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BroadcastScreen(
            isBroadcaster: true,
            channelId: channelId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Responsive(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      Uint8List? pickedImage = await pickImage();
                      if (pickedImage != null) {
                        setState(() {
                          image = pickedImage;
                        });
                      } else {
                        showSnackBar(context, 'No image selected');
                      }
                    } catch (e) {
                      showSnackBar(context, 'Error picking image: $e');
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : image != null
                            ? SizedBox(
                                height: 300,
                                child: Image.memory(
                                  image!,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Text('Error loading image'),
                                ),
                              )
                            : DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(10),
                                dashPattern: const [10, 4],
                                strokeCap: StrokeCap.round,
                                color: buttonColor,
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: buttonColor.withOpacity(.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.folder_open,
                                        color: buttonColor,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        'Select your thumbnail',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CustomTextfiled(controller: _titleController, onTap: (val) {  },),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: CustomButton(text: 'Go Live!', onTap: goLiveStream),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
