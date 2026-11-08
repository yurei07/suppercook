import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { NavigationContainer, DefaultTheme } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { Recipe } from './src/api/client';
import { colors } from './src/theme';
import { InventoryScreen } from './src/screens/InventoryScreen';
import { RecipesScreen } from './src/screens/RecipesScreen';
import { RecipeDetailScreen } from './src/screens/RecipeDetailScreen';
import { ShoppingListScreen } from './src/screens/ShoppingListScreen';

type RootStackParamList = {
  Tabs: undefined;
  RecipeDetail: { recipe: Recipe };
};

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator();

const TAB_ICONS: Record<string, string> = {
  Холодильник: '🧊',
  Рецепты: '👨‍🍳',
  Покупки: '🛒',
};

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarActiveTintColor: colors.primary,
        tabBarInactiveTintColor: colors.textSecondary,
        tabBarStyle: styles.tabBar,
        tabBarIcon: ({ focused }) => (
          <View style={{ opacity: focused ? 1 : 0.45 }}>
            <Text style={{ fontSize: 20 }}>{TAB_ICONS[route.name] ?? '•'}</Text>
          </View>
        ),
      })}
    >
      <Tab.Screen name="Холодильник">
        {({ navigation }) => (
          <InventoryScreen
            onSuggestRecipes={() => navigation.navigate('Рецепты' as never)}
          />
        )}
      </Tab.Screen>
      <Tab.Screen name="Рецепты">
        {({ navigation }) => (
          <RecipesScreen
            onOpenRecipe={(recipe) =>
              navigation.navigate('RecipeDetail', { recipe } as never)
            }
          />
        )}
      </Tab.Screen>
      <Tab.Screen name="Покупки" component={ShoppingListScreen} />
    </Tab.Navigator>
  );
}

export default function App() {
  return (
    <SafeAreaProvider>
      <NavigationContainer
        theme={{
          ...DefaultTheme,
          colors: { ...DefaultTheme.colors, background: colors.background },
        }}
      >
        <StatusBar style="dark" />
        <Stack.Navigator screenOptions={{ headerShown: false }}>
          <Stack.Screen name="Tabs" component={MainTabs} />
          <Stack.Screen name="RecipeDetail">
            {({ route, navigation }) => (
              <RecipeDetailScreen
                recipe={route.params.recipe}
                onBack={() => navigation.goBack()}
                onGoToShopping={() =>
                  navigation.navigate('Tabs', { screen: 'Покупки' } as never)
                }
              />
            )}
          </Stack.Screen>
        </Stack.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  tabBar: {
    backgroundColor: colors.white,
    borderTopColor: colors.border,
    height: 60,
    paddingBottom: 6,
    paddingTop: 6,
  },
});
