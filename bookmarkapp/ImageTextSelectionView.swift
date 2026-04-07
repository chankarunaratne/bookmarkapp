import SwiftUI
import UIKit

struct ImageTextSelectionView: UIViewRepresentable {
    let image: UIImage
    let regions: [OCRService.TextRegion]
    @Binding var selectedText: String
    @Binding var hasSelection: Bool

    func makeUIView(context: Context) -> TextOverlayView {
        let view = TextOverlayView()
        view.onSelectionChanged = { text in
            selectedText = text
            hasSelection = !text.isEmpty
        }
        return view
    }

    func updateUIView(_ uiView: TextOverlayView, context: Context) {
        uiView.configure(image: image, regions: regions)
    }
}

// MARK: - Flattened word with global reading-order index

struct IndexedWord {
    let text: String
    let topLeft: CGPoint
    let topRight: CGPoint
    let bottomLeft: CGPoint
    let bottomRight: CGPoint
    let globalIndex: Int

    var centerY: CGFloat { (topLeft.y + bottomLeft.y) / 2 }
    var centerX: CGFloat { (topLeft.x + topRight.x) / 2 }
}

// MARK: - iOS-style selection handle

private final class SelectionHandleView: UIView {

    enum HandleType { case start, end }

    let handleType: HandleType
    private let stemLayer = CAShapeLayer()
    private let dotLayer = CAShapeLayer()

    private static let dotRadius: CGFloat = 5.5
    private static let stemWidth: CGFloat = 2.5
    private static let handleColor = UIColor.systemBlue

    init(type: HandleType) {
        self.handleType = type
        super.init(frame: .zero)
        backgroundColor = .clear
        isUserInteractionEnabled = true

        stemLayer.strokeColor = Self.handleColor.cgColor
        stemLayer.lineWidth = Self.stemWidth
        stemLayer.lineCap = .round
        stemLayer.fillColor = nil
        layer.addSublayer(stemLayer)

        dotLayer.fillColor = Self.handleColor.cgColor
        dotLayer.strokeColor = nil
        layer.addSublayer(dotLayer)
    }

    required init?(coder: NSCoder) { fatalError() }

    /// Position the handle so its stem aligns with a word edge.
    /// `edgeTop` and `edgeBottom` are in the superview's coordinate space.
    func place(edgeTop: CGPoint, edgeBottom: CGPoint) {
        let r = Self.dotRadius
        let stemH = max(edgeBottom.y - edgeTop.y, 8)
        let pad: CGFloat = 20
        let totalH = pad + r * 2 + stemH + pad
        let w = max(pad * 2, 44)
        let edgeX = (edgeTop.x + edgeBottom.x) / 2

        if handleType == .start {
            frame = CGRect(x: edgeX - w / 2,
                           y: edgeTop.y - r * 2 - pad,
                           width: w, height: totalH)
        } else {
            frame = CGRect(x: edgeX - w / 2,
                           y: edgeTop.y - pad,
                           width: w, height: totalH)
        }

        redraw(stemH: stemH)
    }

    private func redraw(stemH: CGFloat) {
        let r = Self.dotRadius
        let cx = bounds.midX
        let pad: CGFloat = 20

        if handleType == .start {
            let dotCY = pad + r
            let stemTop = pad + r * 2
            let stemBot = stemTop + stemH

            dotLayer.path = UIBezierPath(
                arcCenter: CGPoint(x: cx, y: dotCY),
                radius: r, startAngle: 0,
                endAngle: .pi * 2, clockwise: true
            ).cgPath

            let p = UIBezierPath()
            p.move(to: CGPoint(x: cx, y: stemTop))
            p.addLine(to: CGPoint(x: cx, y: stemBot))
            stemLayer.path = p.cgPath
        } else {
            let stemTop = pad
            let stemBot = pad + stemH
            let dotCY = stemBot + r

            dotLayer.path = UIBezierPath(
                arcCenter: CGPoint(x: cx, y: dotCY),
                radius: r, startAngle: 0,
                endAngle: .pi * 2, clockwise: true
            ).cgPath

            let p = UIBezierPath()
            p.move(to: CGPoint(x: cx, y: stemTop))
            p.addLine(to: CGPoint(x: cx, y: stemBot))
            stemLayer.path = p.cgPath
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -10, dy: -10).contains(point)
    }
}

// MARK: - Core UIKit view

final class TextOverlayView: UIView, UIGestureRecognizerDelegate {

    var onSelectionChanged: ((String) -> Void)?

    private let imageView = UIImageView()
    private let overlayLayer = CALayer()

    private var allWords: [IndexedWord] = []
    private var wordLayers: [CAShapeLayer] = []
    private var wordPaths: [UIBezierPath] = []

    private var anchorIndex: Int?
    private var currentEndIndex: Int?

    private var lastImage: UIImage?
    private var lastRegions: [OCRService.TextRegion]?
    private var needsRebuild = true

    private static let idleTint = UIColor.systemBlue.withAlphaComponent(0.10)
    private static let selectedTint = UIColor.systemBlue.withAlphaComponent(0.32)

    private let startHandle = SelectionHandleView(type: .start)
    private let endHandle = SelectionHandleView(type: .end)
    private var longPressGesture: UILongPressGestureRecognizer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Public

    func configure(image: UIImage, regions: [OCRService.TextRegion]) {
        let imageChanged = image !== lastImage
        let regionsChanged = lastRegions == nil || regions.count != lastRegions!.count

        if imageChanged {
            imageView.image = image
            lastImage = image
            needsRebuild = true
        }
        if regionsChanged {
            lastRegions = regions
            allWords = Self.buildSortedWords(from: regions)
            needsRebuild = true
        }
        if needsRebuild {
            setNeedsLayout()
        }
    }

    // MARK: - Setup

    private func setup() {
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        imageView.layer.addSublayer(overlayLayer)

        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.25
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.require(toFail: longPressGesture)
        addGestureRecognizer(tap)

        startHandle.isHidden = true
        endHandle.isHidden = true
        addSubview(startHandle)
        addSubview(endHandle)

        let startPan = UIPanGestureRecognizer(target: self, action: #selector(handleStartPan(_:)))
        startHandle.addGestureRecognizer(startPan)

        let endPan = UIPanGestureRecognizer(target: self, action: #selector(handleEndPan(_:)))
        endHandle.addGestureRecognizer(endPan)
    }

    // MARK: - UIGestureRecognizerDelegate

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === longPressGesture {
            let point = gestureRecognizer.location(in: self)
            if !startHandle.isHidden, startHandle.frame.insetBy(dx: -10, dy: -10).contains(point) {
                return false
            }
            if !endHandle.isHidden, endHandle.frame.insetBy(dx: -10, dy: -10).contains(point) {
                return false
            }
        }
        return true
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        overlayLayer.frame = imageView.bounds
        if needsRebuild {
            needsRebuild = false
            rebuildOverlays()
        }
        updateHandlePositions()
    }

    private func rebuildOverlays() {
        wordLayers.forEach { $0.removeFromSuperlayer() }
        wordLayers.removeAll()
        wordPaths.removeAll()

        guard let image = imageView.image else { return }

        let fitRect = aspectFitRect(for: image.size, in: imageView.bounds.size)

        for word in allWords {
            let path = quadPath(for: word, fitRect: fitRect, imageSize: image.size)
            wordPaths.append(path)

            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.fillColor = Self.idleTint.cgColor
            layer.strokeColor = nil
            overlayLayer.addSublayer(layer)
            wordLayers.append(layer)
        }
    }

    // MARK: - Coordinate conversion

    private func aspectFitRect(for imageSize: CGSize, in viewSize: CGSize) -> CGRect {
        let widthRatio = viewSize.width / imageSize.width
        let heightRatio = viewSize.height / imageSize.height
        let scale = min(widthRatio, heightRatio)
        let scaledW = imageSize.width * scale
        let scaledH = imageSize.height * scale
        let x = (viewSize.width - scaledW) / 2
        let y = (viewSize.height - scaledH) / 2
        return CGRect(x: x, y: y, width: scaledW, height: scaledH)
    }

    private func visionToView(_ point: CGPoint, fitRect: CGRect, imageSize: CGSize) -> CGPoint {
        let x = fitRect.origin.x + point.x * fitRect.width
        let y = fitRect.origin.y + (1 - point.y) * fitRect.height
        return CGPoint(x: x, y: y)
    }

    private func quadPath(for word: IndexedWord, fitRect: CGRect, imageSize: CGSize) -> UIBezierPath {
        let tl = visionToView(word.topLeft, fitRect: fitRect, imageSize: imageSize)
        let tr = visionToView(word.topRight, fitRect: fitRect, imageSize: imageSize)
        let br = visionToView(word.bottomRight, fitRect: fitRect, imageSize: imageSize)
        let bl = visionToView(word.bottomLeft, fitRect: fitRect, imageSize: imageSize)

        let path = UIBezierPath()
        path.move(to: tl)
        path.addLine(to: tr)
        path.addLine(to: br)
        path.addLine(to: bl)
        path.close()
        return path
    }

    // MARK: - Reading-order word sorting

    private static func buildSortedWords(from regions: [OCRService.TextRegion]) -> [IndexedWord] {
        struct RawWord {
            let text: String
            let topLeft: CGPoint
            let topRight: CGPoint
            let bottomLeft: CGPoint
            let bottomRight: CGPoint
            let lineCenterY: CGFloat
        }

        var rawWords: [RawWord] = []
        for region in regions {
            let lineCY = (region.topLeft.y + region.bottomLeft.y) / 2
            for w in region.words {
                rawWords.append(RawWord(
                    text: w.text,
                    topLeft: w.topLeft,
                    topRight: w.topRight,
                    bottomLeft: w.bottomLeft,
                    bottomRight: w.bottomRight,
                    lineCenterY: lineCY
                ))
            }
        }

        rawWords.sort {
            if abs($0.lineCenterY - $1.lineCenterY) > 0.005 {
                return $0.lineCenterY > $1.lineCenterY
            }
            return $0.topLeft.x < $1.topLeft.x
        }

        return rawWords.enumerated().map { i, w in
            IndexedWord(
                text: w.text,
                topLeft: w.topLeft,
                topRight: w.topRight,
                bottomLeft: w.bottomLeft,
                bottomRight: w.bottomRight,
                globalIndex: i
            )
        }
    }

    // MARK: - Gesture handling

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: imageView)

        switch gesture.state {
        case .began:
            hideSelectionHandles()
            if let idx = hitTestWord(at: point) {
                anchorIndex = idx
                currentEndIndex = idx
                updateHighlights()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }

        case .changed:
            guard anchorIndex != nil else { return }
            if let idx = hitTestWord(at: point) {
                if idx != currentEndIndex {
                    currentEndIndex = idx
                    updateHighlights()
                }
            }

        case .ended, .cancelled:
            reportSelection()
            if anchorIndex != nil {
                showSelectionHandles()
            }

        default:
            break
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard anchorIndex != nil else { return }
        clearSelection()
    }

    // MARK: - Handle pan gestures

    @objc private func handleStartPan(_ gesture: UIPanGestureRecognizer) {
        handlePan(gesture, isStart: true)
    }

    @objc private func handleEndPan(_ gesture: UIPanGestureRecognizer) {
        handlePan(gesture, isStart: false)
    }

    private func handlePan(_ gesture: UIPanGestureRecognizer, isStart: Bool) {
        let point = gesture.location(in: imageView)

        switch gesture.state {
        case .began:
            if let a = anchorIndex, let e = currentEndIndex {
                anchorIndex = min(a, e)
                currentEndIndex = max(a, e)
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

        case .changed:
            guard let idx = hitTestWord(at: point) else { return }
            if isStart {
                let clamped = min(idx, currentEndIndex ?? idx)
                if clamped != anchorIndex {
                    anchorIndex = clamped
                    updateHighlights()
                    updateHandlePositions()
                }
            } else {
                let clamped = max(idx, anchorIndex ?? idx)
                if clamped != currentEndIndex {
                    currentEndIndex = clamped
                    updateHighlights()
                    updateHandlePositions()
                }
            }

        case .ended, .cancelled:
            reportSelection()

        default: break
        }
    }

    // MARK: - Hit testing

    private func hitTestWord(at point: CGPoint) -> Int? {
        for (i, path) in wordPaths.enumerated() {
            if path.contains(point) {
                return i
            }
        }
        return nearestWord(to: point)
    }

    private func nearestWord(to point: CGPoint) -> Int? {
        guard let image = imageView.image else { return nil }
        let fitRect = aspectFitRect(for: image.size, in: imageView.bounds.size)
        guard fitRect.contains(point) else { return nil }

        var bestIndex: Int?
        var bestDist: CGFloat = .greatestFiniteMagnitude

        for word in allWords {
            let center = visionToView(
                CGPoint(x: word.centerX, y: word.centerY),
                fitRect: fitRect,
                imageSize: image.size
            )
            let dx = center.x - point.x
            let dy = center.y - point.y
            let dist = dx * dx + dy * dy
            if dist < bestDist {
                bestDist = dist
                bestIndex = word.globalIndex
            }
        }

        let maxSnapDistance: CGFloat = 30
        if bestDist > maxSnapDistance * maxSnapDistance {
            return nil
        }
        return bestIndex
    }

    // MARK: - Selection state

    private func updateHighlights() {
        guard let anchor = anchorIndex, let end = currentEndIndex else { return }
        let lo = min(anchor, end)
        let hi = max(anchor, end)

        for (i, layer) in wordLayers.enumerated() {
            layer.fillColor = (i >= lo && i <= hi)
                ? Self.selectedTint.cgColor
                : Self.idleTint.cgColor
        }
    }

    private func reportSelection() {
        guard let anchor = anchorIndex, let end = currentEndIndex else {
            onSelectionChanged?("")
            return
        }
        let lo = min(anchor, end)
        let hi = max(anchor, end)
        let selected = allWords
            .filter { $0.globalIndex >= lo && $0.globalIndex <= hi }
            .map { $0.text }
            .joined(separator: " ")
        onSelectionChanged?(selected)
    }

    private func clearSelection() {
        anchorIndex = nil
        currentEndIndex = nil
        for layer in wordLayers {
            layer.fillColor = Self.idleTint.cgColor
        }
        hideSelectionHandles()
        onSelectionChanged?("")
    }

    // MARK: - Selection handles

    private func updateHandlePositions() {
        guard !startHandle.isHidden,
              let lo = anchorIndex, let hi = currentEndIndex,
              let image = imageView.image else { return }

        let fitRect = aspectFitRect(for: image.size, in: imageView.bounds.size)

        let startWord = allWords[lo]
        let startTop = visionToView(startWord.topLeft, fitRect: fitRect, imageSize: image.size)
        let startBottom = visionToView(startWord.bottomLeft, fitRect: fitRect, imageSize: image.size)
        startHandle.place(edgeTop: startTop, edgeBottom: startBottom)

        let endWord = allWords[hi]
        let endTop = visionToView(endWord.topRight, fitRect: fitRect, imageSize: image.size)
        let endBottom = visionToView(endWord.bottomRight, fitRect: fitRect, imageSize: image.size)
        endHandle.place(edgeTop: endTop, edgeBottom: endBottom)
    }

    private func showSelectionHandles() {
        if let a = anchorIndex, let e = currentEndIndex {
            anchorIndex = min(a, e)
            currentEndIndex = max(a, e)
        }

        startHandle.isHidden = false
        endHandle.isHidden = false
        startHandle.alpha = 0
        endHandle.alpha = 0
        updateHandlePositions()

        UIView.animate(withDuration: 0.15) {
            self.startHandle.alpha = 1
            self.endHandle.alpha = 1
        }
    }

    private func hideSelectionHandles() {
        startHandle.isHidden = true
        endHandle.isHidden = true
    }
}
