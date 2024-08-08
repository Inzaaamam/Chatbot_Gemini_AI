import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'model.dart';

class GeminiChatBot extends StatefulWidget {
  const GeminiChatBot({super.key});
  @override
  State<GeminiChatBot> createState() => _GeminiChatBotState();
}

class _GeminiChatBotState extends State<GeminiChatBot> {
  TextEditingController promprController = TextEditingController();
  static const apiKey = "AIzaSyDRoVCdj_65CDXCaeVXBIz7aM-Lara2NM8";
  final model = GenerativeModel(model: "gemini-pro", apiKey: apiKey);
  bool isLoading = false;

  final List<ModelMessage> prompt = [];
  final _formKey = GlobalKey<FormState>(); // GlobalKey to manage the Form state

  Future<void> sendMessage() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate the form
      setState(() {
        isLoading = true; // Start loading indicator
      });

      final message = promprController.text;
      // Add the prompt message
      setState(() {
        promprController.clear(); // Clear the text field
        prompt.add(
          ModelMessage(
            isPrompt: true,
            message: message,
            time: DateTime.now(),
          ),
        );
      });

      // Generate response from the model
      final content = [Content.text(message)];
      final response = await model.generateContent(content);

      setState(() {
        isLoading = false; // Stop loading indicator
        prompt.add(
          ModelMessage(
            isPrompt: false,
            message: response.text ?? "",
            time: DateTime.now(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Center(
          child: Text(
            "AI ChatBot",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: prompt.length,
              itemBuilder: (context, index) {
                final message = prompt[index];
                return UserPrompt(
                  isPrompt: message.isPrompt,
                  message: message.message,
                  date: DateFormat('hh:mm a').format(
                    message.time,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 15),
            child: Row(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey, // Assign the GlobalKey to the Form
                    child: TextFormField(
                      controller: promprController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                      decoration: InputDecoration(
                        helperMaxLines: 5,
                        focusColor: Colors.transparent,
                        enabled: true,
                        hoverColor: Colors.transparent,
                        suffixIcon: GestureDetector(
                          onTap: sendMessage, // Trigger sendMessage on tap
                          child: const Icon(
                            Icons.send,
                            color: Colors.green,
                            size: 32,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.blue),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.blue),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        hintText: "Enter a prompt here",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Container UserPrompt({
    required final bool isPrompt,
    required String message,
    required String date,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isPrompt ? 80 : 15,
        right: isPrompt ? 15 : 80,
      ),
      decoration: BoxDecoration(
        color: isPrompt ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
          bottomLeft: isPrompt ? const Radius.circular(10) : Radius.zero,
          bottomRight: isPrompt ? Radius.zero : const Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontWeight: isPrompt ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
              color: isPrompt ? Colors.white : Colors.black,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              color: isPrompt ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
