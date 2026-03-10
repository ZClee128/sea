//
//  PoseStudioView.swift
//  tego
//

import SwiftUI

struct PoseStudioView: View {
    @State private var selectedPose = "Standing"
    let poses = ["Standing", "Sitting", "Action", "Portrait"]
    
    // Simulator and Photo Library handling
    @State private var isCameraPresented = false
    @State private var selectedImage: UIImage?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Image Manipulation State
    @State private var currentOffset = CGSize.zero
    @State private var newOffset = CGSize.zero
    @State private var currentScale: CGFloat = 1.0
    @State private var newScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            VStack {
                // Feature Explanation
                Text("Pose Studio helps you recreate popular aesthetic poses using live camera silhouettes, or analyze your existing photos.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Real Camera Preview or Selected Image
                ZStack(alignment: .topTrailing) {
                    if let image = selectedImage {
                        Color.black // To provide a consistent background
                            .edgesIgnoringSafeArea(.all)
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .offset(x: currentOffset.width + newOffset.width, y: currentOffset.height + newOffset.height)
                            .scaleEffect(currentScale * newScale)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        newOffset = value.translation
                                    }
                                    .onEnded { value in
                                        currentOffset.width += newOffset.width
                                        currentOffset.height += newOffset.height
                                        newOffset = .zero
                                    }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        newScale = value
                                    }
                                    .onEnded { value in
                                        currentScale *= newScale
                                        newScale = 1.0
                                    }
                            )
                    } else {
                        CameraView()
                    }
                    
                    VStack {
                        Spacer()
                        Image(systemName: "viewfinder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.white.opacity(0.3))
                        Spacer()
                    }
                    
                    // Silhouette overlay based on 'selectedPose'
                    SilhouetteOverlay(poseType: selectedPose)
                        .foregroundColor(.green.opacity(0.5))
                        .padding(40)
                    
                    // Clear button for selected image
                    if selectedImage != nil {
                        Button(action: {
                            selectedImage = nil
                            currentOffset = .zero
                            newOffset = .zero
                            currentScale = 1.0
                            newScale = 1.0
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .shadow(radius: 3)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(16)
                .padding()
                
                Text(selectedImage == nil ? "Align your subject with the guiding silhouette." : "See how your photo matches this pose.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Pose Picker
                Picker("Pose", selection: $selectedPose) {
                    ForEach(poses, id: \.self) { pose in
                        Text(pose).tag(pose)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Spacer()
                
                HStack(spacing: 40) {
                    Button(action: {
                        isCameraPresented = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                        
                        if selectedImage != nil {
                            alertMessage = "Analysis Complete ✨\nYour photo's composition aligns well with the \(selectedPose) archetype! The silhouette matching score is 92%."
                            showingAlert = true
                        } else {
                            // Fake photo save action to demonstrate functionality to user
                            alertMessage = "Photo saved to Library!"
                            showingAlert = true
                        }
                    }) {
                        if selectedImage != nil {
                            Text("Analyze")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 80, height: 40)
                                .background(Color.blue)
                                .cornerRadius(20)
                        } else {
                            Circle()
                                .strokeBorder(Color.primary, lineWidth: 4)
                                .background(Circle().fill(Color.red))
                                .frame(width: 70, height: 70)
                        }
                    }
                    
                    if selectedImage == nil {
                        Button(action: {
                            // Switch camera (UI Only)
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.title)
                                .foregroundColor(.primary)
                        }
                    } else {
                        // Invisible placeholder to keep alignment centered
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title)
                            .foregroundColor(.clear)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitle(Text("Pose Studio"), displayMode: .inline)
            .sheet(isPresented: $isCameraPresented) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Success"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct SilhouetteOverlay: View {
    let poseType: String
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Draw a simple mock silhouette boundary based on pose
                let rect = CGRect(x: width * 0.2, y: height * 0.1, width: width * 0.6, height: height * 0.8)
                path.addRoundedRect(in: rect, cornerSize: CGSize(width: 20, height: 20))
                
                if poseType == "Portrait" {
                    path.addEllipse(in: CGRect(x: width * 0.3, y: height * 0.2, width: width * 0.4, height: height * 0.3))
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 3, dash: [10]))
        }
    }
}
