import Foundation
import ImageIO

struct ExifParser {

    // MARK: - Nested Types

    struct ParserError: LocalizedError {
        enum Reason {
            case notAnImage
            case noExifProperties
            case noCaptureDate
            case unparsableCaptureDate(String)
        }

        let path: String
        let reason: Reason

        var errorDescription: String? {
            switch reason {
            case .notAnImage:
                "\(path): file is not a readable image"
            case .noExifProperties:
                "\(path): could not read Exif metadata of \(path)"
            case .noCaptureDate:
                "\(path): exif metadata did not contain capture at expected location"
            case .unparsableCaptureDate(let captureDateString):
                "\(path): capture date \"\(captureDateString)\" was not parsable. If you think it should be parseable, please submit an issue on Github"
            }
        }
    }

    // MARK: - Properties

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        return formatter
    }()

    private static let alternativeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return formatter
    }()

    // MARK: - Parsing

    static func exifMetadata(ofFile fileURL: URL) throws -> ExifMetadata {
        guard let imageSource = CGImageSourceCreateWithURL(fileURL as CFURL, nil) else {
            throw ParserError(path: fileURL.relativePath, reason: .notAnImage)
        }
        guard
            let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any],
            let exif = properties["{Exif}"] as? [String: Any]
        else {
            throw ParserError(path: fileURL.relativePath, reason: .noExifProperties)
        }
        guard let captureDateString = exif["DateTimeOriginal"] as? String, !captureDateString.isEmpty else {
            print(exif)
            throw ParserError(path: fileURL.relativePath, reason: .noCaptureDate)
        }
        guard let captureDate = dateFormatter.date(from: captureDateString) ?? alternativeDateFormatter.date(from: captureDateString) else {
            throw ParserError(path: fileURL.relativePath, reason: .unparsableCaptureDate(captureDateString))
        }
        return ExifMetadata(captureDate: captureDate)
    }

}
