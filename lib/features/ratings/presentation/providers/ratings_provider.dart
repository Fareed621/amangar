import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/models/rating_model.dart';
import '../../data/ratings_repository_impl.dart';
import '../../domain/ratings_repository.dart';

part 'ratings_provider.g.dart';

@riverpod
RatingsRepository ratingsRepository(RatingsRepositoryRef ref) {
  return RatingsRepositoryImpl();
}
