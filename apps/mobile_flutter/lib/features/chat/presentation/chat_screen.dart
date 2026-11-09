import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/extensions.dart';
import '../../../data/providers/recipe_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_cards.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final String? recipeId;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.recipeId,
  });
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _typing = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _messages.add(
        _ChatMessage(text: context.l10n.chatGreeting, isUser: false),
      );
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  Future<void> _send([String? preset]) async {
    final locale = Localizations.localeOf(context);
    final l10n = context.l10n;
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _typing = true;
      _controller.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final suggestions = ref.read(suggestionsProvider);
    final fallback = ref.read(recipesProvider);
    final recipe = suggestions.isNotEmpty
        ? suggestions.first
        : fallback.first;
    final ingredientNames = recipe.ingredients
        .take(3)
        .map((ingredient) => ingredient.name.resolve(locale))
        .join(', ');

    setState(() {
      _typing = false;
      _messages.add(
        _ChatMessage(
          text: l10n.chatMockReply(
            recipe.title.resolve(locale),
            recipe.minutes,
            ingredientNames,
          ),
          isUser: false,
          recipeId: recipe.id,
        ),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.pagePadding,
                      AppSpacing.md,
                      context.pagePadding,
                      AppSpacing.sm,
                    ),
                    child: AppPageHeader(
                      title: l10n.chatTitle,
                      subtitle: l10n.chatSubtitle,
                      onBack: () => context.pop(),
                      actions: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AI',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: context.pagePadding,
                        vertical: AppSpacing.md,
                      ),
                      itemCount:
                          _messages.length + (_typing ? 1 : 0) + 1,
                      itemBuilder: (context, index) {
                        if (index < _messages.length) {
                          return _Bubble(
                            message: _messages[index],
                            onOpenRecipe: (id) =>
                                context.push('/recipe/$id'),
                          );
                        }
                        final extraIndex = index - _messages.length;
                        if (extraIndex == 0 && _typing) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(top: AppSpacing.md),
                            child: _TypingBubble(label: l10n.chatTyping),
                          );
                        }
                        if (_messages.length == 1 && !_typing) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.lg),
                            child: Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                AppPillButton(
                                  label: l10n.chatSuggestion1,
                                  icon: Icons.local_dining_outlined,
                                  onPressed: () =>
                                      _send(l10n.chatSuggestion1),
                                ),
                                AppPillButton(
                                  label: l10n.chatSuggestion2,
                                  icon: Icons.fitness_center_rounded,
                                  onPressed: () =>
                                      _send(l10n.chatSuggestion2),
                                ),
                                AppPillButton(
                                  label: l10n.chatSuggestion3,
                                  icon: Icons.eco_outlined,
                                  onPressed: () =>
                                      _send(l10n.chatSuggestion3),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      context.pagePadding,
                      AppSpacing.sm,
                      context.pagePadding,
                      AppSpacing.md,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      border: Border(
                        top: BorderSide(color: AppColors.borderSoft),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              minLines: 1,
                              maxLines: 4,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _send(),
                              decoration: InputDecoration(
                                hintText: l10n.chatHint,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          AppIconButton(
                            icon: Icons.arrow_upward_rounded,
                            size: 50,
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.black,
                            onPressed: () => _send(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _ChatMessage message;
  final void Function(String recipeId) onOpenRecipe;

  const _Bubble({required this.message, required this.onOpenRecipe});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: AppSpacing.md),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: const BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              fontFamily: AppTypography.sans,
              fontSize: 14,
              height: 1.45,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              gradient: AppColors.accentGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'S',
              style: TextStyle(
                fontFamily: AppTypography.serif,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (message.recipeId != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: () => onOpenRecipe(message.recipeId!),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(context.l10n.viewRecipe),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final String label;

  const _TypingBubble({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            gradient: AppColors.accentGradient,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            'S',
            style: TextStyle(
              fontFamily: AppTypography.serif,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 1.8),
              ),
              const SizedBox(width: 9),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
