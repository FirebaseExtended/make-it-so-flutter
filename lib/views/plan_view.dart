import 'package:flutter/material.dart';

import '../data/plan_repository.dart';

class PlanView extends StatelessWidget {
  const PlanView({
    required this.plan,
    required this.onItemStatusChanged,
    this.onRemovePlan,
    super.key,
  });

  final Plan plan;

  // ignore: avoid_positional_boolean_parameters
  final void Function(int itemIndex, bool isDone) onItemStatusChanged;
  final void Function()? onRemovePlan;

  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Colors.black, width: 1),
      borderRadius: BorderRadius.circular(16),
    ),
    color: Colors.white,
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onRemovePlan != null)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onRemovePlan,
                  ),
                ),
            ],
          ),
          const Divider(),
          SizedBox(
            height: (plan.items.length + 2) * 36,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: plan.items.length,
              itemBuilder: (context, index) {
                final item = plan.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Radio<bool>(
                        toggleable: true,
                        value: true,
                        groupValue: item.isDone,
                        onChanged:
                            (done) => onItemStatusChanged(index, done ?? false),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onItemStatusChanged(index, !item.isDone),
                          child: Text(
                            plan.items[index].title,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
