import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'player_notifier.dart';
import '../services/persistence_service.dart';

final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>(
  (ref) => PlayerNotifier(PersistenceService.instance),
);
