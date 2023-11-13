//
//  DietaryRestrictions.swift
//  PassplateApp
//
//  Created by Trent Ho on 11/7/23.
//

import Foundation


struct DietaryRestrictions {
    static let shared = DietaryRestrictions()

    let restrictions: [String: [String]] = [
        "nut-free": [
            "peanuts", "walnuts", "almonds", "hazelnuts", "cashews", "pecans", "brazil nuts",
            "pistachios", "macadamia nuts", "pine nuts", "chestnuts", "pecan nuts", "peanut butter", "pecan"
        ],
        "vegan": [
            "beef", "steak", "pork", "bacon", "ham", "lamb", "mutton", "veal", "chicken", "turkey", "duck", "goose",
            "quail", "fish", "shrimp", "prawns", "crab", "lobster", "oysters", "mussels", "scallops", "clams",
            "squid", "octopus", "milk", "cheese", "butter", "cream", "yogurt", "ice cream", "gelato", "custard",
            "eggs", "mayonnaise", "honey", "gelatin", "lard", "suet", "tallow", "whey", "casein", "rennet",
            "collagen", "albumen", "isinglass"
        ],
        "vegetarian": [
            "beef", "steak", "pork", "bacon", "ham", "lamb", "mutton", "veal", "chicken", "turkey", "duck",
            "goose", "quail", "fish", "shrimp", "prawns", "crab", "lobster", "oysters", "mussels", "scallops",
            "clams", "squid", "octopus", "gelatin", "lard", "suet", "tallow", "rennet", "collagen", "isinglass"
        ],
        "gluten-free": [
            "wheat", "spelt", "kamut", "emmer", "einkorn", "farro", "barley", "rye", "triticale", "malt",
            "brewer's yeast", "wheat starch", "wheat bran", "wheat germ", "couscous", "bulgur", "seitan",
            "farina", "graham flour", "durum", "semolina"
        ],
        "dairy-free": [
            "milk", "cream", "butter", "cheese", "yogurt", "ice cream", "gelato", "custard", "whey",
            "casein", "lactose", "ghee", "sour cream", "kefir", "curds"
        ],
        "egg-free": [
            "eggs", "egg whites", "egg yolks", "egg powder", "egg solids", "egg substitutes", "albumin",
            "lysozyme", "ovalbumin", "ovoglobulin", "ovomucin", "ovomucoid", "ovotransferrin", "silici albuminate"
        ],
        "soy-free": [
            "soybeans", "soy milk", "soy sauce", "soy lecithin", "soy protein", "soy flour", "tofu", "tempeh",
            "miso", "edamame", "soybean oil", "tamari", "soy sprouts", "soy cheese", "soy yogurt"
        ],
        "shellfish-free": [
            "shrimp", "prawns", "lobster", "crab", "crayfish", "crawfish", "langoustine", "scampi", "krill",
            "mussels", "oysters", "scallops", "clams", "cockles", "abalone", "geoduck", "sea cucumber"
        ],
        "fish-free": [
            "anchovies", "bass", "catfish", "cod", "flounder", "haddock", "hake", "halibut", "herring",
            "mahi mahi", "marlin", "monkfish", "perch", "pike", "pollock", "salmon", "sardines", "snapper",
            "sole", "swordfish", "tilapia", "trout", "tuna", "walleye"
        ],
        "paleo": [
            "grains", "legumes", "beans", "peanuts", "lentils", "peas", "soy", "dairy", "refined sugar",
            "processed foods", "potatoes", "refined vegetable oils", "salt", "artificial sweeteners"
        ],
        "keto": [
            "sugar", "syrups", "sweeteners", "grains", "wheat", "rice", "pasta", "bread", "high-carb fruits",
            "apples", "bananas", "oranges", "tubers", "potatoes", "yams", "sweetened yogurts", "honey",
            "smoothies", "juice", "starchy vegetables", "corn", "peas"
        ]
        // Add more categories and ingredients as necessary
    ]
    
    private init() {}
}
