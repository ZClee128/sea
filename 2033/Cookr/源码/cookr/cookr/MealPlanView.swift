import SwiftUI

@available(iOS 14.0, *)
struct MealPlanView: View {
    let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    @State private var plan: [String: Recipe] = [:]
    @State private var showingPicker: String? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tap a day to assign a recipe")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    ForEach(weekDays, id: \.self) { day in
                        Button(action: { showingPicker = day }) {
                            HStack(spacing: 14) {
                                Text(day)
                                    .font(.headline)
                                    .frame(width: 44, alignment: .leading)
                                    .foregroundColor(.primary)
                                
                                if let recipe = plan[day] {
                                    Image(recipe.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 56, height: 56)
                                        .cornerRadius(10)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(recipe.title)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Text(recipe.category)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button(action: { plan.removeValue(forKey: day) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    Text("+ Add a recipe")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Shopping list summary
                    if !plan.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("This Week's Ingredients")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top, 20)
                            
                            let allIngredients = plan.values.flatMap { $0.ingredients }
                            ForEach(Array(Set(allIngredients)).sorted(), id: \.self) { ing in
                                HStack {
                                    Image(systemName: "cart.badge.plus")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    Text(ing)
                                        .font(.subheadline)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Meal Plan")
            .sheet(item: Binding(
                get: { showingPicker.map { PickerDay(day: $0) } },
                set: { showingPicker = $0?.day }
            )) { item in
                RecipePickerSheet(day: item.day, onSelect: { recipe in
                    plan[item.day] = recipe
                    showingPicker = nil
                })
            }
        }
    }
}

struct PickerDay: Identifiable {
    let id = UUID()
    let day: String
}

@available(iOS 14.0, *)
struct RecipePickerSheet: View {
    let day: String
    let onSelect: (Recipe) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(RecipeData.samples) { recipe in
                Button(action: { onSelect(recipe) }) {
                    HStack {
                        Image(recipe.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                        VStack(alignment: .leading) {
                            Text(recipe.title).fontWeight(.semibold)
                            Text(recipe.category).font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Choose for \(day)")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct MealPlanView_Previews: PreviewProvider {
    static var previews: some View { if #available(iOS 14.0, *) {
        MealPlanView()
    } else {
        // Fallback on earlier versions
    } }
}
