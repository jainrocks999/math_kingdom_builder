import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/home_action_model.dart';
import '../models/quest_model.dart';

class HomeContentBundle {
  const HomeContentBundle({
    required this.featuredActions,
    required this.quests,
  });

  final List<HomeActionModel> featuredActions;
  final List<QuestModel> quests;
}

class HomeContentRepository {
  const HomeContentRepository();

  Future<HomeContentBundle> loadHomeContent() async {
    final featuredActions = await _loadList(
      'assets/data/home/featured_actions.json',
      HomeActionModel.fromJson,
    );
    final quests = await _loadList(
      'assets/data/home/quests.json',
      QuestModel.fromJson,
    );

    return HomeContentBundle(
      featuredActions: featuredActions,
      quests: quests,
    );
  }

  Future<List<T>> _loadList<T>(
    String assetPath,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Expected a JSON array.');
    }

    return decoded
        .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }
}
