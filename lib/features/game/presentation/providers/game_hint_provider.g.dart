// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_hint_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gameHint)
final gameHintProvider = GameHintProvider._();

final class GameHintProvider
    extends $FunctionalProvider<GameHint?, GameHint?, GameHint?>
    with $Provider<GameHint?> {
  GameHintProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameHintProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameHintHash();

  @$internal
  @override
  $ProviderElement<GameHint?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GameHint? create(Ref ref) {
    return gameHint(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameHint? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameHint?>(value),
    );
  }
}

String _$gameHintHash() => r'd5f3d9526cf05ab9b7f5973ba353dca207fa6008';
