import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/home_content_repository.dart';

final homeContentRepositoryProvider = Provider<HomeContentRepository>(
  (ref) => const HomeContentRepository(),
);

final homeContentProvider = FutureProvider<HomeContentBundle>((ref) {
  final repository = ref.watch(homeContentRepositoryProvider);
  return repository.loadHomeContent();
});
