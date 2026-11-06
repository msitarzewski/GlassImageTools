import Testing
import Foundation
import CoreGraphics
@testable import VisionSnipCore

@Suite struct GeometryTests {
    let image = CGRect(x: 0, y: 0, width: 8000, height: 4000)

    @Test func aspectFitAccountsForLetterboxing() {
        let transform = CanvasTransform(bounds: image, viewport: CGSize(width: 1000, height: 1000))
        #expect(transform.scale == 0.125)
        #expect(transform.viewPoint(.zero) == CGPoint(x: 0, y: 250))
        #expect(transform.sourcePoint(CGPoint(x: 500, y: 500)) == CGPoint(x: 4000, y: 2000))
        #expect(transform.sourcePoint(.zero, clamped: true) == .zero)
        let controls = transform.reachableControlRect(for: image, viewport: CGSize(width: 1000, height: 1000))
        #expect(CropCorner.topLeft.point(in: controls) == transform.viewPoint(.zero))
    }

    @Test(arguments: [CGFloat(1), 1.5, 3, 8])
    func croppedZoomAndPanRoundTrip(zoom: CGFloat) {
        let crop = CGRect(x: 1200, y: 700, width: 3000, height: 1700)
        let transform = CanvasTransform(bounds: crop, viewport: CGSize(width: 972, height: 651),
                                        zoom: zoom, pan: CGSize(width: 57, height: -82))
        for point in [crop.origin, CGPoint(x: crop.midX, y: crop.midY), CGPoint(x: crop.maxX, y: crop.maxY)] {
            let restored = transform.sourcePoint(transform.viewPoint(point))
            #expect(abs(restored.x - point.x) < 0.000001)
            #expect(abs(restored.y - point.y) < 0.000001)
        }
    }

    @Test(arguments: [CGFloat(1.5), 3, 8])
    func zoomedCropCornersRemainReachableWithoutMovingTheirSourceBoundary(zoom: CGFloat) {
        let viewport = CGSize(width: 1000, height: 700)
        let transform = CanvasTransform(bounds: image, viewport: viewport, zoom: zoom,
                                        pan: CGSize(width: 57, height: -82))
        let controls = transform.reachableControlRect(for: image, viewport: viewport)
        #expect(controls.width >= 60 && controls.height >= 60)
        for corner in CropCorner.allCases {
            let sourceCorner = corner.point(in: image)
            let control = corner.point(in: controls)
            #expect(control.x >= 0 && control.x <= viewport.width)
            #expect(control.y >= 0 && control.y <= viewport.height)
            let restored = transform.sourcePoint(transform.viewPoint(sourceCorner))
            #expect(abs(restored.x - sourceCorner.x) < 0.000001)
            #expect(abs(restored.y - sourceCorner.y) < 0.000001)
        }
        #expect(transform.viewRect(image).width > viewport.width)
    }

    @Test func pinnedControlsStayFiniteForTinyViewportsAndExtremePan() {
        let viewport = CGSize(width: 24, height: 20)
        let transform = CanvasTransform(bounds: image, viewport: viewport, zoom: 8,
                                        pan: CGSize(width: 1_000_000, height: -1_000_000))
        #expect(transform.reachableControlRect(for: image, viewport: viewport)
            == CGRect(origin: .zero, size: viewport))
    }

    @Test func tinyAndPartlyOffscreenCropsKeepAllFourControlsSeparated() {
        let bounds = CGRect(x: 0, y: 0, width: 1000, height: 800)
        let viewport = bounds.size
        let cases = [
            (CGRect(x: 400, y: 300, width: 1, height: 1), CGSize.zero),
            (CGRect(x: 10, y: 200, width: 25, height: 4), CGSize(width: -30, height: -202))
        ]
        for (crop, pan) in cases {
            let transform = CanvasTransform(bounds: bounds, viewport: viewport, pan: pan)
            let controls = transform.reachableControlRect(for: crop, viewport: viewport)
            let points = CropCorner.allCases.map { $0.point(in: controls) }
            for (index, point) in points.enumerated() {
                #expect(point.x >= 0 && point.x <= viewport.width)
                #expect(point.y >= 0 && point.y <= viewport.height)
                for other in points.dropFirst(index + 1) {
                    #expect(hypot(point.x - other.x, point.y - other.y) >= 60)
                }
            }
            // Spacing is presentation only: even an expanded proxy changes the real corner by
            // exactly the two source pixels dragged and leaves its opposite anchor untouched.
            let resized = CropGeometry.resized(crop, corner: .bottomRight,
                by: transform.sourceDelta(CGSize(width: 2, height: 2)), in: bounds)
            #expect(resized.minX == crop.minX && resized.minY == crop.minY)
            #expect(resized.width == crop.width + 2 && resized.height == crop.height + 2)
        }
    }

    @Test(arguments: CropCorner.allCases)
    func aSmallPinnedCornerDragResizesFromItsOriginalBoundaryWithoutJumping(corner: CropCorner) {
        let viewport = CGSize(width: 1000, height: 700)
        let transform = CanvasTransform(bounds: image, viewport: viewport, zoom: 8,
                                        pan: CGSize(width: 57, height: -82))
        let sourceCorner = corner.point(in: image)
        let control = corner.point(in: transform.reachableControlRect(for: image, viewport: viewport))
        #expect(hypot(control.x - transform.viewPoint(sourceCorner).x,
                      control.y - transform.viewPoint(sourceCorner).y) > 100)
        let delta = transform.sourceDelta(CGSize(width: corner.left ? 2 : -2, height: corner.top ? 3 : -3))
        let resized = CropGeometry.resized(image, corner: corner, by: delta, in: image)
        #expect(resized.width == image.width - 2)
        #expect(resized.height == image.height - 3)
        let opposite = CGPoint(x: corner.left ? resized.maxX : resized.minX,
                               y: corner.top ? resized.maxY : resized.minY)
        #expect(opposite == CGPoint(x: corner.left ? image.maxX : image.minX,
                                    y: corner.top ? image.maxY : image.minY))
        #expect(image.contains(resized))
    }

    @Test func zoomedPanCropResizePreservesPresetAndUndoRedo() {
        let original = EditState(crop: CropGeometry.preset(.wide, inside: image), preset: .wide)
        let transform = CanvasTransform(bounds: image, viewport: CGSize(width: 1000, height: 700),
                                        zoom: 3, pan: CGSize(width: -137, height: 91))
        var changed = original
        changed.crop = CropGeometry.resized(original.crop, corner: .topLeft,
            by: transform.sourceDelta(CGSize(width: 45, height: 20)), in: image, ratio: original.preset.ratio)
        #expect(abs(changed.crop.width / changed.crop.height - 16.0 / 9.0) < 0.000001)
        #expect(changed.crop.maxX == original.crop.maxX)
        #expect(changed.crop.maxY == original.crop.maxY)
        #expect(changed.crop.width == original.crop.width - 120)
        var history = EditHistory(original)
        history.commit(changed)
        history.undo(); #expect(history.current == original)
        history.redo(); #expect(history.current == changed)
        #expect(history.current.preset == .wide)
    }

    @Test(arguments: CropCorner.allCases)
    func onePixelAnnotationProxyResizeKeepsItsOppositeAnchorAndUndo(corner: CropCorner) {
        let annotation = Annotation(kind: .rectangle, points: [CGPoint(x: 4000, y: 2000), CGPoint(x: 4001, y: 2001)])
        let original = EditState(crop: image, annotations: [annotation])
        let transform = CanvasTransform(bounds: image, viewport: CGSize(width: 1000, height: 700),
                                        zoom: 8, pan: CGSize(width: 1800, height: -950))
        let controls = transform.reachableControlRect(for: annotation.bounds, viewport: CGSize(width: 1000, height: 700))
        #expect(controls.width >= 60 && controls.height >= 60)
        let delta = transform.sourceDelta(CGSize(width: corner.left ? -2 : 2, height: corner.top ? -2 : 2))
        let resized = CropGeometry.resized(annotation.bounds, corner: corner, by: delta, in: image)
        #expect(resized.width == 3 && resized.height == 3)
        #expect((corner.left ? resized.maxX : resized.minX) == (corner.left ? annotation.bounds.maxX : annotation.bounds.minX))
        #expect((corner.top ? resized.maxY : resized.minY) == (corner.top ? annotation.bounds.maxY : annotation.bounds.minY))
        var changed = original; changed.annotations[0] = annotation.resized(to: resized)
        var history = EditHistory(original)
        history.commit(changed)
        history.undo(); #expect(history.current == original)
        history.redo(); #expect(history.current == changed)
    }

    @Test func shortCoincidentAndEdgeEndpointsRemainSeparatedWithoutChangingTheirSourcePoints() {
        let viewport = CGSize(width: 1000, height: 700)
        let pairs = [
            (CGPoint(x: 100, y: 100), CGPoint(x: 101, y: 100)),
            (CGPoint(x: 100, y: 100), CGPoint(x: 100, y: 101)),
            (CGPoint(x: 101, y: 101), CGPoint(x: 100, y: 100)),
            (CGPoint(x: 100, y: 100), CGPoint(x: 100, y: 100)),
            (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
        ]
        for pan in [CGSize.zero, CGSize(width: 1800, height: -950)] {
            let transform = CanvasTransform(bounds: image, viewport: viewport, zoom: 3, pan: pan)
            for (start, end) in pairs {
                let controls = transform.endpointControls(start: start, end: end, viewport: viewport)
                #expect(hypot(controls.end.x - controls.start.x, controls.end.y - controls.start.y) >= 60 - 0.000001)
                for point in [controls.start, controls.end] {
                    #expect(point.x >= -0.000001 && point.x <= viewport.width + 0.000001)
                    #expect(point.y >= -0.000001 && point.y <= viewport.height + 0.000001)
                }
                // Editing an offset endpoint uses only the stable source delta, never the proxy's
                // screen position. Its opposite endpoint survives and one Undo restores both.
                let annotation = Annotation(kind: .line, points: [start, end])
                let original = EditState(crop: image, annotations: [annotation])
                let delta = transform.sourceDelta(CGSize(width: 3, height: 3))
                var moved = annotation
                moved.points[0] = CropGeometry.clamp(CGPoint(x: start.x + delta.width, y: start.y + delta.height), to: image)
                #expect(moved.points[0] == CGPoint(x: start.x + 8, y: start.y + 8))
                #expect(moved.points[1] == end)
                var changed = original; changed.annotations[0] = moved
                var history = EditHistory(original)
                history.commit(changed)
                history.undo(); #expect(history.current == original)
                history.redo(); #expect(history.current == changed)
            }
        }
    }

    @Test func usableEndpointsKeepTheirActualPositionsAndNarrowViewportsHaveFiniteFallbacks() {
        let bounds = CGRect(x: 0, y: 0, width: 1000, height: 800)
        let transform = CanvasTransform(bounds: bounds, viewport: bounds.size)
        let start = CGPoint(x: 100, y: 100), end = CGPoint(x: 500, y: 100)
        let ordinary = transform.endpointControls(start: start, end: end, viewport: bounds.size)
        #expect(ordinary.start == start && ordinary.end == end)
        let narrow = transform.endpointControls(start: start, end: CGPoint(x: 101, y: 100), viewport: CGSize(width: 24, height: 800))
        #expect(abs(narrow.start.y - narrow.end.y) == 60)
        #expect(narrow.start.x >= 0 && narrow.end.x <= 24)
        let tiny = transform.endpointControls(start: start, end: start, viewport: CGSize(width: 24, height: 20))
        #expect(tiny.start == .zero)
        #expect(abs(tiny.end.x - 24) < 0.000001 && abs(tiny.end.y - 20) < 0.000001)
    }

    @Test(arguments: [CGFloat(1), 3, 8])
    func revealingASelectionCentersTheViewAtItsExistingZoom(zoom: CGFloat) {
        let crop = CGRect(x: 1200, y: 700, width: 3000, height: 1700)
        let selection = CGRect(x: 3600, y: 900, width: 1, height: 1)
        let viewport = CGSize(width: 972, height: 651)
        let pan = CGSize(width: 57, height: -82)
        let transform = CanvasTransform(bounds: crop, viewport: viewport, zoom: zoom, pan: pan)
        let delta = transform.centeringDelta(for: selection, viewport: viewport)
        let revealed = CanvasTransform(bounds: crop, viewport: viewport, zoom: zoom,
            pan: CGSize(width: pan.width + delta.width, height: pan.height + delta.height))
        #expect(revealed.scale == transform.scale)
        let center = revealed.viewPoint(CGPoint(x: selection.midX, y: selection.midY))
        #expect(abs(center.x - viewport.width / 2) < 0.000001)
        #expect(abs(center.y - viewport.height / 2) < 0.000001)
        #expect(revealed.bounds == crop)
    }

    @Test func cropIsClippedAndSnappedOnlyToSourcePixels() {
        let rect = CGRect(x: -5.7, y: 20.3, width: 100.1, height: 4000)
        #expect(CropGeometry.pixelAligned(rect, in: image) == CGRect(x: 0, y: 20, width: 95, height: 3980))
        #expect(CropGeometry.pixelAligned(CGRect(x: 9000, y: 0, width: 20, height: 20), in: image) == .zero)
        #expect(CropGeometry.pixelAligned(CGRect(x: CGFloat.nan, y: 0, width: 20, height: 20), in: image) == .zero)
    }

    @Test(arguments: CropPreset.allCases)
    func presetFitsAndIsCentered(preset: CropPreset) {
        let crop = CropGeometry.preset(preset, inside: image)
        #expect(image.contains(crop))
        #expect(crop.midX == image.midX && crop.midY == image.midY)
        if let ratio = preset.ratio { #expect(abs(crop.width / crop.height - ratio) < 0.000001) }
    }

    @Test(arguments: CropCorner.allCases)
    func cornerResizeHonorsAnchorBoundsAndRatio(corner: CropCorner) {
        let crop = CGRect(x: 1000, y: 1000, width: 1600, height: 900)
        let resized = CropGeometry.resized(crop, corner: corner,
            by: CGSize(width: corner.left ? -20_000 : 20_000, height: corner.top ? -10_000 : 10_000),
            in: image, ratio: 16.0 / 9.0)
        #expect(image.contains(resized))
        #expect(abs(resized.width / resized.height - 16.0 / 9.0) < 0.000001)
        #expect((corner.left ? resized.maxX : resized.minX) == (corner.left ? crop.maxX : crop.minX))
        #expect((corner.top ? resized.maxY : resized.minY) == (corner.top ? crop.maxY : crop.minY))
    }

    @Test func moveClampsWithoutChangingSize() {
        let crop = CGRect(x: 100, y: 200, width: 600, height: 400)
        #expect(CropGeometry.moved(crop, by: CGSize(width: -500, height: 20_000), in: image)
            == CGRect(x: 0, y: 3600, width: 600, height: 400))
    }

    @Test func historyCoalescesNoOpsAndInvalidatesRedo() {
        let first = EditState(crop: image)
        var second = first; second.crop.size.width = 3000
        var third = second; third.annotations = [Annotation(kind: .rectangle, points: [.zero, CGPoint(x: 30, y: 40)])]
        var history = EditHistory(first)
        history.commit(first); #expect(!history.canUndo)
        history.commit(second); history.commit(third)
        history.undo(); #expect(history.current == second)
        history.undo(); #expect(history.current == first)
        history.redo(); #expect(history.current == second)
        history.commit(first); #expect(!history.canRedo)
    }

    @Test func annotationMoveResizeAndRecropKeepSourceCoordinates() {
        let annotation = Annotation(kind: .arrow, points: [CGPoint(x: 200, y: 300), CGPoint(x: 800, y: 500)])
        let moved = annotation.moved(by: CGSize(width: 50, height: -30))
        #expect(moved.points == [CGPoint(x: 250, y: 270), CGPoint(x: 850, y: 470)])
        #expect(moved.id == annotation.id)
        let resized = annotation.resized(to: CGRect(x: 100, y: 100, width: 300, height: 100))
        #expect(resized.points == [CGPoint(x: 100, y: 100), CGPoint(x: 400, y: 200)])
        var state = EditState(crop: image, annotations: [annotation])
        state.crop = CGRect(x: 100, y: 200, width: 1000, height: 1000)
        #expect(state.annotations[0] == annotation)
    }

    @Test func annotationResizeBoundsExtremeInspectorValuesAndRejectsNonFiniteGeometry() {
        let annotation = Annotation(kind: .rectangle, points: [.zero, CGPoint(x: 30, y: 40)])
        let resized = annotation.resized(to: CGRect(x: 0, y: 0, width: CGFloat(Int.max), height: 40))
        #expect(resized.bounds.width == Annotation.maximumDimension)
        #expect(Int(exactly: resized.bounds.width) != nil)
        #expect(annotation.resized(to: CGRect(x: CGFloat.nan, y: 0, width: 30, height: 40)) == annotation)
        #expect(CropGeometry.pixelAligned(CGRect(x: 0, y: 0, width: CGFloat.infinity, height: 20), in: image) == .zero)
    }

    @Test func undoAndRedoRestoreTheCropAspectConstraint() {
        let first = EditState(crop: image)
        let constrained = EditState(crop: CropGeometry.preset(.wide, inside: image), preset: .wide)
        var history = EditHistory(first)
        history.commit(constrained)
        history.undo()
        #expect(history.current.preset == .freeform && history.current.crop == image)
        history.redo()
        #expect(history.current == constrained)
    }

}
