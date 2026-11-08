/**
 * Дизайн-токены Suppercook.
 * Тёплая «кулинарная» палитра: оранжевый как основной акцент.
 */
export const colors = {
  primary: '#FF6B35',
  primaryDark: '#E8541F',
  primaryLight: '#FFF1EB',
  background: '#FFFFFF',
  surface: '#F7F7F8',
  text: '#1A1A1A',
  textSecondary: '#6B6B6B',
  border: '#E5E5E5',
  success: '#2E9E5B',
  successLight: '#E8F6EE',
  warning: '#E8A317',
  warningLight: '#FDF6E7',
  danger: '#D9403F',
  white: '#FFFFFF',
} as const;

export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
} as const;

export const radius = {
  sm: 8,
  md: 12,
  lg: 16,
  pill: 999,
} as const;

export const typography = {
  title: { fontSize: 24, fontWeight: '700' as const },
  subtitle: { fontSize: 18, fontWeight: '600' as const },
  body: { fontSize: 16, fontWeight: '400' as const },
  caption: { fontSize: 13, fontWeight: '400' as const },
} as const;
