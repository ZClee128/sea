import Foundation

struct RecipeData {
    static let samples: [Recipe] = [
        // ---- 3 original recipes (first 2 have video) ----
        Recipe(
            title: "Golden Truffle Pasta",
            category: "Main Course",
            imageName: "pasta",
            story: "Inspired by the autumn harvests in Northern Italy, this pasta brings together the earthy richness of shaved golden truffles and a delicate cream sauce.",
            ingredients: ["200g Tagliatelle", "50g Fresh golden truffles", "100ml Heavy cream", "30g Butter", "Parmesan", "Sea salt & Pepper"],
            steps: ["Boil pasta in salted water until al dente.", "Melt butter and add cream, simmer gently.", "Toss pasta in sauce.", "Top with truffle shavings and parmesan."],
            videoURL: "Golden Truffle Pasta",
            isPremium: true,
            chefName: "Giovanni"
        ),
        Recipe(
            title: "Midnight Berry Tart",
            category: "Dessert",
            imageName: "tart",
            story: "A visual masterpiece capturing the essence of a moonlit garden, combining Moroccan-spiced crust with vibrant berry medley and a gold leaf garnish.",
            ingredients: ["1 pre-baked tart shell", "250g Mixed berries", "200g Mascarpone", "2 tbsp Honey", "1 tsp Vanilla", "Gold leaf"],
            steps: ["Whisk mascarpone, honey, and vanilla.", "Spread into tart shell.", "Arrange berries artfully.", "Apply gold leaf flakes."],
            videoURL: "Midnight Berry Tart",
            isPremium: true,
            chefName: "Amina"
        ),
        Recipe(
            title: "Emerald Zen Bowl",
            category: "Healthy Main",
            imageName: "bowl",
            story: "Balance in a bowl. Locally sourced kale, creamy avocado, and protein-rich edamame make this as nourishing as it is beautiful.",
            ingredients: ["1 cup Quinoa", "½ Avocado", "½ cup Edamame", "1 cup Kale", "1 tsp Sesame seeds", "Tahini dressing"],
            steps: ["Place quinoa as base.", "Arrange toppings in sections.", "Sprinkle sesame seeds.", "Drizzle tahini before serving."],
            videoURL: nil
        ),
        // ---- 10 new recipes ----
        Recipe(
            title: "Saffron Risotto",
            category: "Main Course",
            imageName: "Saffron Risotto",
            story: "A Milanese classic, golden with saffron and finished with aged Parmigiano-Reggiano. Every spoonful is silky, aromatic luxury.",
            ingredients: ["300g Arborio rice", "1g Saffron threads", "1L Warm vegetable stock", "1 Shallot", "100ml White wine", "60g Parmigiano-Reggiano"],
            steps: ["Toast shallot in butter.", "Add rice and white wine.", "Ladle in warm stock gradually.", "Stir in saffron and parmesan off heat."],
            videoURL: nil
        ),
        Recipe(
            title: "Lemon Lavender Tart",
            category: "Dessert",
            imageName: "Lemon Lavender Tart",
            story: "Bright citrus meets floral lavender in a silky custard tart. The combination is unexpected, delicate, and completely unforgettable.",
            ingredients: ["1 tart shell", "3 Lemons (zest & juice)", "1 tsp Dried lavender", "4 Eggs", "150g Sugar", "80g Butter"],
            steps: ["Infuse lavender in lemon juice.", "Whisk eggs and sugar.", "Cook over bain-marie until thick.", "Pour into shell and refrigerate."],
            videoURL: nil
        ),
        Recipe(
            title: "Miso Glazed Salmon",
            category: "Main Course",
            imageName: "Miso Glazed Salmon",
            story: "A Japanese-inspired glaze of white miso, mirin and sake transforms a humble salmon fillet into a restaurant-worthy centrepiece.",
            ingredients: ["2 Salmon fillets", "3 tbsp White miso", "2 tbsp Mirin", "1 tbsp Sake", "1 tbsp Sugar", "Sesame seeds"],
            steps: ["Mix miso, mirin, sake, and sugar.", "Marinate salmon 30 minutes.", "Broil 8 minutes until caramelized.", "Garnish with sesame seeds."],
            videoURL: nil
        ),
        Recipe(
            title: "Chocolate Fondant",
            category: "Dessert",
            imageName: "Chocolate Fondant",
            story: "The molten core of a perfectly baked fondant is one of dessert's greatest pleasures. Dark chocolate, butter, and precision timing are all you need.",
            ingredients: ["150g Dark chocolate (70%)", "150g Butter", "4 Eggs", "100g Sugar", "60g Plain flour", "Cocoa powder for dusting"],
            steps: ["Melt chocolate and butter.", "Whisk eggs and sugar until light.", "Fold in chocolate, then flour.", "Bake 180°C for 12 minutes exactly."],
            videoURL: nil
        ),
        Recipe(
            title: "Roasted Beet Salad",
            category: "Healthy Main",
            imageName: "Roasted Beet Salad",
            story: "Sweet roasted beets, creamy goat cheese, and candied walnuts with a tangy balsamic reduction — a salad that feels like a celebration.",
            ingredients: ["4 Beetroots", "100g Goat cheese", "50g Candied walnuts", "Mixed greens", "3 tbsp Balsamic glaze", "Olive oil"],
            steps: ["Roast beets at 200°C for 45 minutes.", "Let cool and slice.", "Arrange on greens with cheese.", "Drizzle balsamic and scatter walnuts."],
            videoURL: nil
        ),
        Recipe(
            title: "Prawn Bisque",
            category: "Main Course",
            imageName: "Prawn Bisque",
            story: "A velvety French classic, simmered with cognac and cream. The shells give the broth an intense, complex seafood depth.",
            ingredients: ["500g Prawn shells & heads", "2 tbsp Tomato paste", "50ml Cognac", "200ml Heavy cream", "1 Carrot", "Tarragon"],
            steps: ["Sauté lobster shells and aromatics.", "Add tomato paste and deglaze with cognac.", "Simmer with water, then strain.", "Add cream and butter, season to taste."],
            videoURL: nil,
            isPremium: true
        ),
        Recipe(
            title: "Matcha Panna Cotta",
            category: "Dessert",
            imageName: "Matcha Panna Cotta",
            story: "Silky Italian panna cotta gets a Japanese makeover with ceremonial-grade matcha. The bittersweet earthiness pairs perfectly with a honey drizzle.",
            ingredients: ["500ml Cream", "2 tbsp Ceremonial matcha", "2 tsp Gelatin", "60g Sugar", "Honey to serve", "Fresh berries"],
            steps: ["Warm cream with sugar and matcha.", "Bloom gelatin, stir into cream.", "Pour into moulds, refrigerate 4 hours.", "Unmould and serve with honey."],
            videoURL: nil
        ),
        Recipe(
            title: "Avocado Toast Royale",
            category: "Healthy Main",
            imageName: "Avocado Toast Royale",
            story: "Elevated far beyond its brunch reputation: whipped ricotta, microgreens, a perfectly poached egg, and a scatter of chilli flakes.",
            ingredients: ["2 slices Sourdough", "1 Ripe avocado", "50g Ricotta", "1 Egg (poached)", "Microgreens", "Chilli flakes & sea salt"],
            steps: ["Toast sourdough until golden.", "Whip ricotta, spread on toast.", "Mash avocado with lemon, layer on.", "Top with poached egg and microgreens."],
            videoURL: nil
        ),
        Recipe(
            title: "Lobster Bisque",
            category: "Main Course",
            imageName: "Lobster Bisque",
            story: "The crown jewel of French seafood cookery. Rich, golden, and intensely flavoured — every bowl commands attention.",
            ingredients: ["1 Lobster (1kg)", "100ml Brandy", "300ml Cream", "2 Shallots", "3 tbsp Tomato paste", "Tarragon & chervil"],
            steps: ["Cook lobster, remove meat.", "Sauté shells with shallots.", "Deglaze with brandy.", "Add cream, simmer, strain and serve."],
            videoURL: nil
        ),
        Recipe(
            title: "Shizuku Stir-fry",
            category: "Main Course",
            imageName: "Shizuku Stir-fry",
            story: "A vibrant and healthy stir-fry inspired by Japanese garden fresh ingredients, featuring crisp vegetables and a delicate soy-ginger glaze.",
            ingredients: ["200g Tofu", "1 cup Broccoli florets", "1 Carrot (julienned)", "1 Bell pepper (sliced)", "2 tbsp Soy sauce", "1 tbsp Ginger (grated)"],
            steps: ["Prepare vegetables.", "Toss with soy and ginger.", "Garnish and serve."],
            videoURL: nil,
            isPremium: true, chefName: "Kenji"
        ),
        Recipe(
            title: "Passion Fruit Soufflé",
            category: "Dessert",
            imageName: "Passion Fruit Soufflé",
            story: "The soufflé is theatre and science in one. This tropical version, made with passion fruit curd, rises high and tastes of warm island sunshine.",
            ingredients: ["4 Passion fruits", "4 Eggs (separated)", "80g Sugar", "20g Flour", "200ml Milk", "Butter for ramekins"],
            steps: ["Make passion fruit curd.", "Fold into stiff meringue gently.", "Fill buttered ramekins to the brim.", "Bake 190°C, 12 minutes. Serve immediately."],
            videoURL: nil
        ),
    ]
}
