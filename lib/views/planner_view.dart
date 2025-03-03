// ignore_for_file: avoid_dynamic_calls, do_not_use_environment

import 'dart:convert';

// import 'package:firebase_vertexai/firebase_vertexai.dart'; // Vertex
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Gemini

import '../buttons/hollow_button.dart';
import '../buttons/solid_button.dart';
import '../data/image_choice.dart';
import '../data/plan_repository.dart';
import 'image_choice_view.dart';
import 'plan_view.dart';

class PlannerView extends StatefulWidget {
  const PlannerView({super.key});

  @override
  State<PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends State<PlannerView> {
  static const _systemInstruction = '''
Keep task names short; names ideally within 7 words.

Use the following schema in your response:
{
  "title":"string",
  "subtasks":"string[]"
}

The substasks should follow logical order''';

  // Vertex
  // final _provider = VertexProvider(
  //   model: FirebaseVertexAI.instance.generativeModel(
  //     model: 'gemini-2.0-flash',
  //     generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  //     systemInstruction: Content.text(_systemInstruction),
  //   ),
  // );

  // Gemini
  final _provider = GeminiProvider(
    model: GenerativeModel(
      apiKey: 'TODO: Gemini API Key',
      model: 'gemini-2.0-flash',
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      systemInstruction: Content.text(_systemInstruction),
    ),
  );

  var _selectedImageChoice = ImageChoice.location;
  final _controller = TextEditingController();
  Plan? _plan;
  var _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _selectImageChoice(ImageChoice.location);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        color: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image selection row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // First image (location)
                      Flexible(
                        fit: FlexFit.loose,
                        child: ImageChoiceView(
                          choice: ImageChoice.location,
                          groupChoice: _selectedImageChoice,
                          onChanged: _selectImageChoice,
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Second image (Room)
                      Flexible(
                        fit: FlexFit.loose,
                        child: ImageChoiceView(
                          choice: ImageChoice.room,
                          groupChoice: _selectedImageChoice,
                          onChanged: _selectImageChoice,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Prompt input section with Go button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: TextField(
                          controller: _controller,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: 'Add a prompt*',
                            labelStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SolidButton(
                        onPressed: _goPressed,
                        label: 'Go',
                        icon: Image.asset(
                          'assets/Spark_Gradient.png',
                          fit: BoxFit.cover,
                          height: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Helper text
                  const Text(
                    '*Update the prompt to generate a new list, like:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Text(
                    'Help me plan a trip to this location',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Generating a plan
                  if (_isGenerating)
                    const Center(child: CircularProgressIndicator()),

                  // Plan view
                  if (_plan != null)
                    Stack(
                      children: [
                        PlanView(plan: _plan!, onItemStatusChanged: (_, __) {}),
                        const Positioned(
                          right: 16,
                          bottom: 16,
                          child: Text(
                            'Generated by the Gemini API',
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                        ),
                      ],
                    ),

                  // Save and Reset buttons row
                  if (_plan != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Save button
                          SolidButton(onPressed: _savePressed, label: 'Save'),
                          const SizedBox(width: 16),
                          // Reset button
                          HollowButton(
                            onPressed: _resetPressed,
                            label: 'Reset',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  void _selectImageChoice(ImageChoice value) => setState(() {
    _selectedImageChoice = value;
    _controller.text = _promptFor(value);
  });

  String _promptFor(ImageChoice value) => switch (value) {
    ImageChoice.location =>
      'You are a travel expert planning a trip here for 5 people including '
          'one toddler and my mom who is turning 50',
    ImageChoice.room =>
      'You are an organization expert transforming this '
          'place to be enjoyed by a child and a toddler who love superheroes',
  };

  Future<void> _goPressed() async {
    setState(() {
      _isGenerating = true;
      _plan = null;
    });

    final text = _controller.text;
    final prompt =
        'Generate a title and list of tasks for $text '
        'using the ${_selectedImageChoice.name}.png image provided.';

    final image = await rootBundle.load(_selectedImageChoice.assetPath);
    final imageAttachment = ImageFileAttachment(
      name: '${_selectedImageChoice.name}.png',
      mimeType: 'image/png',
      bytes: image.buffer.asUint8List(),
    );

    final result =
        await _provider
            .generateStream(prompt, attachments: [imageAttachment])
            .join();

    setState(() {
      final json = jsonDecode(result);
      _plan = Plan.fromJson(json);
      _isGenerating = false;
    });
  }

  void _savePressed() {
    PlanRepository.instance.addPlan(_plan!);
    setState(() => _plan = null);
  }

  void _resetPressed() => setState(() => _plan = null);
}
