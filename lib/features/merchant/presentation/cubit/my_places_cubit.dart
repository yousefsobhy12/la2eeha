import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/merchant_repository.dart';
import 'my_places_state.dart';

class MyPlacesCubit extends Cubit<MyPlacesState> {
  final MerchantRepository _repository;

  MyPlacesCubit(MerchantRepository repository)
    : _repository = repository,
      super(const MyPlacesInitial());

  Future<void> load({bool silent = false}) async {
    final keepVisible = silent && state is MyPlacesLoaded;
    if (!keepVisible) emit(const MyPlacesLoading());
    final result = await _repository.getMyPlaces();
    if (isClosed) return;
    result.fold(
      (failure) {
        if (!keepVisible) emit(MyPlacesError(failure));
      },
      (places) => emit(MyPlacesLoaded(places)),
    );
  }
}
