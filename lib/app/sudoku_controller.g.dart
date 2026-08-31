// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sudoku_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SudokuController)
final sudokuControllerProvider = SudokuControllerProvider._();

final class SudokuControllerProvider
    extends $NotifierProvider<SudokuController, SudokuState> {
  SudokuControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sudokuControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sudokuControllerHash();

  @$internal
  @override
  SudokuController create() => SudokuController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SudokuState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SudokuState>(value),
    );
  }
}

String _$sudokuControllerHash() => r'2e5e9a8bd457db0f735169579b4709b688fc8729';

abstract class _$SudokuController extends $Notifier<SudokuState> {
  SudokuState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SudokuState, SudokuState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SudokuState, SudokuState>,
              SudokuState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
