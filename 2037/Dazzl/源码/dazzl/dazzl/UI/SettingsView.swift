import SwiftUI

@available(iOS 14.0, *)
struct SettingsView: View {
    @State private var showPrivacy = false
    @State private var privacyContent = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                List {
                    Section(header: Text("Information").foregroundColor(.gray)) {
                        Button(action: { 
                            loadPrivacy()
                            showPrivacy = true 
                        }) {
                            HStack {
                                Label("Privacy Policy", systemImage: "doc.text.fill")
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                            }
                        }
                        
                        HStack {
                            Label("App Version", systemImage: "info.circle.fill")
                            Spacer()
                            Text("1.0.0").foregroundColor(.gray)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section(header: Text("Management").foregroundColor(.gray)) {
                        Button(action: {
                            // Clear cache logic
                        }) {
                            Label("Clear Cache", systemImage: "trash.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section {
                        VStack(alignment: .center, spacing: 8) {
                            Text("Dazzl")
                                .font(.title3).bold()
                                .foregroundColor(.white)
                            Text("Pure Aesthetic Inspiration")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPrivacy) {
                PrivacyDetailView(content: privacyContent)
            }
        }
        .onAppear {
            // Fix list background
            UITableView.appearance().backgroundColor = .clear
        }
    }
    
    private func loadPrivacy() {
        if let path = Bundle.main.path(forResource: "Privacy", ofType: "txt"),
           let content = try? String(contentsOfFile: path) {
            self.privacyContent = content
        } else {
            self.privacyContent = "Error loading privacy policy."
        }
    }
}

@available(iOS 14.0, *)
struct PrivacyDetailView: View {
    let content: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    Text(content)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .preferredColorScheme(.dark)
    }
}
