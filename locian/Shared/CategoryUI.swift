//
//  CategoryUI.swift
//  locian
//
//  Centralized mapping for place categories to UI elements (Icons, Colors, etc.)
//

import SwiftUI

struct CategoryUI {
    
    /// Maps a place ID or category name to a standard SF Symbol
    static func icon(for category: String) -> String {
        let normalized = category.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch normalized {
        case "airport":
            return "airplane"
        case "bakery":
            return "birthday.cake.fill"
        case "bar_pub":
            return "wineglass.fill"
        case "beach":
            return "beach.umbrella.fill"
        case "bus_stop":
            return "bus.fill"
        case "cafe":
            return "cup.and.saucer.fill"
        case "clinic":
            return "stethoscope"
        case "coaching_center":
            return "person.2.fill"
        case "fast_food_outlet":
            return "flame.fill"
        case "food_court":
            return "fork.knife"
        case "gym":
            return "dumbbell.fill"
        case "home":
            return "house.fill"
        case "hospital":
            return "cross.case.fill"
        case "library":
            return "books.vertical.fill"
        case "metro_station":
            return "tram.fill"
        case "movie_theatre":
            return "popcorn.fill"
        case "office":
            return "building.2.fill"
        case "park":
            return "tree.fill"
        case "pharmacy":
            return "pill.fill"
        case "railway_station":
            return "train.side.front.car"
        case "restaurant":
            return "fork.knife"
        case "school":
            return "pencil.and.ruler.fill"
        case "shopping_mall":
            return "bag.fill"
        case "supermarket":
            return "cart.fill"
        case "university":
            return "graduationcap.fill"
        case "yoga_studio":
            return "figure.mind.and.body"
        default:
            return "mappin.and.ellipse"
        }
    }
}
