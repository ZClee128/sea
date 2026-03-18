import SwiftUI

struct GRProfileDetailView: View {
    let model: GRModelProfile
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var favorites = GRFavoritesControl.shared
    @State private var showContactSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image Section
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 500)
                    
                    Image(model.imageNames.first ?? "")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 500)
                        .clipped()
                    
                    VStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .foregroundColor(.black)
                                .padding()
                                .background(Circle().fill(Color.white.opacity(0.7)))
                        }
                        .padding(.top, 50)
                        .padding(.leading, 20)
                        
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading, spacing: 25) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(model.name)
                                .font(.system(size: 36, weight: .bold, design: .serif))
                                .foregroundColor(.black)
                            Text(model.agency)
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: { favorites.toggleFavorite(model.id) }) {
                            Image(systemName: favorites.favoriteIds.contains(model.id) ? "heart.fill" : "heart")
                                .font(.title)
                                .foregroundColor(favorites.favoriteIds.contains(model.id) ? .red : .black.opacity(0.5))
                                .padding()
                                .background(Circle().fill(Color.black.opacity(0.05)))
                        }
                    }
                    .padding(.top)
                    
                    // Professional Rank (Interactive Feature)
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyany")
                            .foregroundColor(.green)
                        Text("Trending #\(abs(model.name.hashValue % 20) + 1) in Portfolio Hub")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8)
                    
                    // Stats Column Layout
                    VStack(spacing: 20) {
                        HStack(spacing: 0) {
                            StatItem(label: "Height", value: model.height)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            StatItem(label: "Eyes", value: model.eyes)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            StatItem(label: "Hair", value: model.hair)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack(spacing: 0) {
                            StatItem(label: "Bust", value: model.bust)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            StatItem(label: "Waist", value: model.waist)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            StatItem(label: "Hips", value: model.hips)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    Text("BIOGRAPHY")
                        .font(.caption)
                        .tracking(2)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                    
                    Text(model.bio)
                        .font(.body)
                        .foregroundColor(.black.opacity(0.8))
                        .lineSpacing(6)
                    
                    // Professional Interaction: Contact Agency
                    Button(action: {
                        showContactSheet = true
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Contact Agency for Booking")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                    .padding(.top, 20)
                }
                .padding(24)
                .background(Color.white)
            }
        }
        .sheet(isPresented: $showContactSheet) {
            GRBookingInquirySheet(model: model)
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

struct GRBookingInquirySheet: View {
    let model: GRModelProfile
    @Environment(\.presentationMode) var presentationMode
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    Text("Inquiry for \(model.name)")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.top)
                    
                    Text("Interested in booking? Send a brief message to the agency. Our professional team will contact you within 24 hours.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    TextField("", text: $message)
                        .placeholder(when: message.isEmpty) {
                            Text("Your contact details or message...").foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.black.opacity(0.05))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Submit Booking Inquiry")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.black))
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct StatItem: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(label.uppercased())
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .foregroundColor(.black)
        }
    }
}
