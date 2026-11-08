import React, { useState } from 'react';
import {
  Alert,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { Recipe, api } from '../api/client';
import { colors, radius, spacing, typography } from '../theme';

interface Props {
  recipe: Recipe;
  /** Открыть вкладку со списком покупок */
  onGoToShopping: () => void;
  onBack: () => void;
}

/**
 * Режим готовки: пошаговые инструкции + умное добавление в список покупок.
 */
export function RecipeDetailScreen({ recipe, onGoToShopping, onBack }: Props) {
  const [step, setStep] = useState(0);
  const [added, setAdded] = useState(false);
  const [adding, setAdding] = useState(false);

  const addToShopping = async () => {
    if (recipe.missingIngredients.length === 0) return;
    setAdding(true);
    try {
      await api.addFromRecipe(recipe.missingIngredients, recipe.id);
      setAdded(true);
      Alert.alert('Добавлено ✓', 'Недостающие ингредиенты в списке покупок', [
        { text: 'К списку', onPress: onGoToShopping },
        { text: 'Остаться', style: 'cancel' },
      ]);
    } catch (e) {
      Alert.alert('Ошибка', e instanceof Error ? e.message : 'Не удалось добавить');
    } finally {
      setAdding(false);
    }
  };

  const isLast = step === recipe.steps.length - 1;

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <TouchableOpacity onPress={onBack}>
        <Text style={styles.back}>← Назад</Text>
      </TouchableOpacity>

      <Text style={typography.title}>{recipe.title}</Text>
      <Text style={[typography.caption, styles.desc]}>{recipe.description}</Text>

      <View style={styles.metaRow}>
        <View style={styles.metaBox}>
          <Text style={styles.metaValue}>⏱ {recipe.timeMinutes}</Text>
          <Text style={styles.metaLabel}>минут</Text>
        </View>
        <View style={styles.metaBox}>
          <Text style={styles.metaValue}>👤 {recipe.servings}</Text>
          <Text style={styles.metaLabel}>порций</Text>
        </View>
        <View style={styles.metaBox}>
          <Text style={styles.metaValue}>🔥 {recipe.nutrition.kcal}</Text>
          <Text style={styles.metaLabel}>ккал/порц</Text>
        </View>
      </View>

      {/* КБЖУ */}
      <View style={styles.kbju}>
        <Text style={styles.kbjuItem}>Б: {recipe.nutrition.protein} г</Text>
        <Text style={styles.kbjuItem}>Ж: {recipe.nutrition.fat} г</Text>
        <Text style={styles.kbjuItem}>У: {recipe.nutrition.carbs} г</Text>
      </View>

      {/* Ингредиенты */}
      <Text style={styles.sectionTitle}>Ингредиенты</Text>
      {recipe.ingredients.map((ing, i) => (
        <View key={`${ing.name}-${i}`} style={styles.ingRow}>
          <Text style={[styles.ingName, ing.have === false && styles.ingMissing]}>
            {ing.have === false ? '○ ' : '✓ '}
            {ing.name}
          </Text>
          <Text style={styles.ingQty}>
            {ing.quantity} {ing.unit}
          </Text>
        </View>
      ))}

      {recipe.missingIngredients.length > 0 && (
        <TouchableOpacity
          style={[styles.shopBtn, (added || adding) && styles.shopBtnDone]}
          onPress={() => void addToShopping()}
          disabled={added || adding}
        >
          <Text style={styles.shopBtnText}>
            {added ? '✓ Добавлено в список покупок' : '🛒 Добавить недостающее в список'}
          </Text>
        </TouchableOpacity>
      )}

      {/* Готовка по шагам */}
      <Text style={styles.sectionTitle}>Готовка</Text>
      <View style={styles.stepCard}>
        <Text style={styles.stepCounter}>
          Шаг {step + 1} из {recipe.steps.length}
        </Text>
        <Text style={styles.stepText}>{recipe.steps[step]}</Text>

        <View style={styles.stepNav}>
          {step > 0 && (
            <TouchableOpacity style={styles.stepPrev} onPress={() => setStep(step - 1)}>
              <Text style={styles.stepPrevText}>← Назад</Text>
            </TouchableOpacity>
          )}
          <TouchableOpacity
            style={[styles.stepNext, isLast && styles.stepDone]}
            onPress={() => (isLast ? onBack() : setStep(step + 1))}
          >
            <Text style={styles.stepNextText}>{isLast ? '🎉 Готово!' : 'Далее →'}</Text>
          </TouchableOpacity>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  content: { padding: spacing.md, paddingBottom: 60 },
  back: { color: colors.primary, fontSize: 16, fontWeight: '600', marginBottom: spacing.md },
  desc: { marginTop: spacing.sm, lineHeight: 18 },
  metaRow: { flexDirection: 'row', gap: spacing.sm, marginTop: spacing.md },
  metaBox: {
    flex: 1,
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    padding: spacing.sm,
    alignItems: 'center',
  },
  metaValue: { fontSize: 16, fontWeight: '700', color: colors.text },
  metaLabel: { fontSize: 12, color: colors.textSecondary, marginTop: 2 },
  kbju: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    backgroundColor: colors.primaryLight,
    borderRadius: radius.md,
    padding: spacing.sm,
    marginTop: spacing.sm,
  },
  kbjuItem: { fontWeight: '600', color: colors.primaryDark, fontSize: 14 },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    marginTop: spacing.lg,
    marginBottom: spacing.sm,
  },
  ingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  ingName: { fontSize: 15, color: colors.text },
  ingMissing: { color: colors.textSecondary },
  ingQty: { fontSize: 15, color: colors.textSecondary },
  shopBtn: {
    backgroundColor: colors.primary,
    borderRadius: radius.md,
    paddingVertical: 14,
    alignItems: 'center',
    marginTop: spacing.md,
  },
  shopBtnDone: { backgroundColor: colors.success },
  shopBtnText: { color: colors.white, fontWeight: '700', fontSize: 15 },
  stepCard: {
    backgroundColor: colors.surface,
    borderRadius: radius.lg,
    padding: spacing.md,
  },
  stepCounter: {
    fontSize: 13,
    fontWeight: '700',
    color: colors.primary,
    textTransform: 'uppercase',
    marginBottom: spacing.sm,
  },
  stepText: { fontSize: 18, lineHeight: 26, color: colors.text },
  stepNav: { flexDirection: 'row', gap: spacing.sm, marginTop: spacing.lg },
  stepPrev: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.border,
    alignItems: 'center',
    backgroundColor: colors.white,
  },
  stepPrevText: { fontWeight: '600', color: colors.text },
  stepNext: {
    flex: 2,
    paddingVertical: 14,
    borderRadius: radius.md,
    backgroundColor: colors.primary,
    alignItems: 'center',
  },
  stepDone: { backgroundColor: colors.success },
  stepNextText: { fontWeight: '700', color: colors.white, fontSize: 16 },
});
