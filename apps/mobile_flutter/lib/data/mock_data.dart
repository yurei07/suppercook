import 'models/ingredient.dart';
import 'models/localized_text.dart';
import 'models/recipe.dart';
import 'models/shopping_item.dart';

/// Local demo content. In production this will be replaced by the API layer
/// (`/inventory`, `/recipes/suggest`, `/shopping`).
abstract final class MockData {
  // ---------------------------------------------------------------------------
  // Ingredients
  // ---------------------------------------------------------------------------
  static const salmon = Ingredient(
    id: 'salmon',
    name: LocalizedText('Salmon', 'Lachs'),
    amount: 300,
    unit: 'g',
  );
  static const couscous = Ingredient(
    id: 'couscous',
    name: LocalizedText('Couscous', 'Couscous'),
    amount: 150,
    unit: 'g',
    category: IngredientCategory.pantry,
  );
  static const cherryTomato = Ingredient(
    id: 'cherry_tomato',
    name: LocalizedText('Cherry tomatoes', 'Kirschtomaten'),
    amount: 200,
    unit: 'g',
    category: IngredientCategory.produce,
  );
  static const cucumber = Ingredient(
    id: 'cucumber',
    name: LocalizedText('Cucumber', 'Gurke'),
    amount: 1,
    unit: 'pcs',
    category: IngredientCategory.produce,
  );
  static const oliveOil = Ingredient(
    id: 'olive_oil',
    name: LocalizedText('Olive oil', 'Olivenöl'),
    amount: 2,
    unit: 'tbsp',
    category: IngredientCategory.pantry,
  );
  static const lemon = Ingredient(
    id: 'lemon',
    name: LocalizedText('Lemon', 'Zitrone'),
    amount: 1,
    unit: 'pcs',
    category: IngredientCategory.produce,
  );
  static const garlic = Ingredient(
    id: 'garlic',
    name: LocalizedText('Garlic', 'Knoblauch'),
    amount: 2,
    unit: 'clove',
    category: IngredientCategory.produce,
  );
  static const feta = Ingredient(
    id: 'feta',
    name: LocalizedText('Feta', 'Feta'),
    amount: 60,
    unit: 'g',
    category: IngredientCategory.dairy,
  );
  static const parsley = Ingredient(
    id: 'parsley',
    name: LocalizedText('Fresh parsley', 'Frische Petersilie'),
    amount: 1,
    unit: 'bunch',
    category: IngredientCategory.produce,
  );
  static const pasta = Ingredient(
    id: 'pasta',
    name: LocalizedText('Pasta', 'Pasta'),
    amount: 250,
    unit: 'g',
    category: IngredientCategory.pantry,
  );
  static const tomato = Ingredient(
    id: 'tomato',
    name: LocalizedText('Tomatoes', 'Tomaten'),
    amount: 400,
    unit: 'g',
    category: IngredientCategory.produce,
  );
  static const parmesan = Ingredient(
    id: 'parmesan',
    name: LocalizedText('Parmesan', 'Parmesan'),
    amount: 50,
    unit: 'g',
    category: IngredientCategory.dairy,
  );
  static const basil = Ingredient(
    id: 'basil',
    name: LocalizedText('Fresh basil', 'Frisches Basilikum'),
    amount: 1,
    unit: 'bunch',
    category: IngredientCategory.produce,
  );
  static const cream = Ingredient(
    id: 'cream',
    name: LocalizedText('Cream', 'Sahne'),
    amount: 100,
    unit: 'ml',
    category: IngredientCategory.dairy,
  );
  static const zucchini = Ingredient(
    id: 'zucchini',
    name: LocalizedText('Zucchini', 'Zucchini'),
    amount: 1,
    unit: 'pcs',
    category: IngredientCategory.produce,
  );
  static const bellPepper = Ingredient(
    id: 'bell_pepper',
    name: LocalizedText('Bell pepper', 'Paprika'),
    amount: 1,
    unit: 'pcs',
    category: IngredientCategory.produce,
  );
  static const arugula = Ingredient(
    id: 'arugula',
    name: LocalizedText('Arugula', 'Rucola'),
    amount: 60,
    unit: 'g',
    category: IngredientCategory.produce,
  );
  static const chickpeas = Ingredient(
    id: 'chickpeas',
    name: LocalizedText('Chickpeas', 'Kichererbsen'),
    amount: 200,
    unit: 'g',
    category: IngredientCategory.pantry,
  );
  static const pumpkin = Ingredient(
    id: 'pumpkin',
    name: LocalizedText('Pumpkin', 'Kürbis'),
    amount: 800,
    unit: 'g',
    category: IngredientCategory.produce,
  );
  static const onion = Ingredient(
    id: 'onion',
    name: LocalizedText('Onion', 'Zwiebel'),
    amount: 1,
    unit: 'pcs',
    category: IngredientCategory.produce,
  );
  static const coconutMilk = Ingredient(
    id: 'coconut_milk',
    name: LocalizedText('Coconut milk', 'Kokosmilch'),
    amount: 200,
    unit: 'ml',
    category: IngredientCategory.pantry,
  );
  static const vegetableBroth = Ingredient(
    id: 'vegetable_broth',
    name: LocalizedText('Vegetable broth', 'Gemüsebrühe'),
    amount: 500,
    unit: 'ml',
    category: IngredientCategory.pantry,
  );
  static const ginger = Ingredient(
    id: 'ginger',
    name: LocalizedText('Ginger', 'Ingwer'),
    amount: 20,
    unit: 'g',
    category: IngredientCategory.produce,
  );
  static const pizzaDough = Ingredient(
    id: 'pizza_dough',
    name: LocalizedText('Pizza dough', 'Pizzateig'),
    amount: 1,
    unit: 'pcs',
    category: IngredientCategory.pantry,
  );
  static const mushroom = Ingredient(
    id: 'mushroom',
    name: LocalizedText('Mushrooms', 'Pilze'),
    amount: 250,
    unit: 'g',
    category: IngredientCategory.produce,
  );
  static const mozzarella = Ingredient(
    id: 'mozzarella',
    name: LocalizedText('Mozzarella', 'Mozzarella'),
    amount: 125,
    unit: 'g',
    category: IngredientCategory.dairy,
  );
  static const truffleOil = Ingredient(
    id: 'truffle_oil',
    name: LocalizedText('Truffle oil', 'Trüffelöl'),
    amount: 1,
    unit: 'tbsp',
    category: IngredientCategory.pantry,
  );
  static const tomatoSauce = Ingredient(
    id: 'tomato_sauce',
    name: LocalizedText('Tomato sauce', 'Tomatensauce'),
    amount: 150,
    unit: 'g',
    category: IngredientCategory.pantry,
  );
  static const flour = Ingredient(
    id: 'flour',
    name: LocalizedText('Flour', 'Mehl'),
    amount: 200,
    unit: 'g',
    category: IngredientCategory.pantry,
  );
  static const milk = Ingredient(
    id: 'milk',
    name: LocalizedText('Milk', 'Milch'),
    amount: 200,
    unit: 'ml',
    category: IngredientCategory.dairy,
  );
  static const eggs = Ingredient(
    id: 'eggs',
    name: LocalizedText('Eggs', 'Eier'),
    amount: 2,
    unit: 'pcs',
    category: IngredientCategory.dairy,
  );
  static const bakingPowder = Ingredient(
    id: 'baking_powder',
    name: LocalizedText('Baking powder', 'Backpulver'),
    amount: 1,
    unit: 'tsp',
    category: IngredientCategory.pantry,
  );
  static const berries = Ingredient(
    id: 'berries',
    name: LocalizedText('Mixed berries', 'Beerenmix'),
    amount: 150,
    unit: 'g',
    category: IngredientCategory.produce,
  );
  static const mapleSyrup = Ingredient(
    id: 'maple_syrup',
    name: LocalizedText('Maple syrup', 'Ahornsirup'),
    amount: 2,
    unit: 'tbsp',
    category: IngredientCategory.pantry,
  );
  static const butter = Ingredient(
    id: 'butter',
    name: LocalizedText('Butter', 'Butter'),
    amount: 30,
    unit: 'g',
    category: IngredientCategory.dairy,
  );
  static const bread = Ingredient(
    id: 'bread',
    name: LocalizedText('Sourdough bread', 'Sauerteigbrot'),
    amount: 4,
    unit: 'slice',
    category: IngredientCategory.pantry,
  );
  static const avocado = Ingredient(
    id: 'avocado',
    name: LocalizedText('Avocado', 'Avocado'),
    amount: 1,
    unit: 'pcs',
    category: IngredientCategory.produce,
  );
  static const chiliFlakes = Ingredient(
    id: 'chili_flakes',
    name: LocalizedText('Chili flakes', 'Chiliflocken'),
    amount: 1,
    unit: 'pinch',
    category: IngredientCategory.pantry,
  );
  static const quinoa = Ingredient(
    id: 'quinoa',
    name: LocalizedText('Quinoa', 'Quinoa'),
    amount: 150,
    unit: 'g',
    category: IngredientCategory.pantry,
  );
  static const sweetPotato = Ingredient(
    id: 'sweet_potato',
    name: LocalizedText('Sweet potato', 'Süßkartoffel'),
    amount: 1,
    unit: 'pcs',
    category: IngredientCategory.produce,
  );
  static const spinach = Ingredient(
    id: 'spinach',
    name: LocalizedText('Spinach', 'Spinat'),
    amount: 100,
    unit: 'g',
    category: IngredientCategory.produce,
  );
  static const tahini = Ingredient(
    id: 'tahini',
    name: LocalizedText('Tahini', 'Tahini'),
    amount: 2,
    unit: 'tbsp',
    category: IngredientCategory.pantry,
  );

  // ---------------------------------------------------------------------------
  // Default state
  // ---------------------------------------------------------------------------
  static const pantryItems = <Ingredient>[
    salmon,
    cherryTomato,
    cucumber,
    oliveOil,
    lemon,
    garlic,
    pasta,
    tomato,
    parmesan,
    zucchini,
    bellPepper,
    arugula,
    chickpeas,
    pumpkin,
    onion,
    mushroom,
    flour,
    milk,
    eggs,
    butter,
    bread,
    avocado,
    chiliFlakes,
    quinoa,
    sweetPotato,
    spinach,
  ];

  static const scanDetected = <Ingredient>[
    salmon,
    cherryTomato,
    cucumber,
    garlic,
    lemon,
    feta,
    parsley,
  ];

  static const featuredRecipeIds = ['salmon_bowl', 'tomato_pasta', 'pumpkin_soup'];

  static const shoppingItems = <ShoppingItem>[
    ShoppingItem(
      id: 'feta',
      name: LocalizedText('Feta', 'Feta'),
      category: IngredientCategory.dairy,
      source: feta,
    ),
    ShoppingItem(
      id: 'basil',
      name: LocalizedText('Fresh basil', 'Frisches Basilikum'),
      category: IngredientCategory.produce,
      source: basil,
    ),
    ShoppingItem(
      id: 'coconut_milk',
      name: LocalizedText('Coconut milk', 'Kokosmilch'),
      category: IngredientCategory.pantry,
      source: coconutMilk,
    ),
    ShoppingItem(
      id: 'mozzarella',
      name: LocalizedText('Mozzarella', 'Mozzarella'),
      category: IngredientCategory.dairy,
      source: mozzarella,
    ),
    ShoppingItem(
      id: 'maple_syrup',
      name: LocalizedText('Maple syrup', 'Ahornsirup'),
      category: IngredientCategory.pantry,
      source: mapleSyrup,
      checked: true,
    ),
    ShoppingItem(
      id: 'truffle_oil',
      name: LocalizedText('Truffle oil', 'Trüffelöl'),
      category: IngredientCategory.pantry,
      source: truffleOil,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Recipes
  // ---------------------------------------------------------------------------
  static const recipes = <Recipe>[
    Recipe(
      id: 'salmon_bowl',
      title: LocalizedText('Mediterranean Salmon Bowl', 'Mediterraner Lachs-Bowl'),
      description: LocalizedText(
        'Seared salmon, fluffy couscous and crunchy vegetables with a lemon-herb dressing.',
        'Gebratener Lachs, lockerer Couscous und knackiges Gemüse mit Zitronen-Kräuter-Dressing.',
      ),
      image: 'assets/images/food/salmon_bowl.jpg',
      minutes: 25,
      calories: 540,
      protein: 38,
      carbs: 42,
      fat: 24,
      servings: 2,
      difficulty: RecipeDifficulty.easy,
      tags: [RecipeTag.highProtein],
      ingredients: [
        salmon,
        couscous,
        cherryTomato,
        cucumber,
        oliveOil,
        lemon,
        garlic,
        feta,
        parsley,
      ],
      steps: [
        RecipeStep(
          title: LocalizedText('Cook the couscous', 'Couscous garen'),
          body: LocalizedText(
            'Pour hot vegetable broth over the couscous, cover and let it stand for 5 minutes. Fluff with a fork.',
            'Übergieße den Couscous mit heißer Gemüsebrühe, decke ihn ab und lass ihn 5 Minuten ziehen. Mit einer Gabel auflockern.',
          ),
          timerMinutes: 5,
        ),
        RecipeStep(
          title: LocalizedText('Sear the salmon', 'Lachs braten'),
          body: LocalizedText(
            'Pat the salmon dry, season with salt and pepper and sear skin-side down for 4 minutes. Flip and cook 2 more minutes.',
            'Tupfe den Lachs trocken, würze ihn mit Salz und Pfeffer und brate ihn 4 Minuten auf der Hautseite. Wenden und 2 Minuten weiterbraten.',
          ),
          timerMinutes: 6,
        ),
        RecipeStep(
          title: LocalizedText('Whisk the dressing', 'Dressing anrühren'),
          body: LocalizedText(
            'Whisk olive oil, lemon juice, crushed garlic and chopped parsley.',
            'Verrühre Olivenöl, Zitronensaft, gepressten Knoblauch und gehackte Petersilie.',
          ),
        ),
        RecipeStep(
          title: LocalizedText('Build the bowl', 'Bowl anrichten'),
          body: LocalizedText(
            'Fluff the couscous, top with salmon, tomatoes, cucumber and crumbled feta. Drizzle with dressing.',
            'Lockere den Couscous auf, belege ihn mit Lachs, Tomaten, Gurke und zerbröseltem Feta. Mit dem Dressing beträufeln.',
          ),
        ),
      ],
    ),
    Recipe(
      id: 'tomato_pasta',
      title: LocalizedText('Creamy Tomato Pasta', 'Cremige Tomatenpasta'),
      description: LocalizedText(
        'Silky tomato sauce, parmesan and fresh basil — comfort food in 20 minutes.',
        'Seidige Tomatensauce, Parmesan und frisches Basilikum – Soulfood in 20 Minuten.',
      ),
      image: 'assets/images/food/tomato_pasta.jpg',
      minutes: 20,
      calories: 610,
      protein: 19,
      carbs: 82,
      fat: 22,
      servings: 2,
      difficulty: RecipeDifficulty.easy,
      tags: [RecipeTag.vegetarian, RecipeTag.quick],
      ingredients: [pasta, tomato, garlic, oliveOil, parmesan, basil, cream],
      steps: [
        RecipeStep(
          title: LocalizedText('Boil the pasta', 'Pasta kochen'),
          body: LocalizedText(
            'Cook pasta in salted water until al dente. Keep a cup of pasta water.',
            'Koche die Pasta in Salzwasser bissfest. Behalte eine Tasse Nudelwasser.',
          ),
          timerMinutes: 10,
        ),
        RecipeStep(
          title: LocalizedText('Make the sauce', 'Sauce zubereiten'),
          body: LocalizedText(
            'Sauté garlic in olive oil, add chopped tomatoes and simmer for 8 minutes.',
            'Knoblauch in Olivenöl anschwitzen, gehackte Tomaten zugeben und 8 Minuten köcheln lassen.',
          ),
          timerMinutes: 8,
        ),
        RecipeStep(
          title: LocalizedText('Finish the sauce', 'Sauce verfeinern'),
          body: LocalizedText(
            'Stir in cream and grated parmesan. Season and loosen with pasta water.',
            'Sahne und geriebenen Parmesan einrühren. Würzen und mit Nudelwasser cremig rühren.',
          ),
        ),
        RecipeStep(
          title: LocalizedText('Serve', 'Servieren'),
          body: LocalizedText(
            'Toss pasta with the sauce and finish with fresh basil.',
            'Pasta mit der Sauce vermengen und mit frischem Basilikum servieren.',
          ),
        ),
      ],
    ),
    Recipe(
      id: 'green_salad',
      title: LocalizedText('Charred Veggie Salad', 'Gegrillter Gemüsesalat'),
      description: LocalizedText(
        'Smoky grilled vegetables, chickpeas and arugula with a bright lemon dressing.',
        'Rauchiges Grillgemüse, Kichererbsen und Rucola mit einem frischen Zitronendressing.',
      ),
      image: 'assets/images/food/green_salad.jpg',
      minutes: 15,
      calories: 320,
      protein: 12,
      carbs: 30,
      fat: 18,
      servings: 2,
      difficulty: RecipeDifficulty.easy,
      tags: [RecipeTag.vegan, RecipeTag.quick, RecipeTag.glutenFree],
      ingredients: [zucchini, bellPepper, cherryTomato, oliveOil, lemon, arugula, chickpeas],
      steps: [
        RecipeStep(
          title: LocalizedText('Char the vegetables', 'Gemüse rösten'),
          body: LocalizedText(
            'Slice zucchini and pepper, toss with olive oil and grill in a hot pan for 6 minutes.',
            'Zucchini und Paprika schneiden, mit Olivenöl vermengen und 6 Minuten in einer heißen Pfanne rösten.',
          ),
          timerMinutes: 6,
        ),
        RecipeStep(
          title: LocalizedText('Mix the dressing', 'Dressing mischen'),
          body: LocalizedText(
            'Whisk lemon juice, olive oil, salt and pepper.',
            'Zitronensaft, Olivenöl, Salz und Pfeffer verrühren.',
          ),
        ),
        RecipeStep(
          title: LocalizedText('Assemble', 'Anrichten'),
          body: LocalizedText(
            'Toss arugula, chickpeas and grilled vegetables with the dressing.',
            'Rucola, Kichererbsen und gegrilltes Gemüse mit dem Dressing vermengen.',
          ),
        ),
      ],
    ),
    Recipe(
      id: 'pumpkin_soup',
      title: LocalizedText('Golden Pumpkin Soup', 'Goldene Kürbissuppe'),
      description: LocalizedText(
        'Velvety pumpkin soup with coconut milk and a hint of ginger.',
        'Samtige Kürbissuppe mit Kokosmilch und einem Hauch Ingwer.',
      ),
      image: 'assets/images/food/pumpkin_soup.jpg',
      minutes: 35,
      calories: 280,
      protein: 6,
      carbs: 32,
      fat: 14,
      servings: 4,
      difficulty: RecipeDifficulty.easy,
      tags: [RecipeTag.vegan, RecipeTag.glutenFree],
      ingredients: [pumpkin, onion, garlic, coconutMilk, vegetableBroth, oliveOil, ginger],
      steps: [
        RecipeStep(
          title: LocalizedText('Prepare the pumpkin', 'Kürbis vorbereiten'),
          body: LocalizedText(
            'Peel and cube the pumpkin. Chop the onion and garlic.',
            'Kürbis schälen und würfeln. Zwiebel und Knoblauch hacken.',
          ),
        ),
        RecipeStep(
          title: LocalizedText('Sauté the base', 'Basis anbraten'),
          body: LocalizedText(
            'Sweat onion, garlic and ginger in olive oil for 3 minutes.',
            'Zwiebel, Knoblauch und Ingwer 3 Minuten in Olivenöl anschwitzen.',
          ),
          timerMinutes: 3,
        ),
        RecipeStep(
          title: LocalizedText('Simmer', 'Köcheln'),
          body: LocalizedText(
            'Add pumpkin and broth, simmer for 20 minutes until soft.',
            'Kürbis und Brühe zugeben und 20 Minuten weich köcheln.',
          ),
          timerMinutes: 20,
        ),
        RecipeStep(
          title: LocalizedText('Blend', 'Pürieren'),
          body: LocalizedText(
            'Blend with coconut milk, season and serve.',
            'Mit Kokosmilch pürieren, abschmecken und servieren.',
          ),
        ),
      ],
    ),
    Recipe(
      id: 'mushroom_pizza',
      title: LocalizedText('Truffle Mushroom Pizza', 'Trüffel-Pilz-Pizza'),
      description: LocalizedText(
        'Crispy crust, garlicky mushrooms, mozzarella and a drizzle of truffle oil.',
        'Knuspriger Rand, würzige Pilze, Mozzarella und ein Hauch Trüffelöl.',
      ),
      image: 'assets/images/food/mushroom_pizza.jpg',
      minutes: 40,
      calories: 720,
      protein: 28,
      carbs: 88,
      fat: 30,
      servings: 2,
      difficulty: RecipeDifficulty.medium,
      tags: [RecipeTag.vegetarian],
      ingredients: [pizzaDough, tomatoSauce, mushroom, mozzarella, parmesan, truffleOil, arugula],
      steps: [
        RecipeStep(
          title: LocalizedText('Preheat the oven', 'Ofen vorheizen'),
          body: LocalizedText(
            'Preheat the oven to 240 °C with a baking tray inside.',
            'Heize den Ofen auf 240 °C vor und stelle ein Backblech hinein.',
          ),
        ),
        RecipeStep(
          title: LocalizedText('Top the dough', 'Teig belegen'),
          body: LocalizedText(
            'Spread tomato sauce on the dough, add sliced mushrooms and mozzarella.',
            'Tomatensauce auf dem Teig verteilen, geschnittene Pilze und Mozzarella daraufgeben.',
          ),
        ),
        RecipeStep(
          title: LocalizedText('Bake', 'Backen'),
          body: LocalizedText(
            'Bake for 12–15 minutes until the crust is golden.',
            '12–15 Minuten backen, bis der Rand goldbraun ist.',
          ),
          timerMinutes: 14,
        ),
        RecipeStep(
          title: LocalizedText('Finish', 'Veredeln'),
          body: LocalizedText(
            'Drizzle with truffle oil, add parmesan and fresh arugula.',
            'Mit Trüffelöl beträufeln, Parmesan und frischen Rucola daraufgeben.',
          ),
        ),
      ],
    ),
    Recipe(
      id: 'berry_pancakes',
      title: LocalizedText('Berry Pancake Stack', 'Beeren-Pfannkuchen'),
      description: LocalizedText(
        'Fluffy pancakes, warm berries and maple syrup. Weekend breakfast sorted.',
        'Fluffige Pfannkuchen, warme Beeren und Ahornsirup. Das Wochenendfrühstück ist gerettet.',
      ),
      image: 'assets/images/food/berry_pancakes.jpg',
      minutes: 25,
      calories: 480,
      protein: 14,
      carbs: 68,
      fat: 16,
      servings: 2,
      difficulty: RecipeDifficulty.easy,
      tags: [RecipeTag.vegetarian, RecipeTag.breakfast],
      ingredients: [flour, milk, eggs, bakingPowder, berries, mapleSyrup, butter],
      steps: [
        RecipeStep(
          title: LocalizedText('Make the batter', 'Teig anrühren'),
          body: LocalizedText(
            'Whisk flour, milk, eggs and baking powder into a smooth batter.',
            'Mehl, Milch, Eier und Backpulver zu einem glatten Teig verrühren.',
          ),
        ),
        RecipeStep(
          title: LocalizedText('Cook the pancakes', 'Pfannkuchen backen'),
          body: LocalizedText(
            'Melt butter in a pan and cook small pancakes for 2 minutes per side.',
            'Butter in einer Pfanne schmelzen und kleine Pfannkuchen je 2 Minuten pro Seite backen.',
          ),
          timerMinutes: 4,
        ),
        RecipeStep(
          title: LocalizedText('Serve', 'Servieren'),
          body: LocalizedText(
            'Stack the pancakes with berries and maple syrup.',
            'Pfannkuchen mit Beeren und Ahornsirup stapeln.',
          ),
        ),
      ],
    ),
    Recipe(
      id: 'avocado_toast',
      title: LocalizedText('Avocado Toast', 'Avocado-Toast'),
      description: LocalizedText(
        'Crisp sourdough, creamy avocado, lemon and a kick of chili.',
        'Knuspriges Sauerteigbrot, cremige Avocado, Zitrone und ein Kick Chili.',
      ),
      image: 'assets/images/food/avocado_toast.jpg',
      minutes: 10,
      calories: 350,
      protein: 10,
      carbs: 34,
      fat: 20,
      servings: 1,
      difficulty: RecipeDifficulty.easy,
      tags: [RecipeTag.vegan, RecipeTag.quick],
      ingredients: [bread, avocado, lemon, chiliFlakes, oliveOil, cherryTomato],
      steps: [
        RecipeStep(
          title: LocalizedText('Toast the bread', 'Brot toasten'),
          body: LocalizedText(
            'Toast the bread until crisp.',
            'Toast das Brot knusprig.',
          ),
          timerMinutes: 2,
        ),
        RecipeStep(
          title: LocalizedText('Top it', 'Belegen'),
          body: LocalizedText(
            'Mash avocado with lemon, spread on toast and top with tomatoes, chili flakes and olive oil.',
            'Avocado mit Zitrone zerdrücken, auf dem Toast verstreichen und mit Tomaten, Chiliflocken und Olivenöl belegen.',
          ),
        ),
      ],
    ),
    Recipe(
      id: 'harvest_bowl',
      title: LocalizedText('Harvest Grain Bowl', 'Harvest-Grain-Bowl'),
      description: LocalizedText(
        'Quinoa, roasted sweet potato and chickpeas with a creamy tahini dressing.',
        'Quinoa, geröstete Süßkartoffel und Kichererbsen mit cremigem Tahini-Dressing.',
      ),
      image: 'assets/images/food/harvest_bowl.jpg',
      minutes: 20,
      calories: 420,
      protein: 16,
      carbs: 58,
      fat: 14,
      servings: 2,
      difficulty: RecipeDifficulty.easy,
      tags: [RecipeTag.vegan, RecipeTag.highProtein, RecipeTag.quick],
      ingredients: [quinoa, chickpeas, sweetPotato, spinach, tahini, lemon, oliveOil],
      steps: [
        RecipeStep(
          title: LocalizedText('Cook the quinoa', 'Quinoa kochen'),
          body: LocalizedText(
            'Rinse quinoa and simmer in salted water for 12 minutes.',
            'Quinoa spülen und 12 Minuten in Salzwasser köcheln.',
          ),
          timerMinutes: 12,
        ),
        RecipeStep(
          title: LocalizedText('Roast the sweet potato', 'Süßkartoffel rösten'),
          body: LocalizedText(
            'Cube sweet potato and roast in olive oil for 15 minutes.',
            'Süßkartoffel würfeln und 15 Minuten in Olivenöl rösten.',
          ),
          timerMinutes: 15,
        ),
        RecipeStep(
          title: LocalizedText('Assemble', 'Anrichten'),
          body: LocalizedText(
            'Toss quinoa, spinach, chickpeas and sweet potato with tahini and lemon.',
            'Quinoa, Spinat, Kichererbsen und Süßkartoffel mit Tahini und Zitrone vermengen.',
          ),
        ),
      ],
    ),
  ];
}
