//
//  ExploreView.swift
//  melonShare
//
//  Created by zclee on 2026/5/19.
//

import SwiftUI

struct ExploreView: View {
    @ObservedObject private var watchManager = WatchlistManager.shared
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    let categories = ["All", "CEO Romance", "Action & Revenge", "Time Travel & Retro", "Urban Fantasy & Power"]
    
    // Filtered dramas based on search text and category selection
    var filteredDramas: [Drama] {
        DramaDatabase.list.filter { drama in
            let matchesSearch = searchText.isEmpty || drama.title.localizedCaseInsensitiveContains(searchText) || drama.summary.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == "All" || drama.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGray.edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Header
                        ViewHeader(
                            title: "Curated Amway",
                            subtitle: "Melon Recommendations"
                        )
                        
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Theme.textLight)
                            TextField("Search dramas, plots, reviews...", text: $searchText)
                                .font(.body)
                                .foregroundColor(Theme.textDark)
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Theme.textLight)
                                }
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.borderGray, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        // Categories Scroll
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(categories, id: \.self) { category in
                                    CategoryPill(
                                        title: category,
                                        isSelected: selectedCategory == category,
                                        action: {
                                            selectedCategory = category
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 4)
                        }
                        
                        // Dramas List
                        if filteredDramas.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "sparkles.tv")
                                    .font(.system(size: 48))
                                    .foregroundColor(Theme.textLight.opacity(0.6))
                                Text("No dramas found")
                                    .font(.headline)
                                    .foregroundColor(Theme.textMedium)
                                Text("Try adjusting your search keywords or categories.")
                                    .font(.caption)
                                    .foregroundColor(Theme.textLight)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 80)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(filteredDramas) { drama in
                                    NavigationLink(destination: DramaDetailView(drama: drama)) {
                                        ExploreDramaCard(drama: drama)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 80)
                }
            }
            .background(Theme.backgroundGray)
            .simultaneousGesture(
                TapGesture().onEnded {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            )
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.light)
    }
}

// Category selection pill
struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .bold()
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Theme.accentGradient : LinearGradient(colors: [Color.white], startPoint: .top, endPoint: .bottom))
                .foregroundColor(isSelected ? .white : Theme.textMedium)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Theme.borderGray, lineWidth: 1)
                )
                .shadow(color: isSelected ? Theme.accentPink.opacity(0.2) : Color.clear, radius: 6, x: 0, y: 3)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Beautiful Drama Card for Explore Screen
struct ExploreDramaCard: View {
    let drama: Drama
    @ObservedObject private var watchManager = WatchlistManager.shared
    
    var body: some View {
        GlassCard(padding: 12) {
            HStack(spacing: 14) {
                // Gradient Icon Cover
                RoundedRectangle(cornerRadius: 12)
                    .fill(drama.gradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: drama.iconName)
                            .font(.title)
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                    )
                
                // Description details
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        Text(drama.title)
                            .font(.headline)
                            .bold()
                            .foregroundColor(Theme.textDark)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Rating
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text(String(format: "%.1f", drama.rating))
                                .font(.caption2)
                                .bold()
                                .foregroundColor(Theme.textDark)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Text(drama.category)
                            .font(.caption2)
                            .bold()
                            .foregroundColor(Theme.primaryPeach)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(Theme.primaryPeach.opacity(0.1))
                            .cornerRadius(6)
                        
                        if drama.isPremium {
                            HStack(spacing: 3) {
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.orange)
                                Text("\(drama.coinCost) Coins")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(6)
                        }
                    }
                    
                    Text(drama.summary)
                        .font(.caption)
                        .foregroundColor(Theme.textMedium)
                        .lineLimit(2)
                }
            }
        }
    }
}

// MARK: - Drama Detail View
struct DramaDetailView: View {
    let drama: Drama
    @ObservedObject private var watchManager = WatchlistManager.shared
    @ObservedObject private var iapManager = IAPManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingReviewSheet = false
    @State private var showingAddWatchlistAlert = false
    @State private var watchlistStatus = "Watching"
    @State private var showingCoinStore = false
    @State private var selectedReviewForReport: DramaReview? = nil
    
    var body: some View {
        ZStack {
            Theme.backgroundGray.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Parallax/Gradient Top Header
                    ZStack(alignment: .bottomLeading) {
                        drama.gradient
                            .frame(height: 200)
                        
                        // Overlay back button
                        VStack {
                            HStack {
                                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                    Image(systemName: "chevron.left")
                                        .font(.headline)
                                        .padding(12)
                                        .background(Color.white.opacity(0.85))
                                        .foregroundColor(Theme.textDark)
                                        .clipShape(Circle())
                                }
                                Spacer()
                            }
                            .padding(.top, 44)
                            .padding(.horizontal, 20)
                            Spacer()
                        }
                        
                        // Glassmorphic title details
                        HStack(spacing: 16) {
                            // Mini Cover
                            RoundedRectangle(cornerRadius: 14)
                                .fill(LinearGradient(colors: [.white.opacity(0.3), .white.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Image(systemName: drama.iconName)
                                        .font(.title)
                                        .foregroundColor(.white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(drama.title)
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                                
                                HStack(spacing: 8) {
                                    Text(drama.category)
                                        .font(.caption2)
                                        .bold()
                                        .foregroundColor(.white)
                                        .padding(.vertical, 2)
                                        .padding(.horizontal, 8)
                                        .background(Color.white.opacity(0.25))
                                        .cornerRadius(6)
                                    
                                    Text("\(drama.episodesCount) Episodes")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.85))
                                }
                            }
                        }
                        .padding(20)
                    }
                    
                    if drama.isPremium && !iapManager.isUnlocked(dramaId: drama.id.uuidString) {
                        // Premium Lock Card
                        VStack(spacing: 20) {
                            GlassCard(padding: 24) {
                                VStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.orange.opacity(0.1))
                                            .frame(width: 80, height: 80)
                                        
                                        Image(systemName: "lock.shield.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.orange)
                                    }
                                    .padding(.top, 10)
                                    
                                    VStack(spacing: 8) {
                                        Text("Premium Amway Recommendation Locked")
                                            .font(.headline)
                                            .bold()
                                            .foregroundColor(Theme.textDark)
                                            .multilineTextAlignment(.center)
                                        
                                        Text("This exclusive Amway review details strategic plot twists, character ratings, and advanced drama tracks. Spend Melon Coins to unlock permanently.")
                                            .font(.caption)
                                            .foregroundColor(Theme.textMedium)
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(4)
                                    }
                                    
                                    Divider()
                                    
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Unlock Price")
                                                .font(.caption2)
                                                .foregroundColor(Theme.textLight)
                                            HStack(spacing: 4) {
                                                Image(systemName: "bitcoinsign.circle.fill")
                                                    .foregroundColor(.orange)
                                                Text("\(drama.coinCost) Coins")
                                                    .font(.headline)
                                                    .bold()
                                                    .foregroundColor(Theme.primaryPeach)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("Your Balance")
                                                .font(.caption2)
                                                .foregroundColor(Theme.textLight)
                                            HStack(spacing: 4) {
                                                Image(systemName: "bitcoinsign.circle.fill")
                                                    .foregroundColor(.orange)
                                                Text("\(iapManager.melonCoins) Coins")
                                                    .font(.headline)
                                                    .bold()
                                                    .foregroundColor(Theme.textDark)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    
                                    if iapManager.melonCoins >= drama.coinCost {
                                        Button(action: {
                                            let success = iapManager.spendCoins(amount: drama.coinCost, dramaId: drama.id.uuidString)
                                            if success {
                                                let generator = UINotificationFeedbackGenerator()
                                                generator.notificationOccurred(.success)
                                            }
                                        }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "lock.open.fill")
                                                Text("Unlock for \(drama.coinCost) Coins")
                                                    .bold()
                                            }
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Theme.accentGradient)
                                            .cornerRadius(12)
                                            .shadow(color: Theme.accentPink.opacity(0.3), radius: 6, x: 0, y: 3)
                                        }
                                    } else {
                                        VStack(spacing: 12) {
                                            Text("Insufficient Melon Coins balance")
                                                .font(.caption2)
                                                .foregroundColor(.red)
                                                .bold()
                                            
                                            Button(action: {
                                                showingCoinStore = true
                                            }) {
                                                HStack(spacing: 8) {
                                                    Image(systemName: "cart.fill")
                                                    Text("Recharge / Buy Coins")
                                                        .bold()
                                                }
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.orange)
                                                .cornerRadius(12)
                                                .shadow(color: Color.orange.opacity(0.3), radius: 6, x: 0, y: 3)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(20)
                    } else {
                        VStack(alignment: .leading, spacing: 20) {
                        // Quick Action / Status indicator
                        GlassCard(padding: 14) {
                            HStack {
                                if watchManager.isTracking(drama.id), let tracked = watchManager.getTrackedItem(drama.id) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("TRACKING IN PROGRESS")
                                            .font(.caption2)
                                            .bold()
                                            .foregroundColor(Theme.primaryPeach)
                                            .tracking(1)
                                        Text("Episode \(tracked.currentEpisode) / \(tracked.totalEpisodes) (\(tracked.status))")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(Theme.textDark)
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("NOT TRACKED YET")
                                            .font(.caption2)
                                            .bold()
                                            .foregroundColor(Theme.textLight)
                                            .tracking(1)
                                        Text("Add to watchlist to record progress")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.textMedium)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: { showingAddWatchlistAlert = true }) {
                                    Text(watchManager.isTracking(drama.id) ? "Update" : "Track")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(Theme.accentGradient)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        
                        // Summary Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Story Plotline")
                                .font(.headline)
                                .foregroundColor(Theme.textDark)
                            Text(drama.summary)
                                .font(.body)
                                .foregroundColor(Theme.textMedium)
                                .lineSpacing(4)
                        }
                        
                        // Why We Recommend
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Melon Amway Review")
                                .font(.headline)
                                .foregroundColor(Theme.textDark)
                            
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "quote.opening")
                                    .font(.headline)
                                    .foregroundColor(Theme.primaryPeach)
                                
                                Text(drama.recommendationReason)
                                    .font(.subheadline)
                                    .italic()
                                    .foregroundColor(Theme.textMedium)
                                    .lineSpacing(4)
                            }
                            .padding(14)
                            .background(Theme.champagne.opacity(0.6))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Theme.primaryPeach.opacity(0.15), lineWidth: 1)
                            )
                        }
                        
                        // Characters Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Key Roles & Characters")
                                .font(.headline)
                                .foregroundColor(Theme.textDark)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(drama.characters) { character in
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                Text(character.name)
                                                    .font(.subheadline)
                                                    .bold()
                                                    .foregroundColor(Theme.textDark)
                                                Spacer()
                                                Text(character.role)
                                                    .font(.caption2)
                                                    .bold()
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 2)
                                                    .padding(.horizontal, 6)
                                                    .background(character.role == "Protagonist" ? Theme.primaryPeach : (character.role == "Male Lead" ? Color.blue.opacity(0.7) : Theme.textLight))
                                                    .cornerRadius(4)
                                            }
                                            
                                            Text(character.description)
                                                .font(.caption)
                                                .foregroundColor(Theme.textMedium)
                                                .lineLimit(3)
                                        }
                                        .frame(width: 190, height: 90)
                                        .padding(12)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Theme.borderGray, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Reviews Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("User Feedbacks (\(watchManager.getAllReviews(for: drama).count))")
                                    .font(.headline)
                                    .foregroundColor(Theme.textDark)
                                
                                Spacer()
                                
                                Button(action: { showingReviewSheet = true }) {
                                     HStack(spacing: 4) {
                                         Image(systemName: "plus")
                                         Text("Write")
                                             .bold()
                                     }
                                     .font(.caption)
                                     .foregroundColor(Theme.primaryPeach)
                                 }
                            }
                            
                            ForEach(watchManager.getAllReviews(for: drama)) { review in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(review.username)
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(Theme.textDark)
                                        
                                        Spacer()
                                        
                                        // Stars Display
                                        HStack(spacing: 2) {
                                            ForEach(1...5, id: \.self) { index in
                                                Image(systemName: "star.fill")
                                                    .font(.caption2)
                                                    .foregroundColor(index <= review.rating ? .orange : Theme.textLight.opacity(0.3))
                                            }
                                        }
                                    }
                                    
                                    Text(review.content)
                                        .font(.caption)
                                        .foregroundColor(Theme.textMedium)
                                        .lineSpacing(2)
                                    
                                    HStack {
                                        Text(review.date)
                                            .font(.system(size: 8))
                                            .foregroundColor(Theme.textLight)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            selectedReviewForReport = review
                                        }) {
                                            HStack(spacing: 2) {
                                                Image(systemName: "exclamationmark.bubble.fill")
                                                Text("Report")
                                                    .font(.system(size: 8, weight: .bold))
                                            }
                                            .font(.system(size: 8))
                                            .foregroundColor(Theme.primaryPeach)
                                        }
                                    }
                                }
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Theme.borderGray, lineWidth: 1)
                                )
                            }
                        }
                        .sheet(item: $selectedReviewForReport) { review in
                            ReportReviewSheet(review: review, isPresented: Binding(
                                get: { selectedReviewForReport != nil },
                                set: { newValue in
                                    if !newValue {
                                        selectedReviewForReport = nil
                                    }
                                }
                            ))
                        }
                    }
                    .padding(20)
                    
                    } // End of else block
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingReviewSheet) {
            WriteReviewSheet(drama: drama, isPresented: $showingReviewSheet)
        }
        .sheet(isPresented: $showingAddWatchlistAlert) {
            AddWatchlistSheet(drama: drama, isPresented: $showingAddWatchlistAlert)
        }
        .sheet(isPresented: $showingCoinStore) {
            CoinStoreSheet(isPresented: $showingCoinStore)
        }
    }
}

// Add Watchlist Action Sheet
struct AddWatchlistSheet: View {
    let drama: Drama
    @Binding var isPresented: Bool
    @ObservedObject private var watchManager = WatchlistManager.shared
    
    @State private var selectedStatus = "Watching"
    @State private var episodeCount = 1
    
    var body: some View {
        // iOS 13 Custom Binding to intercept Picker changes (avoiding iOS 14 .onChange)
        let statusBinding = Binding<String>(
            get: { self.selectedStatus },
            set: { newValue in
                self.selectedStatus = newValue
                if newValue == "Completed" {
                    self.episodeCount = self.drama.episodesCount
                }
            }
        )
        
        // iOS 13 Custom Binding to intercept Stepper changes (avoiding iOS 14 .onChange)
        let episodeBinding = Binding<Int>(
            get: { self.episodeCount },
            set: { newValue in
                self.episodeCount = newValue
                if newValue == self.drama.episodesCount {
                    self.selectedStatus = "Completed"
                } else if self.selectedStatus == "Completed" && newValue < self.drama.episodesCount {
                    self.selectedStatus = "Watching"
                }
            }
        )
        
        return NavigationView {
            Form {
                Section(header: Text("Tracking Status")) {
                    Picker("Status", selection: statusBinding) {
                        Text("Watching").tag("Watching")
                        Text("Plan to Watch").tag("Plan to Watch")
                        Text("Completed").tag("Completed")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Progress (Episodes)")) {
                    HStack {
                        Text("Currently On")
                        Spacer()
                        Stepper("Episode \(episodeCount)", value: episodeBinding, in: 1...drama.episodesCount)
                    }
                }
                
                Section {
                    Button(action: {
                        watchManager.track(drama, status: selectedStatus, episode: episodeCount)
                        isPresented = false
                    }) {
                        Text("Save Tracker")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .background(Theme.accentGradient)
                            .cornerRadius(10)
                    }
                    
                    if watchManager.isTracking(drama.id) {
                        Button(action: {
                            watchManager.removeFromWatchlist(drama.id)
                            isPresented = false
                        }) {
                            Text("Remove from Watchlist")
                                .bold()
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationBarTitle("Track Drama", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") { isPresented = false })
            .onAppear {
                if let item = watchManager.getTrackedItem(drama.id) {
                    selectedStatus = item.status
                    episodeCount = item.currentEpisode
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

// Write Comment/Review Sheet
struct WriteReviewSheet: View {
    let drama: Drama
    @Binding var isPresented: Bool
    @ObservedObject private var watchManager = WatchlistManager.shared
    
    @State private var nickname = ""
    @State private var selectedRating = 5
    @State private var content = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Author Nickname")) {
                    TextField("Enter your name...", text: $nickname)
                }
                
                Section(header: Text("Rating Scale")) {
                    HStack {
                        Text("Stars")
                        Spacer()
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: "star.fill")
                                .foregroundColor(index <= selectedRating ? .orange : Theme.textLight.opacity(0.3))
                                .onTapGesture {
                                    selectedRating = index
                                }
                        }
                    }
                }
                
                Section(header: Text("Review Message")) {
                    TextField("Review Description", text: $content)
                }
                
                Section {
                    Button(action: {
                        if content.isEmpty {
                            showError = true
                        } else {
                            watchManager.addReview(for: drama.id, username: nickname, rating: selectedRating, content: content)
                            isPresented = false
                        }
                    }) {
                        Text("Submit Review")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .background(Theme.accentGradient)
                            .cornerRadius(10)
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Missing Information"), message: Text("Please type a review message before submitting."), dismissButton: .default(Text("OK")))
            }
            .navigationBarTitle("Write Review", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") { isPresented = false })
        }
        .preferredColorScheme(.light)
    }
}

// Custom Report and Block UGC Content Sheet
struct ReportReviewSheet: View {
    let review: DramaReview
    @Binding var isPresented: Bool
    
    @State private var selectedReason = "Harassment or Hate Speech"
    @State private var extraDetails = ""
    @State private var isBlockingUser = false
    @State private var showingSuccessAlert = false
    
    let reasons = [
        "Harassment or Hate Speech",
        "Offensive or Vulgar Content",
        "Spam, Scams, or Advertising",
        "Intellectual Property Infringement",
        "Other Violations"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGray.edgesIgnoringSafeArea(.all)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Header info
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.shield.fill")
                                .font(.system(size: 44))
                                .foregroundColor(Theme.primaryPeach)
                            Text("Report Objectionable Content")
                                .font(.title3)
                                .bold()
                                .foregroundColor(Theme.textDark)
                            Text("Help us keep MelonShare reviews safe, secure, and respectful.")
                                .font(.caption)
                                .foregroundColor(Theme.textMedium)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                        
                        // Targeted Review Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("REPORTING USER FEEDBACK BY \(review.username.uppercased())")
                                .font(.caption2)
                                .bold()
                                .foregroundColor(Theme.textLight)
                                .tracking(1)
                            
                            Text("\"\(review.content)\"")
                                .font(.caption)
                                .italic()
                                .foregroundColor(Theme.textMedium)
                                .padding(12)
                                .background(Theme.borderGray.opacity(0.4))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                        
                        // Reason selector list
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select Reason")
                                .font(.headline)
                                .foregroundColor(Theme.textDark)
                            
                            ForEach(reasons, id: \.self) { reason in
                                Button(action: {
                                    selectedReason = reason
                                }) {
                                    HStack {
                                        Text(reason)
                                            .font(.subheadline)
                                            .foregroundColor(Theme.textDark)
                                        Spacer()
                                        if selectedReason == reason {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Theme.primaryPeach)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(Theme.textLight)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Optional comment textbox
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Additional Information (Optional)")
                                .font(.headline)
                                .foregroundColor(Theme.textDark)
                            
                            TextField("Describe why this content violates guidelines...", text: $extraDetails)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 20)
                        
                        // Block author switch
                        GlassCard(padding: 16) {
                            Toggle(isOn: $isBlockingUser) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Block this user permanently")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(Theme.textDark)
                                    Text("You will no longer see reviews or custom commentary from this user across the app.")
                                        .font(.caption2)
                                        .foregroundColor(Theme.textMedium)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Action Trigger
                        Button(action: {
                            showingSuccessAlert = true
                        }) {
                            Text("Submit Report")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Theme.accentGradient)
                                .cornerRadius(12)
                                .shadow(color: Theme.accentPink.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .alert(isPresented: $showingSuccessAlert) {
                            Alert(
                                title: Text("Report Submitted"),
                                message: Text("Thank you! Our moderation team will review this content within 24 hours. \(isBlockingUser ? "This user has been blocked." : "")"),
                                dismissButton: .default(Text("OK")) {
                                    if isBlockingUser {
                                        WatchlistManager.shared.blockUser(review.username)
                                    }
                                    WatchlistManager.shared.reportReview(review.id)
                                    isPresented = false
                                }
                            )
                        }
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationBarTitle("Report", displayMode: .inline)
            .navigationBarItems(leading: Button(action: { isPresented = false }) {
                Text("Cancel")
                    .foregroundColor(Theme.primaryPeach)
            })
        }
        .preferredColorScheme(.light)
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
