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
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var model = CameraModel()
    @State private var latestPhoto: UIImage?
    @State private var showPhotoPicker = false
    
    var body: some View {
        ZStack {
            if model.cameraAuthorized {
                cameraContent
                    .transition(.opacity)
            } else {
                cameraPermissionContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: model.cameraAuthorized)
        .onAppear {
            model.checkPermissions()
            if model.cameraAuthorized {
                fetchLatestPhoto()
            }
        }
        .onChange(of: model.cameraAuthorized) { _, authorized in
            if authorized {
                fetchLatestPhoto()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                model.recheckAuthorization()
            }
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
        .onDisappear {
            model.stopSession()
        }
    }
    
    // MARK: - Camera Content
    
    private var cameraContent: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                .padding(.bottom, 12)
                
                GeometryReader { geo in
                    let inset: CGFloat = 16
                    CameraPreview(session: model.session)
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .frame(
                            width: max(0, geo.size.width - inset * 2),
                            height: max(0, geo.size.height - inset * 2)
                        )
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                HStack {
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
                    
                    Spacer()
                        .frame(width: 56)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 32)
                .padding(.bottom, 16)
            }
        }
    }
    
    // MARK: - Camera Permission Content
    
    private var cameraPermissionContent: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AppColor.glassIconForeground)
                    }
                }
                .padding(.trailing, 24)
                .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 32) {
                    ZStack {
                        Circle()
                            .fill(AppColor.cardBorder)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "camera")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(AppColor.textSubdued)
                    }
                    
                    VStack(spacing: 10) {
                        Text("Camera access required")
                            .font(AppFont.emptyStateTitle)
                            .foregroundStyle(AppColor.textPrimary)
                        
                        Text("For Rememberly to work properly we need to access your camera so that it can capture the text. Please allow camera access below.")
                            .font(AppFont.emptyStateBody)
                            .foregroundStyle(AppColor.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    
                    Button(action: { model.requestCameraAccess() }) {
                        Text("Allow camera access")
                            .font(AppFont.buttonLabel)
                            .foregroundStyle(.white)
                            .frame(height: 36)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(AppColor.buttonDark)
                                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0)
                                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 40)
                
                Spacer()
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
                .foregroundColor(.white)
        }
        .background(.ultraThinMaterial, in: Circle())
    }
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    @Published var capturedImage: UIImage?
    @Published var cameraAuthorized: Bool
    
    private let output = AVCapturePhotoOutput()
    /// Serializes session start/stop and coordinates with `setup()` so a late async completion cannot start the camera after the UI was dismissed.
    private let sessionQueue = DispatchQueue(label: "bookmarkapp.camera.session")
    private var allowsSessionRunning = true
    
    override init() {
        self.cameraAuthorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        super.init()
    }
    
    func checkPermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraAuthorized = (status == .authorized)
        if status == .authorized {
            setup()
        }
    }
    
    func requestCameraAccess() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.cameraAuthorized = granted
                    if granted { self?.setup() }
                }
            }
        case .denied, .restricted:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        default:
            break
        }
    }
    
    func recheckAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized && !cameraAuthorized {
            DispatchQueue.main.async {
                self.cameraAuthorized = true
            }
            setup()
        }
    }
    
    func setup() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device) else {
                return
            }
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
            guard self.allowsSessionRunning else { return }
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.allowsSessionRunning = false
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.allowsSessionRunning = false
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
        DispatchQueue.main.async {
            self.capturedImage = image
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
