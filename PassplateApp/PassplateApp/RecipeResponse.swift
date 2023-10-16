//
//  RecipeResponse.swift
//  PassplateApp
//
//  Created by Summer Ely on 10/16/23.
//

import Foundation

struct RecipeResponse: Decodable {
    let meals: [FullRecipe]
}
