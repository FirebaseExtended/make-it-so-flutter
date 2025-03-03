import 'package:flutter/foundation.dart';

class PlanItem extends ChangeNotifier {
  PlanItem({required this.title, bool isDone = false}) : _isDone = isDone;
  final String title;
  bool _isDone;
  bool get isDone => _isDone;
  set isDone(bool value) {
    _isDone = value;
    notifyListeners();
  }
}

class Plan {
  Plan._({required this.title, required this.items});

  factory Plan.fromJson(Map<String, dynamic> json) => Plan._(
    title: json['title'] as String,
    items:
        (json['subtasks'] as List<dynamic>)
            .map((item) => PlanItem(title: item as String))
            .toList(),
  );

  final String title;
  final List<PlanItem> items;
}

class PlanRepository extends ChangeNotifier {
  PlanRepository._();
  final List<Plan> _plans = [];

  static final PlanRepository instance = PlanRepository._();
  List<Plan> get plans => List.unmodifiable(_plans);

  int addPlan(Plan plan) {
    _plans.add(plan);
    notifyListeners();
    return _plans.length - 1;
  }

  void removePlan(int planIndex) {
    assert(planIndex >= 0 && planIndex < _plans.length);
    _plans.removeAt(planIndex);
    notifyListeners();
  }

  void setPlanItemStatus({
    required int planIndex,
    required int itemIndex,
    required bool isDone,
  }) {
    assert(planIndex >= 0 && planIndex < _plans.length);
    assert(itemIndex >= 0 && itemIndex < _plans[planIndex].items.length);
    _plans[planIndex].items[itemIndex].isDone = isDone;
    notifyListeners();
  }
}
