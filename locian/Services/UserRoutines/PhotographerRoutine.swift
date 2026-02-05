import Foundation
import Combine

struct PhotographerRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Studio", "Editing Desk", "Bedroom", "Darkroom", "Late Edit", "Rendering", "Exporting Files", "Quiet Room"],
            1: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Recharging", "Silence", "Dark Room", "Pillow"],
            2: ["Bedroom", "Lying in Bed", "Sleeping", "Dreaming", "Deep Sleep", "Resting", "Stillness", "Comfort"],
            3: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Dreaming", "Quiet", "Heavy Sleep", "Blanket"],
            4: ["Bedroom", "Lying in Bed", "Sunrise Prep", "Car", "Loading Gear", "Camera Bag", "Tripod", "Coffee To-Go"],
            5: ["Location Shoot", "Hilltop", "Beach", "City Street", "Golden Hour", "Checking Light", "Setting Up", "Changing Lens"],
            6: ["Location Shoot", "Park", "Sunrise Spot", "Cafe", "Action Shot", "Portrait", "Natural Light", "Raw Files"],
            7: ["Cafe", "Eating Breakfast", "Reviewing Shots", "Studio", "Card Reader", "Using Laptop", "Eating Croissant", "Drinking Espresso"],
            8: ["Studio", "Editing Desk", "Client Call", "Equipment Room", "Lightroom", "Photoshop", "Emailing", "Booking"],
            9: ["Studio", "Set", "Lighting Setup", "Dressing Room", "Backdrop", "Softbox", "Reflector", "Model"],
            10: ["Studio", "Shooting Area", "Client Lounge", "Meeting", "Posing", "Directing", "Flash", "Clicking"],
            11: ["Studio", "Shooting Area", "Prop Room", "Desk", "Styling", "Reviewing", "Tethered Shooting", "Monitor"],
            12: ["Studio Kitchen", "Cafe", "Lunch Meeting", "Park", "Eating Sandwich", "Discussing", "Contract", "Planning"],
            13: ["Location Shoot", "City Street", "Client Office", "Event Space", "Scouting", "Architecture", "Travel", "Gear"],
            14: ["Location Shoot", "Outdoor Park", "Architecture", "Studio", "Composing", "Angle", "Reflection", "Shadow"],
            15: ["Studio", "Editing Desk", "Post-Processing", "Client Review", "Color Grading", "Retouching", "Selecting", "Exporting"],
            16: ["Studio", "Cleaning Equipment", "Packing", "Desk", "Wiping Lens", "Charging Battery", "Organizing", "Invoice"],
            17: ["Golden Hour Spot", "Rooftop", "City Park", "Beach", "Sunset", "Silhouette", "Landscape", "Tripod"],
            18: ["Location Shoot", "Sunset View", "Car", "Commuting", "Packing Up", "Driving", "Music", "Home"],
            19: ["Home", "Kitchen", "Living Room", "Dinner", "Cooking", "Relaxing", "Family", "TV"],
            20: ["Home Office", "Editing", "Living Room", "Relaxing", "Portfolio", "Website", "Social Media", "Couch"],
            21: ["Living Room", "Portfolio Review", "Bedroom", "Reading", "Photo Book", "Inspiration", "Art", "Bed"],
            22: ["Bedroom", "Bathroom", "Lying in Bed", "Social Media", "Instagram", "Likes", "Comments", "Sleeping"],
            23: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Darkness", "Silence", "Dreaming", "Recharging"]
        ]
    }
}
