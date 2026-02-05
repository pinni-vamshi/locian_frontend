import Foundation

struct ChefRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Restaurant", "Bar", "Kitchen", "Home", "Cleaning Up", "Staff Drink", "Taxi", "Smoking"],
            1: ["Bedroom", "Lying in Bed", "Snacking", "Taking Shower", "Sofa", "Watching TV", "Winding Down", "Quiet Room"],
            2: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Deep Sleep", "Dark Room", "Pillow", "Silence"],
            3: ["Bedroom", "Lying in Bed", "Deep Sleep", "Sleeping", "Recharging", "Stillness", "Comfort", "Resting"],
            4: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Sleeping", "Quiet", "Heavy Sleep", "Blanket"],
            5: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Sleeping", "Sleeping In", "Quiet House", "Curtains Closed"],
            6: ["Bedroom", "Lying in Bed", "Waking Up", "Coffee", "Taking Shower", "Breakfast", "News", "Checking Phone"],
            7: ["Kitchen", "Breakfast", "Recipe Planning", "Garden", "Drinking Espresso", "Toast", "Menu Planning", "Calling Supplier"],
            8: ["Market", "Produce Stall", "Butcher", "Fishmonger", "Farmers Market", "Chatting Vendor", "Coffee Shop", "Tasting"],
            9: ["Restaurant Kitchen", "Prep Station", "Office", "Storage", "Sharpening Knives", "Wearing Apron", "Team Huddle", "Delivery Truck"],
            10: ["Restaurant Kitchen", "Prep Area", "Stove", "Walk-in Fridge", "Chopping", "Sous Vide", "Oven", "Making Sauce"],
            11: ["Restaurant Kitchen", "Line Check", "Staff Meal", "Meeting", "Tasting Food", "Plating Test", "Updating Menu", "Reservation List"],
            12: ["Restaurant Kitchen", "Pass", "Line", "Service", "Lunch Rush", "Printing Tickets", "Expediting", "Waitstaff"],
            13: ["Restaurant Kitchen", "Line", "Dish Pit", "Office", "Cleaning", "Checking Inventory", "Ordering", "Short Break"],
            14: ["Restaurant", "Break Area", "Office", "Planning", "Napping", "Phone Call", "Smoking", "Coffee"],
            15: ["Restaurant Kitchen", "Prep Station", "Delivery Check", "Storage", "Mise en Place", "Dinner Prep", "Sauce Making", "Butchery"],
            16: ["Restaurant Kitchen", "Line Setup", "Briefing", "Pass", "Specials", "Team Meeting", "Checking Station", "Clean Towel"],
            17: ["Restaurant Kitchen", "Service", "Line", "Stove", "Early Bird", "Appetizer Station", "Grill", "Sautéing"],
            18: ["Restaurant Kitchen", "Pass", "Heat Lamp", "Plating", "Dinner Rush", "Firing Order", "Garnishing", "Chef's Table"],
            19: ["Restaurant Kitchen", "Rush", "Line", "Pass", "Full Board", "High Heat", "Team Flow", "Focusing"],
            20: ["Restaurant Kitchen", "Service", "Plating", "Pass", "Main Course", "Dessert Station", "Expediting", "Checking Quality"],
            21: ["Restaurant Kitchen", "Cleanup", "Office", "Bar", "Scrubbing", "Labeling", "Inventory", "Locking Up"],
            22: ["Restaurant", "Bar", "Staff Drink", "Commuting", "Drinking Beer", "Chatting", "Taxi", "Walking Home"],
            23: ["Home", "Living Room", "Kitchen", "Bedroom", "Taking Shower", "Relaxing", "Late Snack", "Sleeping"]
        ]
    }
}
