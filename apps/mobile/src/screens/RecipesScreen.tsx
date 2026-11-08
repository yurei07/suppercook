import React, { useCallback, useEffect, useState } from 'react';
import {
  ActivityIndicator,
  FlatList,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { Recipe, api } from '../api/client';
import { colors, radius, spacing, typography } from '../theme';

interface Props {
  /** Открыть рецепт в режиме готовки */
  onOpenRecipe: (recipe: Recipe) => void;
}

const DIFFICULTY_LABEL: Record<Recipe['difficulty'], string> = {
  easy: 'Просто',
  medium: 'Средне',
  hard: 'Сложно',
};

/**
 * Экран предложений: «что приготовить из того, что есть».
 * Момент ценности MVP — главный экран продукта.
 */
export function RecipesScreen({ onOpenRecipe }: Props) {
  const [recipes, setRecipes] = useState<Recipe[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setRecipes(await api.suggestRecipes({}));
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Не удалось получить рецепты');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator color={colors.primary} size="large" />
        <Text style={styles.loadingText}>Анализирую ваш холодильник…</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.center}>
        <Text style={styles.errorEmoji}>😵</Text>
        <Text style={[typography.body, styles.centerText]}>{error}</Text>
        <TouchableOpacity style={styles.retryBtn} onPress={() => void load()}>
          <Text style={styles.retryText}>Повторить</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <FlatList
      style={styles.container}
      data={recipes}
      keyExtractor={(r) => r.id}
      contentContainerStyle={styles.content}
      ListHeaderComponent={
        <Text style={[typography.title, styles.title]}>Что приготовить?</Text>
      }
      ListEmptyComponent={
        <View style={styles.center}>
          <Text style={styles.errorEmoji}>🧑‍🍳</Text>
          <Text style={[typography.body, styles.centerText]}>
            Пока нечего предложить — добавьте продукты во вкладке «Холодильник».
          </Text>
        </View>
      }
      renderItem={({ item }) => (
        <TouchableOpacity style={styles.card} onPress={() => onOpenRecipe(item)}>
          <View style={styles.cardHeader}>
            <Text style={typography.subtitle}>{item.title}</Text>
            <View style={styles.timeBadge}>
              <Text style={styles.timeText}>⏱ {item.timeMinutes} мин</Text>
            </View>
          </View>

          <Text style={[typography.caption, styles.description]}>{item.description}</Text>

          <View style={styles.metaRow}>
            <Text style={styles.meta}>👤 {item.servings} порц.</Text>
            <Text style={styles.meta}>📊 {DIFFICULTY_LABEL[item.difficulty]}</Text>
            <Text style={styles.meta}>🔥 {item.nutrition.kcal} ккал</Text>
          </View>

          {item.missingIngredients.length > 0 ? (
            <View style={styles.warning}>
              <Text style={styles.warningText}>
                Не хватает: {item.missingIngredients.join(', ')}
              </Text>
            </View>
          ) : (
            <View style={styles.ready}>
              <Text style={styles.readyText}>✓ Всё есть — можно готовить!</Text>
            </View>
          )}
        </TouchableOpacity>
      )}
    />
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  content: { padding: spacing.md, paddingBottom: 40 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: spacing.xl },
  centerText: { color: colors.textSecondary, textAlign: 'center' },
  loadingText: { marginTop: spacing.md, color: colors.textSecondary, fontSize: 16 },
  errorEmoji: { fontSize: 48, marginBottom: spacing.sm },
  retryBtn: {
    marginTop: spacing.md,
    backgroundColor: colors.primary,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: radius.pill,
  },
  retryText: { color: colors.white, fontWeight: '700' },
  title: { marginBottom: spacing.md },
  card: {
    backgroundColor: colors.background,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.lg,
    padding: spacing.md,
    marginBottom: spacing.md,
  },
  cardHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', gap: spacing.sm },
  timeBadge: {
    backgroundColor: colors.primaryLight,
    paddingHorizontal: spacing.sm,
    paddingVertical: 4,
    borderRadius: radius.pill,
  },
  timeText: { color: colors.primaryDark, fontSize: 12, fontWeight: '700' },
  description: { marginTop: spacing.sm, lineHeight: 18 },
  metaRow: { flexDirection: 'row', gap: spacing.md, marginTop: spacing.sm },
  meta: { fontSize: 13, color: colors.textSecondary },
  warning: {
    backgroundColor: colors.warningLight,
    borderRadius: radius.sm,
    padding: spacing.sm,
    marginTop: spacing.sm,
  },
  warningText: { color: '#8A6100', fontSize: 13 },
  ready: {
    backgroundColor: colors.successLight,
    borderRadius: radius.sm,
    padding: spacing.sm,
    marginTop: spacing.sm,
  },
  readyText: { color: colors.success, fontSize: 13, fontWeight: '600' },
});
