import Foundation
import Vision
import UIKit

struct OCRService {
    enum OCRServiceError: Error {
        case unableToCreateImageForOCR
    }

    struct WordRegion {
        let text: String
        let topLeft: CGPoint
        let topRight: CGPoint
        let bottomLeft: CGPoint
        let bottomRight: CGPoint
        let rangeStart: Int
        let rangeEnd: Int
    }

    struct TextRegion {
        let text: String
        let topLeft: CGPoint
        let topRight: CGPoint
        let bottomLeft: CGPoint
        let bottomRight: CGPoint
        let words: [WordRegion]
    }

    /// Runs Vision text recognition and returns line-level regions with
    /// word-level bounding quadrilaterals in normalized image coordinates.
    static func recognizeText(in image: UIImage) async throws -> [TextRegion] {
        let handler = try makeRequestHandler(from: image)

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let regions: [TextRegion] = observations.compactMap { observation in
                    guard let candidate = observation.topCandidates(1).first else {
                        return nil
                    }

                    let words = Self.extractWords(from: candidate, observation: observation)

                    return TextRegion(
                        text: candidate.string,
                        topLeft: observation.topLeft,
                        topRight: observation.topRight,
                        bottomLeft: observation.bottomLeft,
                        bottomRight: observation.bottomRight,
                        words: words
                    )
                }

                continuation.resume(returning: regions)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US"]

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Extracts word-level bounding quads from a recognized text candidate.
    /// Falls back to the full observation quad if word-level boxes aren't available.
    private static func extractWords(
        from candidate: VNRecognizedText,
        observation: VNRecognizedTextObservation
    ) -> [WordRegion] {
        let fullString = candidate.string
        var words: [WordRegion] = []

        fullString.enumerateSubstrings(
            in: fullString.startIndex..<fullString.endIndex,
            options: .byWords
        ) { substring, substringRange, _, _ in
            guard let word = substring, !word.isEmpty else { return }

            if let box = try? candidate.boundingBox(for: substringRange) {
                words.append(WordRegion(
                    text: word,
                    topLeft: box.topLeft,
                    topRight: box.topRight,
                    bottomLeft: box.bottomLeft,
                    bottomRight: box.bottomRight,
                    rangeStart: fullString.distance(from: fullString.startIndex, to: substringRange.lowerBound),
                    rangeEnd: fullString.distance(from: fullString.startIndex, to: substringRange.upperBound)
                ))
            }
        }

        if words.isEmpty {
            words.append(WordRegion(
                text: fullString,
                topLeft: observation.topLeft,
                topRight: observation.topRight,
                bottomLeft: observation.bottomLeft,
                bottomRight: observation.bottomRight,
                rangeStart: 0,
                rangeEnd: fullString.count
            ))
        }

        return words
    }

    private static func makeRequestHandler(from image: UIImage) throws -> VNImageRequestHandler {
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)

        if let cgImage = image.cgImage {
            return VNImageRequestHandler(cgImage: cgImage, orientation: cgOrientation, options: [:])
        }

        if let ciImage = image.ciImage {
            return VNImageRequestHandler(ciImage: ciImage, orientation: cgOrientation, options: [:])
        }

        if let data = image.jpegData(compressionQuality: 0.95) ?? image.pngData() {
            return VNImageRequestHandler(data: data, options: [:])
        }

        throw OCRServiceError.unableToCreateImageForOCR
    }
}

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up:            self = .up
        case .down:          self = .down
        case .left:          self = .left
        case .right:         self = .right
        case .upMirrored:    self = .upMirrored
        case .downMirrored:  self = .downMirrored
        case .leftMirrored:  self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default:    self = .up
        }
    }
}
