import SwiftUI

@available(iOS 14.0, *)
struct RouteDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // 1. Hero Header
                ZStack(alignment: .bottomLeading) {
                    ProceduralBauhausView()
                        .frame(height: 400)
                        
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SATURDAY RHYTHM")
                            .font(.system(size: 10, weight: .black))
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.black).foregroundColor(.white).cornerRadius(4)
                        Text("The Bauhaus Walk")
                            .font(.system(size: 40, weight: .black))
                            .foregroundColor(.black)
                    }
                    .padding(30)
                }
                
                // 2. Curator's Note
                VStack(alignment: .leading, spacing: 15) {
                    Text("CURATOR'S NOTE")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("This route is designed to capture the structural essence of the city. We start at the minimalist crossings of District 9 and wind our way through the hidden design studios of SOHO.")
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .italic()
                        .lineSpacing(6)
                }
                .padding(.horizontal, 30)
                
                // 3. The Path (Steps)
                VStack(alignment: .leading, spacing: 25) {
                    Text("THE PATH")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    RouteStepRow(number: "01", title: "District 9 Grid", description: "Observe the rhythmic repeating patterns of the industrial glass facades.")
                    RouteStepRow(number: "02", title: "Archive Corridor", description: "A quiet transition through the Library St. underpass.")
                    RouteStepRow(number: "03", title: "The Design Lab", description: "Our final destination - where form meets function.")
                }
                .padding(.horizontal, 30)
                
                Spacer().frame(height: 50)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
        .overlay(
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .padding(12)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding(.top, 50)
            .padding(.leading, 30),
            alignment: .topLeading
        )
    }
}

struct RouteStepRow: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Text(number)
                .font(.system(size: 24, weight: .black))
                .foregroundColor(.black.opacity(0.15))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(size: 18, weight: .bold))
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
