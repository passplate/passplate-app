//
//  Recipes.swift
//  PassplateApp
//
//  Created by Summer Ely on 10/11/23.
//

import Foundation

struct Recipes: Decodable {
    let count: Int?
    let next: URL?
    let previous: URL?
    let meals: [Recipe]
}
