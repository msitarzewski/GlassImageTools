import Foundation
import CoreGraphics

public enum AnnotationKind: String, CaseIterable, Sendable {
    case rectangle = "Rectangle", ellipse = "Ellipse", arrow = "Arrow"
    case line = "Line", roundedRectangle = "Rounded Rectangle", triangle = "Triangle", speechBubble = "Speech Bubble"
    case freehand = "Draw", text = "Text", pixelate = "Pixelate"
    public static let shapes: [Self] = [.rectangle, .roundedRectangle, .ellipse, .triangle, .speechBubble, .line, .arrow]
    public var isShape: Bool { Self.shapes.contains(self) }
    public var supportsFill: Bool {
        switch self {
        case .rectangle, .roundedRectangle, .ellipse, .triangle, .speechBubble: true
        default: false
        }
    }
    public var hasEndpoints: Bool { self == .line || self == .arrow }
    public var symbol: String {
        switch self {
        case .rectangle: "rectangle"
        case .ellipse: "circle"
        case .arrow: "arrow.up.right"
        case .line: "line.diagonal"
        case .roundedRectangle: "rectangle.roundedtop"
        case .triangle: "triangle"
        case .speechBubble: "bubble.left"
        case .freehand: "pencil.tip"
        case .text: "textformat"
        case .pixelate: "square.grid.3x3.fill"
        }
    }
}

public enum AnnotationTextAlignment: String, CaseIterable, Sendable {
    case leading = "Leading", center = "Center", trailing = "Trailing"
}

/// Extended-range sRGB, matching UIKit: components outside 0–1 encode wider-gamut colors such as
/// Display P3. Rendering converts them to the output color space instead of rejecting them.
public struct StrokeColor: Equatable, Sendable {
    /// Display P3 and HDR picker colors stay well inside this finite range.
    public static let componentRange: ClosedRange<CGFloat> = -2...2
    public var red: CGFloat
    public var green: CGFloat
    public var blue: CGFloat
    public var alpha: CGFloat
    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) {
        self.red = red; self.green = green; self.blue = blue; self.alpha = alpha
    }
    /// Converts any Core Graphics color, bounding only components beyond the supported range.
    public init?(converting color: CGColor) {
        guard let space = CGColorSpace(name: CGColorSpace.extendedSRGB),
              let converted = color.converted(to: space, intent: .defaultIntent, options: nil),
              let components = converted.components, components.count == 4,
              components.allSatisfy(\.isFinite) else { return nil }
        let range = Self.componentRange
        // Conversion rounding (Display P3 white becomes 1.0000001) is not a wider color. Within half
        // an 8-bit step of the sRGB gamut, snap to its boundary so ordinary colors keep sRGB output.
        let snap: CGFloat = 0.5 / 255
        func bounded(_ value: CGFloat) -> CGFloat {
            if value < 0, value > -snap { return 0 }
            if value > 1, value < 1 + snap { return 1 }
            return min(range.upperBound, max(range.lowerBound, value))
        }
        self.init(red: bounded(components[0]), green: bounded(components[1]), blue: bounded(components[2]),
                  alpha: min(1, max(0, components[3])))
    }
    public static let red = StrokeColor(red: 1, green: 0.23, blue: 0.19)
    public var isOutsideSRGBGamut: Bool { [red, green, blue].contains { $0 < 0 || $0 > 1 } }
    public var cgColor: CGColor {
        CGColor(colorSpace: CGColorSpace(name: isOutsideSRGBGamut ? CGColorSpace.extendedSRGB : CGColorSpace.sRGB)!,
                components: [red, green, blue, alpha])!
    }
}

public struct Annotation: Identifiable, Equatable, Sendable {
    /// Imported images are limited to 100,000 pixels on either side.
    public static let maximumDimension: CGFloat = 100_000
    public let id: UUID
    public var kind: AnnotationKind
    public var points: [CGPoint]
    public var color: StrokeColor
    public var lineWidth: CGFloat
    public var text: String
    public var fontSize: CGFloat
    public var fillColor: StrokeColor?
    /// System uses Apple's platform font; named families are resolved by CoreText with its fallback.
    public var fontName: String
    public var bold: Bool
    public var italic: Bool
    public var underline: Bool
    public var textAlignment: AnnotationTextAlignment

    public init(id: UUID = UUID(), kind: AnnotationKind, points: [CGPoint],
                color: StrokeColor = .red, lineWidth: CGFloat = 8, text: String = "Label", fontSize: CGFloat = 48,
                fillColor: StrokeColor? = nil, fontName: String = "System", bold: Bool = false,
                italic: Bool = false, underline: Bool = false, textAlignment: AnnotationTextAlignment = .leading) {
        self.id = id; self.kind = kind; self.points = points; self.color = color
        self.lineWidth = lineWidth; self.text = text; self.fontSize = fontSize
        self.fillColor = fillColor; self.fontName = fontName; self.bold = bold
        self.italic = italic; self.underline = underline; self.textAlignment = textAlignment
    }

    public var bounds: CGRect {
        guard let first = points.first else { return .zero }
        var minX = first.x, minY = first.y, maxX = first.x, maxY = first.y
        for point in points {
            minX = min(minX, point.x); minY = min(minY, point.y)
            maxX = max(maxX, point.x); maxY = max(maxY, point.y)
        }
        return CGRect(x: minX, y: minY, width: max(1, maxX - minX), height: max(1, maxY - minY))
    }

    public func moved(by delta: CGSize) -> Self {
        var copy = self
        copy.points = points.map { CGPoint(x: $0.x + delta.width, y: $0.y + delta.height) }
        return copy
    }

    public func resized(to rect: CGRect) -> Self {
        let old = bounds
        guard [rect.origin.x, rect.origin.y, rect.width, rect.height,
               old.origin.x, old.origin.y, old.width, old.height].allSatisfy(\.isFinite) else { return self }
        let limit = Self.maximumDimension
        let bounded = CGRect(x: min(limit, max(-limit, rect.origin.x)),
                             y: min(limit, max(-limit, rect.origin.y)),
                             width: min(limit, max(1, rect.width)),
                             height: min(limit, max(1, rect.height)))
        var copy = self
        copy.points = points.map { CGPoint(x: bounded.minX + ($0.x - old.minX) / old.width * bounded.width,
                                          y: bounded.minY + ($0.y - old.minY) / old.height * bounded.height) }
        return copy
    }
}

public struct EditState: Equatable, Sendable {
    public var crop: CGRect
    public var annotations: [Annotation]
    public var preset: CropPreset
    public var rotation: ImageRotation
    public init(crop: CGRect, annotations: [Annotation] = [], preset: CropPreset = .freeform, rotation: ImageRotation = .none) {
        self.crop = crop; self.annotations = annotations; self.preset = preset; self.rotation = rotation
    }
}

/// Value-only history: undo never duplicates source pixels or preview images.
public struct EditHistory: Sendable {
    public private(set) var current: EditState
    private var past: [EditState] = []
    private var future: [EditState] = []
    public init(_ initial: EditState) { current = initial }
    public var canUndo: Bool { !past.isEmpty }
    public var canRedo: Bool { !future.isEmpty }
    public mutating func commit(_ state: EditState) {
        guard state != current else { return }
        past.append(current)
        if past.count > 100 { past.removeFirst() }
        current = state
        future.removeAll()
    }
    public mutating func undo() {
        guard let previous = past.popLast() else { return }
        future.append(current); current = previous
    }
    public mutating func redo() {
        guard let next = future.popLast() else { return }
        past.append(current); current = next
    }
}
