import '../../../../core/errors/failures.dart';
import '../../domain/entities/merchant_branch.dart';

class _Unset {
  const _Unset();
}

const Object _unset = _Unset();

abstract class ManageBranchesState {
  const ManageBranchesState();
}

class ManageBranchesInitial extends ManageBranchesState {
  const ManageBranchesInitial();
}

class ManageBranchesLoading extends ManageBranchesState {
  const ManageBranchesLoading();
}

class ManageBranchesLoaded extends ManageBranchesState {
  final List<MerchantBranch> branches;
  final String? actionError;
  final bool isSaving;

  const ManageBranchesLoaded(
    this.branches, {
    this.actionError,
    this.isSaving = false,
  });

  ManageBranchesLoaded copyWith({
    List<MerchantBranch>? branches,
    Object? actionError = _unset,
    bool? isSaving,
  }) {
    return ManageBranchesLoaded(
      branches ?? this.branches,
      actionError: actionError == _unset
          ? this.actionError
          : actionError as String?,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class ManageBranchesError extends ManageBranchesState {
  final Failure failure;
  const ManageBranchesError(this.failure);

  String get message => failure.message;
}
