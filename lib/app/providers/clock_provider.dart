import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time. Overridden in tests so date-based logic is stable.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
