// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gameRepository)
final gameRepositoryProvider = GameRepositoryProvider._();

final class GameRepositoryProvider
    extends $FunctionalProvider<GameRepository, GameRepository, GameRepository>
    with $Provider<GameRepository> {
  GameRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameRepositoryHash();

  @$internal
  @override
  $ProviderElement<GameRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GameRepository create(Ref ref) {
    return gameRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameRepository>(value),
    );
  }
}

String _$gameRepositoryHash() => r'0e3d70d25066b785ec9d6acb80d527446febd1af';

@ProviderFor(puzzleGenerator)
final puzzleGeneratorProvider = PuzzleGeneratorProvider._();

final class PuzzleGeneratorProvider
    extends
        $FunctionalProvider<PuzzleGenerator, PuzzleGenerator, PuzzleGenerator>
    with $Provider<PuzzleGenerator> {
  PuzzleGeneratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'puzzleGeneratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$puzzleGeneratorHash();

  @$internal
  @override
  $ProviderElement<PuzzleGenerator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PuzzleGenerator create(Ref ref) {
    return puzzleGenerator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PuzzleGenerator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PuzzleGenerator>(value),
    );
  }
}

String _$puzzleGeneratorHash() => r'4be052585e44b4ebecef333219bfa89f9d4ea267';
