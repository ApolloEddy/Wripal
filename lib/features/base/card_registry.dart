/// 可拔插卡片系统 - 卡片注册中心
/// 
/// 管理所有可用卡片的注册、启用/禁用和状态持久化

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'feature_card.dart';
import '../../core/constants/app_constants.dart';

/// 卡片注册中心
/// 
/// 单例模式，管理所有已注册的卡片
class CardRegistry {
  CardRegistry._();
  static final CardRegistry instance = CardRegistry._();

  /// 已注册的卡片列表
  final Map<String, FeatureCard> _cards = {};

  /// 注册一个卡片
  void register(FeatureCard card) {
    _cards[card.id] = card;
  }

  /// 批量注册卡片
  void registerAll(List<FeatureCard> cards) {
    for (final card in cards) {
      register(card);
    }
  }

  /// 取消注册卡片
  void unregister(String cardId) {
    _cards.remove(cardId);
  }

  /// 获取所有已注册的卡片
  List<FeatureCard> get allCards => _cards.values.toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  /// 根据 ID 获取卡片
  FeatureCard? getCard(String id) => _cards[id];

  /// 根据类型获取卡片
  List<FeatureCard> getCardsByType(CardType type) {
    return allCards.where((card) => card.type == type).toList();
  }
}

/// 卡片管理状态
class CardManagerState {
  /// 所有已注册的卡片
  final List<FeatureCard> allCards;

  /// 已启用的卡片 ID 集合
  final Set<String> enabledCardIds;

  /// 当前选中的卡片 ID
  final String? selectedCardId;

  const CardManagerState({
    required this.allCards,
    required this.enabledCardIds,
    this.selectedCardId,
  });

  /// 获取已启用的卡片列表
  List<FeatureCard> get enabledCards => allCards
      .where((card) => enabledCardIds.contains(card.id))
      .toList();

  /// 获取当前选中的卡片
  FeatureCard? get selectedCard {
    if (selectedCardId == null) return null;
    return allCards.firstWhere(
      (card) => card.id == selectedCardId,
      orElse: () => allCards.first,
    );
  }

  /// 检查卡片是否启用
  bool isEnabled(String cardId) => enabledCardIds.contains(cardId);

  CardManagerState copyWith({
    List<FeatureCard>? allCards,
    Set<String>? enabledCardIds,
    String? selectedCardId,
  }) {
    return CardManagerState(
      allCards: allCards ?? this.allCards,
      enabledCardIds: enabledCardIds ?? this.enabledCardIds,
      selectedCardId: selectedCardId ?? this.selectedCardId,
    );
  }
}

/// 卡片管理 Notifier
class CardManagerNotifier extends StateNotifier<CardManagerState> {
  CardManagerNotifier() : super(const CardManagerState(
    allCards: [],
    enabledCardIds: {},
  ));

  SharedPreferences? _prefs;

  /// 初始化，加载已注册的卡片和持久化状态
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // 获取所有已注册的卡片
    final allCards = CardRegistry.instance.allCards;

    // 加载已启用的卡片
    final enabledIds = _prefs?.getStringList(StorageKeys.enabledCards);
    Set<String> enabledCardIds;
    
    if (enabledIds != null) {
      enabledCardIds = enabledIds.toSet();
    } else {
      // 默认启用标记为 enabledByDefault 的卡片
      enabledCardIds = allCards
          .where((card) => card.enabledByDefault)
          .map((card) => card.id)
          .toSet();
    }

    // 加载选中的卡片
    final selectedId = _prefs?.getString(StorageKeys.selectedCard);

    state = CardManagerState(
      allCards: allCards,
      enabledCardIds: enabledCardIds,
      selectedCardId: selectedId ?? (enabledCardIds.isNotEmpty 
          ? enabledCardIds.first 
          : null),
    );

    // 初始化所有已启用的卡片
    for (final card in state.enabledCards) {
      await card.initialize();
    }
  }

  /// 选择卡片
  void selectCard(String cardId) {
    if (!state.isEnabled(cardId)) return;
    
    state = state.copyWith(selectedCardId: cardId);
    _prefs?.setString(StorageKeys.selectedCard, cardId);
  }

  /// 启用卡片
  Future<void> enableCard(String cardId) async {
    final card = CardRegistry.instance.getCard(cardId);
    if (card == null) return;

    await card.initialize();
    
    final newEnabledIds = {...state.enabledCardIds, cardId};
    state = state.copyWith(enabledCardIds: newEnabledIds);
    
    _prefs?.setStringList(StorageKeys.enabledCards, newEnabledIds.toList());
  }

  /// 禁用卡片
  Future<void> disableCard(String cardId) async {
    final card = CardRegistry.instance.getCard(cardId);
    if (card != null) {
      await card.dispose();
    }

    final newEnabledIds = {...state.enabledCardIds}..remove(cardId);
    
    // 如果禁用的是当前选中的卡片，切换到第一个启用的卡片
    String? newSelectedId = state.selectedCardId;
    if (state.selectedCardId == cardId) {
      newSelectedId = newEnabledIds.isNotEmpty ? newEnabledIds.first : null;
    }

    state = state.copyWith(
      enabledCardIds: newEnabledIds,
      selectedCardId: newSelectedId,
    );
    
    _prefs?.setStringList(StorageKeys.enabledCards, newEnabledIds.toList());
  }

  /// 切换卡片启用状态
  Future<void> toggleCard(String cardId) async {
    if (state.isEnabled(cardId)) {
      await disableCard(cardId);
    } else {
      await enableCard(cardId);
    }
  }

  /// 刷新卡片列表
  void refresh() {
    state = state.copyWith(allCards: CardRegistry.instance.allCards);
  }
}

/// 卡片管理 Provider
final cardManagerProvider = StateNotifierProvider<CardManagerNotifier, CardManagerState>((ref) {
  return CardManagerNotifier();
});
