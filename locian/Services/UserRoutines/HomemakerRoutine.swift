import Foundation
import Combine

struct HomemakerRoutine: ProfessionRoutine {
    static var data: [Int: [String]] {
        return [
            0: ["Bedroom", "Lying in Bed", "Living Room", "Checking Locks", "Thermostat", "Drinking Water", "Quiet House", "Baby Monitor"],
            1: ["Bedroom", "Lying in Bed", "Sleeping", "Quiet House", "Head on Pillow", "Under Blanket", "Dark Room", "Resting"],
            2: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Sleeping", "Silence", "Recharging", "Stillness"],
            3: ["Bedroom", "Lying in Bed", "Deep Sleep", "Sleeping", "Comfortable Bed", "Warm Bed", "Night", "Peace"],
            4: ["Bedroom", "Lying in Bed", "Deep Sleep", "Resting", "Early Birds", "Turning Over", "Snoozing", "Sleeping"],
            5: ["Kitchen", "Making Coffee", "Living Room", "Early Quiet", "Yoga Mat", "Journaling", "Sunrise", "Drinking Tea"],
            6: ["Kitchen", "Prep Breakfast", "Kids Room", "Bathroom", "Pancakes", "Toast", "Packing Lunch", "Hairbrush"],
            7: ["Kitchen", "Dining Table", "School Bus Stop", "Garage", "Car", "Backpack", "Shoes", "Coats"],
            8: ["Kitchen", "Cleaning Up", "Laundry Room", "Living Room", "Loading Dishwasher", "Vacuuming", "Washer", "Dryer"],
            9: ["Grocery Store", "Market", "Car", "Running Errands", "Post Office", "Bank", "Dry Cleaners", "Pharmacy"],
            10: ["Home", "Living Room", "Garden", "Cleaning", "Dusting", "Watering Plants", "Podcast", "Music"],
            11: ["Kitchen", "Meal Prep", "Laundry Room", "Home Office", "Folding Clothes", "Recipe Book", "Chopping", "Organizing"],
            12: ["Kitchen", "Eating Lunch", "Patio", "Living Room", "Eating Salad", "Sandwich", "Phone Call", "Friend"],
            13: ["Living Room", "Resting", "Reading Nook", "Garden", "Reading Book", "Tea", "Napping", "Sunlight"],
            14: ["Home Office", "Paying Bills", "Phone Call", "Kitchen", "Budgeting", "Scheduling", "Calendar", "Notes"],
            15: ["School Bus Stop", "Kitchen", "Prep Snack", "Living Room", "Cookies", "Eating Fruit", "Helping Homework", "Unpacking Bag"],
            16: ["Living Room", "Homework Area", "Kitchen", "Playroom", "Lego", "Drawing", "Reading", "Tutor"],
            17: ["Kitchen", "Prep Dinner", "Garden", "Garage", "Oven", "Stove", "Adding Spices", "Stirring Pot"],
            18: ["Dining Room", "Dinner Table", "Kitchen", "Cleaning Up", "Placemats", "Family Meal", "Conversation", "Dishwasher"],
            19: ["Living Room", "Family Time", "TV Room", "Bath Time", "Bubbles", "Pajamas", "Reading Storybook", "Cuddling"],
            20: ["Kids Bedroom", "Story Time", "Living Room", "Relaxing", "Nightlight", "Singing Lullaby", "Door Ajar", "Drinking Wine"],
            21: ["Living Room", "Watching TV", "Bedroom", "Reading", "Netflix", "Partner", "Chatting", "Sofa"],
            22: ["Bedroom", "Bathroom", "Lying in Bed", "Planning", "To-Do List", "Washing Face", "Lotion", "Pillow"],
            23: ["Bedroom", "Lying in Bed", "Sleeping", "Resting", "Lights Out", "Charging Phone", "Dark Room", "Falling Asleep"]
        ]
    }
}
