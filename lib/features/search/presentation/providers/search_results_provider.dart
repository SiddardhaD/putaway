import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/purchase_line_detail_entity.dart';

// Provider to hold search results for access across screens
final searchResultsProvider = StateProvider<List<PurchaseLineDetailEntity>?>((ref) => null);
