//
//  ChatViews.swift
//  joyar
//
//  Created by Antigravity on 01/06/2026.
//

import SwiftUI
import Combine

// MARK: - Chat List View
struct ChatListView: View {
    @ObservedObject var dataService = DataService.shared
    @State private var selectedTrainer: Trainer? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header block
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("JOYAR COACHES")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                            .tracking(2)
                        
                        Text("Expert Gym Advice")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Coaches List block
                VStack(spacing: 12) {
                    ForEach(dataService.trainers.filter { !dataService.blockedUserNames.contains($0.name) }, id: \.id) { trainer in
                        TrainerRowView(trainer: trainer)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTrainer = trainer
                            }
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            }
        }
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
        .background(
            Color(red: 0.07, green: 0.07, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
        )
        .background(
            ZStack {
                NavigationLink(
                    destination: Group {
                        if let trainer = selectedTrainer {
                            ChatDetailView(trainerId: trainer.id)
                        }
                    },
                    isActive: Binding(
                        get: { selectedTrainer != nil },
                        set: { if !$0 { selectedTrainer = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .frame(width: 0, height: 0)
        )
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

// MARK: - Trainer Row Item
struct TrainerRowView: View {
    let trainer: Trainer
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar with Online Badge overlay
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: trainer.avatar)
                    .font(.system(size: 28))
                    .foregroundColor(.black)
                    .frame(width: 50, height: 50)
                    .background(Color(red: 0.90, green: 0.90, blue: 0.92))
                    .clipShape(Circle())
                
                if trainer.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color(red: 0.12, green: 0.12, blue: 0.14), lineWidth: 2))
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .bottom) {
                    Text(trainer.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text(trainer.lastMessageTime)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                Text(trainer.specialty)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 1.0, green: 0.37, blue: 0.23))
                
                // Typing Indicator or Last Msg
                if trainer.isTyping {
                    HStack(spacing: 4) {
                        Text("Coach is typing")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.green)
                        TypingDotsAnimationView()
                    }
                } else {
                    Text(trainer.lastMessage)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
        }
        .padding(14)
        .background(Color(red: 0.12, green: 0.12, blue: 0.14))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Typing Indicator Animation helper
struct TypingDotsAnimationView: View {
    @State private var activeDot = 0
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.green)
                    .frame(width: 4, height: 4)
                    .opacity(activeDot == index ? 1.0 : 0.3)
                    .scaleEffect(activeDot == index ? 1.2 : 1.0)
            }
        }
        .onReceive(timer) { _ in
            withAnimation {
                activeDot = (activeDot + 1) % 3
            }
        }
    }
}

// MARK: - Chat Details Conversation View
struct ChatDetailView: View {
    let trainerId: String
    @ObservedObject var dataService = DataService.shared
    @State private var inputText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var trainer: Trainer? {
        dataService.trainers.firstNumerator(where: { $0.id == trainerId })
    }
    
    var messages: [ChatMessage] {
        dataService.chatMessages.filter { $0.trainerId == trainerId }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header panel
            HStack(spacing: 12) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color(red: 0.16, green: 0.16, blue: 0.18))
                        .clipShape(Circle())
                }
                
                if let tr = trainer {
                    Image(systemName: tr.avatar)
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 38, height: 38)
                        .background(Color(red: 0.9, green: 0.9, blue: 0.92))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tr.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(tr.isOnline ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)
                            Text(tr.isOnline ? "Online" : "Offline")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                }
                Spacer()
                
                if let tr = trainer {
                    Button(action: {
                        dataService.activeModTarget = ModerationTarget(id: tr.id, type: "Trainer Chat", contentId: tr.id, authorName: tr.name)
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color(red: 0.16, green: 0.16, blue: 0.18))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(red: 0.10, green: 0.10, blue: 0.12))
            
            // Messages stream
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.08)
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(messages, id: \.id) { msg in
                                HStack {
                                    if msg.isFromUser {
                                        Spacer()
                                        // User Bubble (Gradient Coral Accent)
                                        Text(msg.content)
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 11)
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(red: 1.0, green: 0.37, blue: 0.23),
                                                        Color(red: 1.0, green: 0.18, blue: 0.33)
                                                    ]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .cornerRadius(18)
                                            .padding(.leading, 60)
                                    } else {
                                        // Trainer Bubble (Dark Slate Card)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(msg.content)
                                                .font(.system(size: 14))
                                                .foregroundColor(.white)
                                                .lineSpacing(2)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 11)
                                        .background(Color(red: 0.16, green: 0.16, blue: 0.18))
                                        .cornerRadius(18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(Color.white.opacity(0.04), lineWidth: 1)
                                        )
                                        .padding(.trailing, 60)
                                        Spacer()
                                    }
                                }
                            }
                            
                            // Trainer Typing Indicator
                            if let tr = trainer, tr.isTyping {
                                HStack {
                                    HStack(spacing: 6) {
                                        Text("Coach is analyzing query")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.green)
                                        TypingDotsAnimationView()
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(12)
                                    Spacer()
                                }
                            }
                        }
                        .padding(16)
                        .frame(minHeight: geometry.size.height, alignment: .top)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                )
            }
            .background(Color(red: 0.07, green: 0.07, blue: 0.08))
            
            // Bottom Editor Bar
            HStack(spacing: 12) {
                TextField("Message trainer...", text: $inputText)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .padding(12)
                    .background(Color(red: 0.08, green: 0.08, blue: 0.10))
                    .cornerRadius(20)
                
                Button(action: {
                    let textToSend = inputText
                    inputText = ""
                    dataService.sendUserChatMessage(trainerId: trainerId, content: textToSend)
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color(red: 1.0, green: 0.37, blue: 0.23))
                        .clipShape(Circle())
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(red: 0.12, green: 0.12, blue: 0.14))
        }
        .background(
            Color(red: 0.07, green: 0.07, blue: 0.08)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarHidden(true)
        .onReceive(dataService.$blockedUserNames) { blockedList in
            if let tr = trainer, blockedList.contains(tr.name) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct ChatViews_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatListView()
        }
        .preferredColorScheme(.dark)
    }
}
