import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/branch_draft.dart';
import '../../domain/repositories/merchant_repository.dart';
import 'manage_branches_state.dart';

class ManageBranchesCubit extends Cubit<ManageBranchesState> {
  static const int maxBranches = 10;

  final MerchantRepository _repository;
  final int placeId;

  ManageBranchesCubit(MerchantRepository repository, {required this.placeId})
    : _repository = repository,
      super(const ManageBranchesInitial());

  Future<void> load({bool silent = false}) async {
    final keepVisible = silent && state is ManageBranchesLoaded;
    if (!keepVisible) emit(const ManageBranchesLoading());
    final result = await _repository.getMyBranches(placeId: placeId);
    if (isClosed) return;
    result.fold(
      (failure) {
        if (!keepVisible) {
          emit(ManageBranchesError(failure));
          return;
        }
        final current = state;
        if (current is ManageBranchesLoaded) {
          emit(current.copyWith(isSaving: false));
        }
      },
      (branches) => emit(ManageBranchesLoaded(branches)),
    );
  }

  Future<bool> add(BranchDraft draft) {
    return _save(() => _repository.addBranch(placeId: placeId, draft: draft));
  }

  Future<bool> update(int branchId, BranchDraft draft) {
    return _save(
      () => _repository.updateBranch(branchId: branchId, draft: draft),
    );
  }

  Future<bool> remove(int branchId) {
    return _save(() => _repository.deleteBranch(branchId: branchId));
  }

  void clearActionError() {
    final current = state;
    if (current is ManageBranchesLoaded && current.actionError != null) {
      emit(current.copyWith(actionError: null));
    }
  }

  Future<bool> _save(Future<Either<Failure, void>> Function() call) async {
    final current = state;
    if (current is ManageBranchesLoaded) {
      emit(current.copyWith(isSaving: true));
    }
    final result = await call();
    if (isClosed) return false;
    final error = result.fold((failure) => failure.message, (_) => null);
    if (error != null) {
      final latest = state;
      if (latest is ManageBranchesLoaded) {
        emit(latest.copyWith(actionError: error, isSaving: false));
      }
      return false;
    }
    await load(silent: true);
    return true;
  }
}
