//
//  UploadedRecipe.swift
//  PassplateApp
//
//  Created by Annie Prosper on 12/3/23.
//

import Foundation

struct UploadedRecipe: Decodable {
    let recipeName: String
    let recipeImage: String
    let recipeCountryOfOrigin: String
    let recipeInstructions: String
    let recipeIngredients: String
}
