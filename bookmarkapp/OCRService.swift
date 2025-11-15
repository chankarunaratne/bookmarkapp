import Foundation
import Vision
import UIKit

struct OCRService {
    enum OCRServiceError: Error {
        case unableToCreateImageForOCR
    }

    /// Represents a single OCR line along with its vertical position
    /// in the image (normalized Vision coordinate space).
    struct OCRLine {
        let text: String
        let minY: CGFloat
    }

    /// Runs a Vision text recognition request and returns individual
    /// lines with their vertical positions so that callers can infer
    /// paragraph structure from layout.
    static func recognizeText(in image: UIImage) async throws -> [OCRLine] {
        let handler = try makeRequestHandler(from: image)

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let lines: [OCRLine] = observations.compactMap { observation in
                    guard let candidate = observation.topCandidates(1).first else {
                        return nil
                    }
                    return OCRLine(
                        text: candidate.string,
                        minY: observation.boundingBox.minY
                    )
                }

                continuation.resume(returning: lines)
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

    /// Builds a Vision image request handler using the most robust available
    /// representation of the given UIImage.
    /// Fallback order: CGImage → CIImage → encoded JPEG/PNG data.
    private static func makeRequestHandler(from image: UIImage) throws -> VNImageRequestHandler {
        if let cgImage = image.cgImage {
            return VNImageRequestHandler(cgImage: cgImage, options: [:])
        }

        if let ciImage = image.ciImage {
            return VNImageRequestHandler(ciImage: ciImage, options: [:])
        }

        if let data = image.jpegData(compressionQuality: 0.95) ?? image.pngData() {
            return VNImageRequestHandler(data: data, options: [:])
        }

        throw OCRServiceError.unableToCreateImageForOCR
    }
}


