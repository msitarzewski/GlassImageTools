import Foundation
import CoreGraphics

/// Exact quarter-turns in a top-left pixel coordinate system; source geometry stays immutable.
public enum ImageRotation: Int, CaseIterable, Sendable {
    case none, left, upsideDown, right
    public var swapsAxes: Bool { rawValue.isMultiple(of: 2) == false }
    public var turnedLeft: ImageRotation {
        switch self { case .none: .left; case .left: .upsideDown; case .upsideDown: .right; case .right: .none }
    }
    public func size(for size: CGSize) -> CGSize {
        swapsAxes ? CGSize(width: size.height, height: size.width) : size
    }
    /// Maps the requested source region to an upright, rotated output starting at zero.
    public func transform(in region: CGRect) -> CGAffineTransform {
        let linear: CGAffineTransform
        switch self {
        case .none: linear = .identity
        case .left: linear = CGAffineTransform(a: 0, b: -1, c: 1, d: 0, tx: 0, ty: 0)
        case .upsideDown: linear = CGAffineTransform(a: -1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        case .right: linear = CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 0, ty: 0)
        }
        let projected = region.applying(linear)
        return linear.concatenating(CGAffineTransform(translationX: -projected.minX, y: -projected.minY))
    }
}

/// All editing geometry uses upright source pixels, with the origin at the top left.
public struct CanvasTransform: Sendable {
    public let bounds: CGRect
    public let scale: CGFloat
    public let origin: CGPoint
    public let rotation: ImageRotation
    public let affineTransform: CGAffineTransform

    public init(bounds: CGRect, viewport: CGSize, zoom: CGFloat = 1, pan: CGSize = .zero,
                rotation: ImageRotation = .none) {
        self.bounds = bounds
        self.rotation = rotation
        let size = rotation.size(for: bounds.size)
        let fit = min(max(1, viewport.width) / max(1, size.width),
                      max(1, viewport.height) / max(1, size.height))
        scale = fit * max(0.1, zoom)
        affineTransform = rotation.transform(in: bounds)
            .concatenating(CGAffineTransform(scaleX: scale, y: scale))
            .concatenating(CGAffineTransform(translationX: (viewport.width - size.width * scale) / 2 + pan.width,
                                             y: (viewport.height - size.height * scale) / 2 + pan.height))
        origin = CGPoint(x: affineTransform.tx, y: affineTransform.ty)
    }

    public func viewPoint(_ point: CGPoint) -> CGPoint { point.applying(affineTransform) }

    public func sourcePoint(_ point: CGPoint, clamped: Bool = false) -> CGPoint {
        let result = point.applying(affineTransform.inverted())
        return clamped ? CropGeometry.clamp(result, to: bounds) : result
    }

    public func viewRect(_ rect: CGRect) -> CGRect { rect.applying(affineTransform) }

    /// Rotation-aware drag delta, independent of translation or a moving handle's frame.
    public func sourceDelta(_ delta: CGSize) -> CGSize {
        let inverse = affineTransform.inverted()
        return CGSize(width: inverse.a * delta.width + inverse.c * delta.height,
                      height: inverse.b * delta.width + inverse.d * delta.height)
    }

    /// Screen corner labels remain stable while their source corners turn with the image.
    public func sourceCorner(for corner: CropCorner) -> CropCorner {
        let unit = CGRect(x: 0, y: 0, width: 1, height: 1)
        let point = corner.point(in: unit).applying(rotation.transform(in: unit).inverted())
        if point.y < 0.5 { return point.x < 0.5 ? .topLeft : .topRight }
        return point.x < 0.5 ? .bottomLeft : .bottomRight
    }

    /// Display-only proxy controls remain reachable and separated even for a tiny or partly
    /// offscreen selection. Its actual border and drag origin continue to use source pixels.
    /// Canvas padding accommodates the target's radius outside these viewport-edge centers.
    public func reachableControlRect(for selection: CGRect, viewport: CGSize, minimumSeparation: CGFloat = 60) -> CGRect {
        let projected = viewRect(selection)
        guard [projected.minX, projected.minY, projected.maxX, projected.maxY,
               viewport.width, viewport.height, minimumSeparation].allSatisfy(\.isFinite),
              viewport.width > 0, viewport.height > 0 else { return .zero }
        func span(_ first: CGFloat, _ last: CGFloat, limit: CGFloat) -> (origin: CGFloat, length: CGFloat) {
            let leading = min(limit, max(0, first))
            let trailing = min(limit, max(0, last))
            let length = min(limit, max(max(0, minimumSeparation), trailing - leading))
            let origin = min(limit - length, max(0, (leading + trailing - length) / 2))
            return (origin, length)
        }
        let horizontal = span(projected.minX, projected.maxX, limit: viewport.width)
        let vertical = span(projected.minY, projected.maxY, limit: viewport.height)
        return CGRect(x: horizontal.origin, y: vertical.origin, width: horizontal.length, height: vertical.length)
    }

    /// Separate short/coincident or clipped endpoints without changing the line's source points.
    /// Prefer the original direction; fall back to an available viewport axis when it cannot fit.
    public func endpointControls(start: CGPoint, end: CGPoint, viewport: CGSize,
                                 minimumSeparation: CGFloat = 60) -> (start: CGPoint, end: CGPoint) {
        let first = viewPoint(start), last = viewPoint(end)
        guard [first.x, first.y, last.x, last.y, viewport.width, viewport.height,
               minimumSeparation].allSatisfy(\.isFinite), viewport.width > 0, viewport.height > 0 else {
            return (.zero, .zero)
        }
        let visibleBounds = CGRect(origin: .zero, size: viewport)
        let clippedFirst = CropGeometry.clamp(first, to: visibleBounds)
        let clippedLast = CropGeometry.clamp(last, to: visibleBounds)
        let distance = hypot(clippedLast.x - clippedFirst.x, clippedLast.y - clippedFirst.y)
        let requested = max(0, minimumSeparation)
        if distance >= requested { return (clippedFirst, clippedLast) }
        let actualDistance = hypot(last.x - first.x, last.y - first.y)
        var direction = actualDistance > 0.000001
            ? CGPoint(x: (last.x - first.x) / actualDistance, y: (last.y - first.y) / actualDistance)
            : CGPoint(x: 1, y: 0)
        func available(_ direction: CGPoint) -> CGFloat {
            min(abs(direction.x) > 0.000001 ? viewport.width / abs(direction.x) : .infinity,
                abs(direction.y) > 0.000001 ? viewport.height / abs(direction.y) : .infinity)
        }
        if available(direction) < requested {
            if viewport.width >= requested {
                direction = CGPoint(x: direction.x < 0 ? -1 : 1, y: 0)
            } else if viewport.height >= requested {
                direction = CGPoint(x: 0, y: direction.y < 0 ? -1 : 1)
            } else {
                let diagonal = hypot(viewport.width, viewport.height)
                direction = CGPoint(x: viewport.width / diagonal * (direction.x < 0 ? -1 : 1),
                                    y: viewport.height / diagonal * (direction.y < 0 ? -1 : 1))
            }
        }
        let length = min(requested, available(direction))
        let center = CGPoint(x: (clippedFirst.x + clippedLast.x) / 2, y: (clippedFirst.y + clippedLast.y) / 2)
        var proxyFirst = CGPoint(x: center.x - direction.x * length / 2, y: center.y - direction.y * length / 2)
        var proxyLast = CGPoint(x: center.x + direction.x * length / 2, y: center.y + direction.y * length / 2)
        let minX = min(proxyFirst.x, proxyLast.x), maxX = max(proxyFirst.x, proxyLast.x)
        let minY = min(proxyFirst.y, proxyLast.y), maxY = max(proxyFirst.y, proxyLast.y)
        let shift = CGSize(width: minX < 0 ? -minX : maxX > viewport.width ? viewport.width - maxX : 0,
                           height: minY < 0 ? -minY : maxY > viewport.height ? viewport.height - maxY : 0)
        proxyFirst.x += shift.width; proxyFirst.y += shift.height
        proxyLast.x += shift.width; proxyLast.y += shift.height
        return (proxyFirst, proxyLast)
    }

    /// A reveal operation changes only the view's pan; source/edit/history values stay untouched.
    public func centeringDelta(for selection: CGRect, viewport: CGSize) -> CGSize {
        let center = viewPoint(CGPoint(x: selection.midX, y: selection.midY))
        guard [center.x, center.y, viewport.width, viewport.height].allSatisfy(\.isFinite) else { return .zero }
        return CGSize(width: viewport.width / 2 - center.x, height: viewport.height / 2 - center.y)
    }
}

public enum CropPreset: String, CaseIterable, Sendable {
    case freeform = "Freeform", square = "1:1", wide = "16:9", photo = "4:3"
    public var ratio: CGFloat? {
        switch self {
        case .freeform: nil
        case .square: 1
        case .wide: 16.0 / 9.0
        case .photo: 4.0 / 3.0
        }
    }
}

public enum CropCorner: CaseIterable, Sendable {
    case topLeft, topRight, bottomLeft, bottomRight
    public var left: Bool { self == .topLeft || self == .bottomLeft }
    public var top: Bool { self == .topLeft || self == .topRight }
    public func point(in rect: CGRect) -> CGPoint {
        CGPoint(x: left ? rect.minX : rect.maxX, y: top ? rect.minY : rect.maxY)
    }
}

public enum CropGeometry {
    public static func clamp(_ point: CGPoint, to bounds: CGRect) -> CGPoint {
        CGPoint(x: min(bounds.maxX, max(bounds.minX, point.x)),
                y: min(bounds.maxY, max(bounds.minY, point.y)))
    }

    /// Round outwards once, at the pixel boundary. The same rectangle drives UI dimensions and export.
    public static func pixelAligned(_ rect: CGRect, in bounds: CGRect) -> CGRect {
        guard [rect.minX, rect.minY, rect.maxX, rect.maxY, rect.width, rect.height,
               bounds.minX, bounds.minY, bounds.maxX, bounds.maxY, bounds.width, bounds.height].allSatisfy(\.isFinite),
              bounds.width >= 1, bounds.height >= 1 else { return .zero }
        let clipped = rect.standardized.intersection(bounds)
        guard !clipped.isNull, clipped.width > 0, clipped.height > 0 else { return .zero }
        let x = max(bounds.minX, floor(clipped.minX))
        let y = max(bounds.minY, floor(clipped.minY))
        return CGRect(x: x, y: y, width: min(bounds.maxX, ceil(clipped.maxX)) - x,
                      height: min(bounds.maxY, ceil(clipped.maxY)) - y)
    }

    public static func preset(_ preset: CropPreset, inside rect: CGRect, rotation: ImageRotation = .none) -> CGRect {
        guard let requested = preset.ratio else { return rect }
        let ratio = rotation.swapsAxes ? 1 / requested : requested
        let width = min(rect.width, rect.height * ratio)
        let height = width / ratio
        return CGRect(x: rect.midX - width / 2, y: rect.midY - height / 2, width: width, height: height)
    }

    public static func moved(_ rect: CGRect, by delta: CGSize, in bounds: CGRect) -> CGRect {
        CGRect(x: min(max(bounds.minX, rect.minX + delta.width), bounds.maxX - rect.width),
               y: min(max(bounds.minY, rect.minY + delta.height), bounds.maxY - rect.height),
               width: rect.width, height: rect.height)
    }

    public static func resized(_ rect: CGRect, corner: CropCorner, by delta: CGSize,
                               in bounds: CGRect, ratio: CGFloat? = nil) -> CGRect {
        let anchor = CGPoint(x: corner.left ? rect.maxX : rect.minX,
                             y: corner.top ? rect.maxY : rect.minY)
        let maxWidth = max(1, corner.left ? anchor.x - bounds.minX : bounds.maxX - anchor.x)
        let maxHeight = max(1, corner.top ? anchor.y - bounds.minY : bounds.maxY - anchor.y)
        var width = min(maxWidth, max(1, rect.width + delta.width * (corner.left ? -1 : 1)))
        var height = min(maxHeight, max(1, rect.height + delta.height * (corner.top ? -1 : 1)))
        if let ratio, ratio > 0 {
            if abs(delta.width) >= abs(delta.height) * ratio { height = width / ratio }
            else { width = height * ratio }
            let shrink = min(1, maxWidth / width, maxHeight / height)
            width *= shrink
            height *= shrink
        }
        return CGRect(x: corner.left ? anchor.x - width : anchor.x,
                      y: corner.top ? anchor.y - height : anchor.y, width: width, height: height)
    }
}
