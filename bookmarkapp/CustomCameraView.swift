//
//  CustomCameraView.swift
//  bookmarkapp
//

import SwiftUI
import AVFoundation
import Photos
import Combine

struct CustomCameraView: View {
    var onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    @StateObject private var model = CameraModel()
    @State private var latestPhoto: UIImage?
    @State private var showPhotoPicker = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top header
                HStack {
                    Spacer()
                    Text("Camera")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    Spacer()
                }
                .overlay(
                    Button(action: { dismiss() }) {
                        LiquidGlassXButton()
                    }
                    .padding(.trailing, 24)
                    , alignment: .trailing
                )
                .padding(.top, 24)
                .padding(.bottom, 24)
                
                // Guide text
                VStack(spacing: 4) {
                    Text("Keep the text clear and flat.")
                        .font(.system(size: 18))
                        .foregroundColor(Color(white: 0.4))
                    Text("You’ll select the highlight next.")
                        .font(.system(size: 18))
                        .foregroundColor(Color(white: 0.4))
                }
                .padding(.bottom, 24)
                
                // Viewport
                CameraPreview(session: model.session)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .padding(.horizontal, 24)
                
                // Bottom controls
                HStack {
                    // Gallery shortcut
                    Button {
                        showPhotoPicker = true
                    } label: {
                        if let photo = latestPhoto {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(white: 0.2))
                                .frame(width: 56, height: 56)
                        }
                    }
                    
                    Spacer()
                    
                    // Native-like shooter button
                    Button {
                        model.capturePhoto()
                    } label: {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 65, height: 65)
                            .padding(4)
                            .background(
                                Circle().stroke(Color.white.opacity(0.3), lineWidth: 4)
                            )
                    }
                    
                    Spacer()
                    
                    // Balancing empty space for alignment
                    Spacer()
                        .frame(width: 56)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 32)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            model.checkPermissions()
            fetchLatestPhoto()
        }
        .onChange(of: model.capturedImage) { _, image in
            if let img = image {
                onImagePicked(img)
                dismiss()
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker { img in
                onImagePicked(img)
                dismiss()
            }
        }
    }
    
    private func fetchLatestPhoto() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .authorized || status == .limited {
            loadLatestPhoto()
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    loadLatestPhoto()
                }
            }
        }
    }
    
    private func loadLatestPhoto() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 1
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
        guard let asset = fetchResult.firstObject else { return }
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .opportunistic
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill, options: requestOptions) { image, _ in
            DispatchQueue.main.async {
                self.latestPhoto = image
            }
        }
    }
}

struct LiquidGlassXButton: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(white: 0.8).opacity(0.15))
                .frame(width: 38, height: 38)
            
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                // iOS 26 liquid glass commonly has contrasting icons or somewhat dark gray
                .foregroundColor(.white)
        }
        .background(.ultraThinMaterial, in: Circle())
    }
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var capturedImage: UIImage?
    
    private let output = AVCapturePhotoOutput()
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setup()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { self?.setup() }
                }
            }
        default: break
        }
    }
    
    func setup() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()
            
            // Setup input
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                return
            }
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            // Setup output
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        DispatchQueue.main.async {
            self.capturedImage = image
            self.session.stopRunning()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
}
