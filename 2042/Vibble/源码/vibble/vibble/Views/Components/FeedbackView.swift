//
//  FeedbackView.swift
//  vibble
//

import SwiftUI

@available(iOS 14.0, *)
struct FeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var description = ""
    @State private var showSuccess = false
    let title: String
    
    init(title: String = "Report a Problem") {
        self.title = title
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) { 
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white) 
                    }
                    Spacer()
                    Text(title).font(.headline).foregroundColor(.white)
                    Spacer()
                    Image(systemName: "xmark").opacity(0)
                }.padding()
                
                if showSuccess {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.fill").font(.system(size: 80)).foregroundColor(Theme.primary)
                        Text("Thank You").foregroundColor(.white).font(.title2.bold())
                        Text("We have received your report and will review it shortly.").foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal, 40)
                        Button("Done") { presentationMode.wrappedValue.dismiss() }.padding().frame(width: 150).background(Theme.primary).foregroundColor(.white).cornerRadius(10)
                    }.frame(maxHeight: .infinity)
                } else {
                    VStack(spacing: 20) {
                        TextEditor(text: $description)
                            .frame(height: 200)
                            .padding()
                            .background(Theme.cardBackground)
                            .cornerRadius(15)
                            .foregroundColor(.white)
                            .overlay(
                                Group {
                                    if description.isEmpty {
                                        Text("Please describe the issue or inappropriate behavior...")
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(.leading, 25)
                                            .padding(.top, 30)
                                    }
                                }, alignment: .topLeading
                            )
                        
                        Button(action: { withAnimation { showSuccess = true } }) {
                            Text("Submit").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 55).background(Theme.primary).cornerRadius(15)
                        }
                        .disabled(description.isEmpty)
                        .opacity(description.isEmpty ? 0.6 : 1.0)
                    }.padding(25)
                    Spacer()
                }
            }
        }.navigationBarHidden(true)
    }
}
