import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'split_or_tabs.dart';
import 'views/planner_view.dart';
import 'views/plans_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(home: HomePage()));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        // Header with Gemini icon and title
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Spark_Gradient.png',
                fit: BoxFit.cover,
                height: 32,
              ),
              const SizedBox(width: 8),
              const Text(
                'Planning with the Gemini API',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        body: SplitOrTabs(
          tabs: const [
            Tab(text: 'Planner'),
            Tab(text: 'Plans'),
          ],
          children: [
            const PlannerView(),
            PlansView(),
          ],
        ),
      );
}
