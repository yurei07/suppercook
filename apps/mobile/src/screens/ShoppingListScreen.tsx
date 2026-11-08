import React, { useCallback, useState } from 'react';
import {
  ActivityIndicator,
  FlatList,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { ShoppingListItem, api } from '../api/client';
import { colors, radius, spacing, typography } from '../theme';

/**
 * Умный список покупок.
 * Позиции сюда попадают только из того, ЧЕГО НЕ ХВАТАЕТ в инвентаре.
 */
export function ShoppingListScreen() {
  const [items, setItems] = useState<ShoppingListItem[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    try {
      setItems(await api.getShoppingList());
    } catch {
      /* тихо: экран покажет пустое состояние */
    } finally {
      setLoading(false);
    }
  }, []);

  // Перезагружаем при каждом возврате на вкладку —
  // список мог измениться на экране рецепта
  useFocusEffect(
    useCallback(() => {
      void load();
    }, [load]),
  );

  const toggle = async (item: ShoppingListItem) => {
    // Оптистичное обновление UI
    setItems((prev) =>
      prev.map((i) => (i.id === item.id ? { ...i, checked: !i.checked } : i)),
    );
    try {
      await api.toggleShoppingItem(item.id, !item.checked);
    } catch {
      await load(); // откат при ошибке
    }
  };

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator color={colors.primary} size="large" />
      </View>
    );
  }

  const remaining = items.filter((i) => !i.checked);

  return (
    <FlatList
      style={styles.container}
      data={items}
      keyExtractor={(i) => i.id}
      contentContainerStyle={styles.content}
      ListHeaderComponent={
        <View>
          <Text style={typography.title}>Список покупок</Text>
          <Text style={[typography.caption, styles.hint]}>
            {remaining.length > 0
              ? `Осталось купить: ${remaining.length}`
              : items.length > 0
                ? 'Всё куплено! 🎉'
                : ''}
          </Text>
        </View>
      }
      ListEmptyComponent={
        <View style={styles.center}>
          <Text style={styles.emptyEmoji}>🛒</Text>
          <Text style={[typography.body, styles.emptyText]}>
            Список пуст. Выберите рецепт — и недостающие ингредиенты попадут сюда
            автоматически.
          </Text>
        </View>
      }
      renderItem={({ item }) => (
        <TouchableOpacity style={styles.row} onPress={() => void toggle(item)}>
          <View style={[styles.checkbox, item.checked && styles.checkboxChecked]}>
            {item.checked && <Text style={styles.check}>✓</Text>}
          </View>
          <View style={styles.info}>
            <Text style={[styles.name, item.checked && styles.nameChecked]}>
              {item.name}
            </Text>
            <Text style={typography.caption}>
              {item.quantity} {item.unit}
              {item.recipeIds.length > 0 ? ` · из ${item.recipeIds.length} рецептов` : ''}
            </Text>
          </View>
        </TouchableOpacity>
      )}
    />
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  content: { padding: spacing.md, paddingBottom: 40 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: spacing.xl },
  hint: { marginTop: spacing.xs, marginBottom: spacing.md },
  emptyEmoji: { fontSize: 48, marginBottom: spacing.sm },
  emptyText: { color: colors.textSecondary, textAlign: 'center' },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 14,
    gap: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  checkbox: {
    width: 26,
    height: 26,
    borderRadius: 13,
    borderWidth: 2,
    borderColor: colors.border,
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkboxChecked: { backgroundColor: colors.success, borderColor: colors.success },
  check: { color: colors.white, fontWeight: '700', fontSize: 14 },
  info: { flex: 1 },
  name: { fontSize: 16, color: colors.text },
  nameChecked: { textDecorationLine: 'line-through', color: colors.textSecondary },
});
