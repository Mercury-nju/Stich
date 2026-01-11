//
//  ContentView.swift
//  长图拼接
//
//  Created by Mercury on 2026/1/11.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [IdentifiableImage] = []
    @State private var isProcessing = false
    @State private var showingSaveAlert = false
    @State private var saveSuccess = false
    @State private var stitchedImage: UIImage?
    @State private var showingPreview = false
    @State private var showingSettings = false
    @State private var showingOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    @State private var showingMemoryWarning = false
    
    private let accentGradient = LinearGradient(
        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if selectedImages.isEmpty {
                        emptyStateView
                    } else {
                        imageGridView
                    }
                    
                    bottomBar
                }
            }
            .navigationTitle("LongPic")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if !selectedImages.isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedImages.removeAll()
                                selectedItems.removeAll()
                            }
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.red.opacity(0.8))
                        }
                    }
                }
            }
            .alert(saveSuccess ? "Saved!" : "Error", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(saveSuccess ? "Image saved to your photo library." : "Please allow photo library access in Settings.")
            }
            .fullScreenCover(isPresented: $showingPreview) {
                if let image = stitchedImage {
                    PreviewView(image: image, isPresented: $showingPreview) {
                        saveImageToPhotos(image)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $showingOnboarding) {
                OnboardingView(isPresented: $showingOnboarding)
                    .onDisappear {
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    }
            }
            .alert("Memory Warning", isPresented: $showingMemoryWarning) {
                Button("Continue Anyway") {
                    performStitch()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("The selected images are very large and may cause the app to slow down. Consider selecting fewer or smaller images.")
            }
            .overlay {
                if isProcessing {
                    ProcessingOverlay()
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(accentGradient.opacity(0.1))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "photo.stack")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(accentGradient)
            }
            
            VStack(spacing: 8) {
                Text("Create Long Images")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Select multiple photos to stitch them\ninto a single vertical image")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 30,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text("Select Photos")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(accentGradient)
                .clipShape(Capsule())
                .shadow(color: Color(hex: "667eea").opacity(0.3), radius: 8, y: 4)
            }
            .onChange(of: selectedItems) { _, newItems in
                loadImages(from: newItems)
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }

    
    // MARK: - Image Grid
    private var imageGridView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Header info
                HStack {
                    Label("\(selectedImages.count) photos", systemImage: "photo.on.rectangle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("Hold & drag to reorder")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 4)
                .padding(.top, 8)
                
                // Image cards
                ForEach(Array(selectedImages.enumerated()), id: \.element.id) { index, item in
                    ImageCard(
                        image: item.image,
                        index: index + 1,
                        onDelete: {
                            withAnimation(.spring(response: 0.3)) {
                                if let idx = selectedImages.firstIndex(where: { $0.id == item.id }) {
                                    selectedImages.remove(at: idx)
                                }
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
                .onMove(perform: moveImages)
            }
            .padding()
        }
        .environment(\.editMode, .constant(.active))
    }
    
    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 16) {
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 30,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Add")
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(Color(hex: "667eea"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(hex: "667eea").opacity(0.1))
                    .clipShape(Capsule())
                }
                .onChange(of: selectedItems) { _, newItems in
                    loadImages(from: newItems)
                }
                
                Spacer()
                
                if selectedImages.count >= 2 {
                    Button {
                        stitchImages()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Stitch")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(accentGradient)
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "667eea").opacity(0.25), radius: 6, y: 3)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else if !selectedImages.isEmpty {
                    Text("Select at least 2 photos")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
        }
    }
    
    // MARK: - Functions
    private func moveImages(from source: IndexSet, to destination: Int) {
        selectedImages.move(fromOffsets: source, toOffset: destination)
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        Task {
            isProcessing = true
            var newImages: [IdentifiableImage] = []
            
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    newImages.append(IdentifiableImage(image: uiImage))
                }
            }
            
            await MainActor.run {
                withAnimation(.spring(response: 0.4)) {
                    selectedImages = newImages
                }
                isProcessing = false
            }
        }
    }

    
    private func stitchImages() {
        guard selectedImages.count >= 2 else { return }
        
        let images = selectedImages.map { $0.image }
        
        // Check memory before stitching
        if !ImageProcessor.canSafelyStitch(images) {
            showingMemoryWarning = true
            return
        }
        
        performStitch()
    }
    
    private func performStitch() {
        guard selectedImages.count >= 2 else { return }
        
        isProcessing = true
        
        Task.detached(priority: .userInitiated) {
            let images = await MainActor.run { selectedImages.map { $0.image } }
            
            let result = ImageProcessor.stitchImages(images)
            
            await MainActor.run {
                stitchedImage = result
                isProcessing = false
                if result != nil {
                    showingPreview = true
                }
            }
        }
    }
    
    private func saveImageToPhotos(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if status == .authorized || status == .limited {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                DispatchQueue.main.async {
                    saveSuccess = true
                    showingSaveAlert = true
                }
            } else {
                DispatchQueue.main.async {
                    saveSuccess = false
                    showingSaveAlert = true
                }
            }
        }
    }
}

// MARK: - Image Card Component
struct ImageCard: View {
    let image: UIImage
    let index: Int
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Photo \(index)")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text("\(Int(image.size.width)) × \(Int(image.size.height))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .buttonStyle(.plain)
            
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.tertiary)
                .padding(.leading, 4)
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Processing Overlay
struct ProcessingOverlay: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                }
                
                Text("Processing...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(36)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
        .onAppear { isAnimating = true }
    }
}


// MARK: - Preview View
struct PreviewView: View {
    let image: UIImage
    @Binding var isPresented: Bool
    let onSave: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    private let accentGradient = LinearGradient(
        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    if scale < 1 {
                                        withAnimation(.spring(response: 0.3)) {
                                            scale = 1
                                            lastScale = 1
                                        }
                                    }
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring(response: 0.3)) {
                                if scale > 1 {
                                    scale = 1
                                    lastScale = 1
                                } else {
                                    scale = 2
                                    lastScale = 2
                                }
                            }
                        }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Preview")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("\(Int(image.size.width)) × \(Int(image.size.height))")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onSave()
                        isPresented = false
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(accentGradient)
                        .clipShape(Capsule())
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Zoom hint
                HStack(spacing: 6) {
                    Image(systemName: "hand.pinch")
                    Text("Pinch to zoom")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.vertical, 12)
            }
        }
    }
}

// MARK: - Supporting Types
struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
