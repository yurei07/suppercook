import React, { useCallback, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  FlatList,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import { InventoryItem, api } from '../api/client';
import { colors, radius, spacing, typography } from '../theme';

interface Props {
  /** Переход к предложениям рецептов */
  onSuggestRecipes: () => void;
}

const QUICK_ADD = ['яйцо', 'молоко', 'помидор', 'сыр', 'хлеб', 'курица'];

/**
 * Главный экран: инвентарь пользователя.
 * Пустое состояние ведёт к действию — «Добавить продукты».
 */
export function InventoryScreen({ onSuggestRecipes }: Props) {
  const [items, setItems] = useState<InventoryItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [name, setName] = useState('');
  const [quantity, setQuantity] = useState('');
  const [unit, setUnit] = useState<'g' | 'ml' | 'pcs'>('pcs');
  const [saving, setSaving] = useState(false);

  const load = useCallback(async () => {
    try {
      setItems(await api.getInventory());
    } catch (e) {
      Alert.alert('Не удалось загрузить', e instanceof Error ? e.message : 'Проверьте API');
    } finally {
      setLoading(false);
    }
  }, []);

  React.useEffect(() => {
    void load();
  }, [load]);

  const add = async (preset?: string) => {
    const finalName = (preset ?? name).trim();
    const finalQty = quantity.trim() || '1';
    if (!finalName) return;

    setSaving(true);
    try {
      const next = await api.addInventoryItem({
        name: finalName,
        quantity: Number(finalQty) || 1,
        unit: preset ? 'pcs' : unit,
      });
      setItems(next);
      setName('');
      setQuantity('');
      setUnit('pcs');
    } catch (e) {
      Alert.alert('Ошибка', e instanceof Error ? e.message : 'Не удалось добавить');
    } finally {
      setSaving(false);
    }
  };

  const remove = async (id: string) => {
    try {
      setItems(await api.deleteInventoryItem(id));
    } catch (e) {
      Alert.alert('Ошибка', e instanceof Error ? e.message : 'Не удалось удалить');
    }
  };

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator color={colors.primary} size="large" />
      </View>
    );
  }

  return (
    <FlatList
      style={styles.container}
      data={items}
      keyExtractor={(i) => i.id}
      ListHeaderComponent={
        <View style={styles.header}>
          <Text style={typography.title}>Что у вас в холодильнике?</Text>
          <Text style={[typography.caption, styles.hint]}>
            Добавьте продукты вручную — и получите рецепты из того, что есть
          </Text>

          <View style={styles.form}>
            <TextInput
              style={styles.input}
              placeholder="Например, куриное филе"
              placeholderTextColor={colors.textSecondary}
              value={name}
              onChangeText={setName}
              autoCapitalize="none"
            />
            <View style={styles.row}>
              <TextInput
                style={[styles.input, styles.qtyInput]}
                placeholder="Кол-во"
                placeholderTextColor={colors.textSecondary}
                value={quantity}
                onChangeText={setQuantity}
                keyboardType="numeric"
              />
              {(['g', 'ml', 'pcs'] as const).map((u) => (
                <TouchableOpacity
                  key={u}
                  style={[styles.unitBtn, unit === u && styles.unitBtnActive]}
                  onPress={() => setUnit(u)}
                >
                  <Text style={[styles.unitText, unit === u && styles.unitTextActive]}>
                    {u === 'pcs' ? 'шт' : u}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
            <TouchableOpacity
              style={[styles.addBtn, saving && styles.addBtnDisabled]}
              onPress={() => void add()}
              disabled={saving}
            >
              {saving ? (
                <ActivityIndicator color={colors.white} />
              ) : (
                <Text style={styles.addBtnText}>Добавить</Text>
              )}
            </TouchableOpacity>
          </View>

          <Text style={styles.sectionLabel}>Быстрое добавление</Text>
          <View style={styles.chips}>
            {QUICK_ADD.map((q) => (
              <TouchableOpacity key={q} style={styles.chip} onPress={() => void add(q)}>
                <Text style={styles.chipText}>+ {q}</Text>
              </TouchableOpacity>
            ))}
          </View>

          {items.length > 0 && <Text style={styles.sectionLabel}>У вас есть</Text>}
        </View>
      }
      ListEmptyComponent={
        <View style={styles.empty}>
          <Text style={styles.emptyEmoji}>🧊</Text>
          <Text style={[typography.body, styles.emptyText]}>
            Пока пусто. Добавьте первый продукт выше.
          </Text>
        </View>
      }
      renderItem={({ item }) => (
        <View style={styles.itemRow}>
          <View style={styles.itemInfo}>
            <Text style={typography.body}>{item.name}</Text>
            <Text style={typography.caption}>
              {item.quantity} {item.unit === 'pcs' ? 'шт' : item.unit}
              {item.source === 'photo' ? ' · 📷' : ''}
            </Text>
          </View>
          <TouchableOpacity onPress={() => void remove(item.id)} hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
            <Text style={styles.delete}>Удалить</Text>
          </TouchableOpacity>
        </View>
      )}
      ListFooterComponent={
        items.length > 0 ? (
          <TouchableOpacity style={styles.suggestBtn} onPress={onSuggestRecipes}>
            <Text style={styles.suggestBtnText}>👨‍🍳 Предложи блюда</Text>
          </TouchableOpacity>
        ) : null
      }
      contentContainerStyle={styles.content}
    />
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.background },
  content: { padding: spacing.md, paddingBottom: 40 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  header: { marginBottom: spacing.sm },
  hint: { marginTop: spacing.xs, marginBottom: spacing.md },
  form: { gap: spacing.sm },
  row: { flexDirection: 'row', gap: spacing.sm },
  input: {
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: radius.md,
    paddingHorizontal: spacing.md,
    paddingVertical: 12,
    fontSize: 16,
    color: colors.text,
    backgroundColor: colors.surface,
    flex: 1,
  },
  qtyInput: { flex: 0.7 },
  unitBtn: {
    paddingHorizontal: spacing.md,
    paddingVertical: 12,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.border,
    backgroundColor: colors.surface,
  },
  unitBtnActive: { backgroundColor: colors.primary, borderColor: colors.primary },
  unitText: { fontSize: 14, color: colors.textSecondary, fontWeight: '600' },
  unitTextActive: { color: colors.white },
  addBtn: {
    backgroundColor: colors.primary,
    borderRadius: radius.md,
    paddingVertical: 14,
    alignItems: 'center',
  },
  addBtnDisabled: { opacity: 0.6 },
  addBtnText: { color: colors.white, fontSize: 16, fontWeight: '700' },
  sectionLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.textSecondary,
    marginTop: spacing.lg,
    marginBottom: spacing.sm,
    textTransform: 'uppercase',
  },
  chips: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm },
  chip: {
    backgroundColor: colors.primaryLight,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    borderRadius: radius.pill,
  },
  chipText: { color: colors.primaryDark, fontWeight: '600', fontSize: 14 },
  empty: { alignItems: 'center', padding: spacing.xl },
  emptyEmoji: { fontSize: 48, marginBottom: spacing.sm },
  emptyText: { color: colors.textSecondary, textAlign: 'center' },
  itemRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 14,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  itemInfo: { gap: 2 },
  delete: { color: colors.danger, fontSize: 14, fontWeight: '600' },
  suggestBtn: {
    backgroundColor: colors.primary,
    borderRadius: radius.lg,
    paddingVertical: 18,
    alignItems: 'center',
    marginTop: spacing.xl,
  },
  suggestBtnText: { color: colors.white, fontSize: 18, fontWeight: '700' },
});
