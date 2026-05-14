import SwiftUI

struct Mood: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let soundName: String
    let isPremium: Bool
    let cost: Int
}

@available(iOS 15.0, *)
struct MoodSelectorView: View {
    @AppStorage("selectedMoodImage") var selectedMoodImage: String = "mood_default"
    @AppStorage("selectedMoodSound") var selectedMoodSound: String = "ambient_library"
    @ObservedObject var audioManager = AudioManager.shared
    @ObservedObject var coinManager = CoinManager.shared
    
    let freeMoods = [
        Mood(name: "Quiet Library", imageName: "mood_1", soundName: "ambient_library", isPremium: false, cost: 0),
        Mood(name: "Summer Morning", imageName: "mood_2", soundName: "ambient_birds", isPremium: false, cost: 0),
        Mood(name: "Rainy Cafe", imageName: "mood_3", soundName: "ambient_rain", isPremium: false, cost: 0),
        Mood(name: "Starry Night", imageName: "mood_4", soundName: "ambient_night", isPremium: false, cost: 0),
        Mood(name: "Autumn Forest", imageName: "mood_5", soundName: "ambient_wind", isPremium: false, cost: 0),
        Mood(name: "Lakeside Reflection", imageName: "mood_6", soundName: "ambient_lake", isPremium: false, cost: 0),
        Mood(name: "Urban Rooftop", imageName: "mood_7", soundName: "ambient_city", isPremium: false, cost: 0),
        Mood(name: "Winter Cabin", imageName: "mood_8", soundName: "ambient_fire", isPremium: false, cost: 0),
        Mood(name: "Art Gallery", imageName: "mood_9", soundName: "ambient_gallery", isPremium: false, cost: 0),
        Mood(name: "Tropical Beach", imageName: "mood_10", soundName: "ambient_waves", isPremium: false, cost: 0)
    ]
    
    let premiumMoods = [
        Mood(name: "Cyberpunk City", imageName: "mood_4", soundName: "ambient_city", isPremium: true, cost: 20),
        Mood(name: "Deep Sea", imageName: "mood_6", soundName: "ambient_lake", isPremium: true, cost: 20),
        Mood(name: "Zen Garden", imageName: "mood_2", soundName: "ambient_birds", isPremium: true, cost: 20)
    ]
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Free Moods Section
                    Text("Free Moods")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(freeMoods) { mood in
                            moodCard(mood: mood)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Premium Moods Section
                    HStack {
                        Text("Premium Moods")
                            .font(.headline)
                        Spacer()
                        Label("\(coinManager.balance)", systemImage: "bitcoinsign.circle.fill")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(premiumMoods) { mood in
                            moodCard(mood: mood)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Visual Inspiration")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Trilo Store"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    @ViewBuilder
    func moodCard(mood: Mood) -> some View {
        let isUnlocked = !mood.isPremium || coinManager.isUnlocked(mood.imageName)
        
        VStack {
            ZStack(alignment: .topTrailing) {
                Image(mood.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 160, height: 220)
                    .clipped()
                    .cornerRadius(15)
                    .blur(radius: isUnlocked ? 0 : 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(selectedMoodImage == mood.imageName ? Color.blue : Color.clear, lineWidth: 4)
                    )
                    .onTapGesture {
                        if isUnlocked {
                            selectedMoodImage = mood.imageName
                            selectedMoodSound = mood.soundName
                        }
                    }
                
                if !isUnlocked {
                    VStack {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                        Text("\(mood.cost) Coins")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(10)
                    }
                    .frame(width: 160, height: 220)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(15)
                }
                
                if selectedMoodImage == mood.imageName {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .background(Color.white.clipShape(Circle()))
                        .padding(8)
                }
            }
            
            Text(mood.name)
                .font(.system(size: 14, weight: .medium))
                .padding(.top, 4)
            
            if isUnlocked {
                Button(action: {
                    if audioManager.currentSound == mood.soundName {
                        audioManager.toggle()
                    } else {
                        audioManager.play(sound: mood.soundName)
                    }
                }) {
                    HStack {
                        Image(systemName: (audioManager.currentSound == mood.soundName && audioManager.isPlaying) ? "pause.circle.fill" : "play.circle.fill")
                        Text((audioManager.currentSound == mood.soundName && audioManager.isPlaying) ? "Pause Sound" : "Listen")
                    }
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
            } else {
                Button(action: {
                    if coinManager.spendCoins(mood.cost) {
                        coinManager.unlockMood(mood.imageName)
                        alertMessage = "Successfully unlocked \(mood.name)!"
                        showAlert = true
                    } else {
                        alertMessage = "Not enough coins. Please top up in Settings."
                        showAlert = true
                    }
                }) {
                    Text("Unlock")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
            }
        }
    }
}
