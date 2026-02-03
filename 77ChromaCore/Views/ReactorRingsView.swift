//
//  ReactorRingsView.swift
//  77ChromaCore
//

import SwiftUI

struct ReactorRingsView: View {
    let rings: [[ReactorSegment]]
    let selectedRingIndex: Int?
    var lockedRingIndex: Int? = nil
    let onRotateRing: (Int, Bool) -> Void
    var onSelectRing: ((Int?) -> Void)?
    
    @State private var touchedRingIndex: Int? = nil
    
    private let minReactorSize: CGFloat = 120
    
    var body: some View {
        GeometryReader { geo in
            let rawSize = min(geo.size.width, geo.size.height)
            let size = max(minReactorSize, rawSize)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            ZStack {
                ForEach(Array(rings.enumerated().reversed()), id: \.offset) { ringIndex, ring in
                    ringView(ring: ring, ringIndex: ringIndex, size: size, center: center, isTouched: touchedRingIndex == ringIndex, isLocked: lockedRingIndex == ringIndex)
                }
                coreView(size: size, center: center)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        if touchedRingIndex == nil {
                            touchedRingIndex = ringAt(point: value.startLocation, size: size, center: center)
                        }
                    }
                    .onEnded { value in
                        defer { touchedRingIndex = nil }
                        guard let r = ringAt(point: value.startLocation, size: size, center: center) else { return }
                        let dx = value.translation.width
                        let dy = value.translation.height
                        let distance = sqrt(dx * dx + dy * dy)
                        if distance < 25 {
                            onRotateRing(r, true)
                        } else {
                            onRotateRing(r, dx > 0)
                        }
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func ringView(ring: [ReactorSegment], ringIndex: Int, size: CGFloat, center: CGPoint, isTouched: Bool = false, isLocked: Bool = false) -> some View {
        let counts = ReactorConfig.ringCounts
        let count = counts[ringIndex]
        let baseR = ringRadius(ringIndex: ringIndex, size: size)
        let innerR = max(4, baseR - 22)
        let outerR = max(innerR + 8, baseR + 22)
        let frameSize = max(16, outerR * 2)
        let isSelected = selectedRingIndex == ringIndex
        let strokeColor: Color = isLocked ? ChromaTheme.balancing : (isTouched ? ChromaTheme.stable : (isSelected ? ChromaTheme.balancing : Color.white.opacity(0.2)))
        let strokeWidth: CGFloat = (isTouched || isSelected || isLocked) ? 4 : ChromaTheme.ringStrokeWidth
        return ZStack {
            ForEach(Array(ring.enumerated()), id: \.element.id) { index, segment in
                segmentShape(
                    segment: segment,
                    index: index,
                    count: count,
                    innerR: innerR,
                    outerR: outerR,
                    center: center
                )
            }
            Circle()
                .stroke(strokeColor, lineWidth: strokeWidth)
                .frame(width: frameSize, height: frameSize)
                .position(center)
                .shadow(color: strokeColor.opacity(0.4), radius: 4, x: 0, y: 2)
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(ChromaTheme.balancing)
                    .shadow(color: ChromaTheme.balancing.opacity(0.6), radius: 6)
                    .position(center)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func segmentShape(segment: ReactorSegment, index: Int, count: Int, innerR: CGFloat, outerR: CGFloat, center: CGPoint) -> some View {
        let angleStep = 2 * CGFloat.pi / CGFloat(count)
        let startAngle = Angle(radians: Double(angleStep * CGFloat(index)) - .pi / 2)
        let endAngle = Angle(radians: Double(angleStep * CGFloat(index + 1)) - .pi / 2)
        let c = segment.energyType.color
        let segmentGradient = LinearGradient(
            colors: [c.opacity(0.9), c, c.opacity(0.75)],
            startPoint: .top,
            endPoint: .bottom
        )
        return SegmentArc(
            startAngle: startAngle,
            endAngle: endAngle,
            innerRadius: innerR,
            outerRadius: outerR,
            center: center,
            color: c,
            isActive: segment.isActive
        )
        .fill(segmentGradient)
        .overlay {
            SegmentArc(startAngle: startAngle, endAngle: endAngle, innerRadius: innerR, outerRadius: outerR, center: center, color: .clear, isActive: false)
                .stroke(c.opacity(0.4), lineWidth: 1)
        }
        .shadow(color: c.opacity(0.5), radius: segment.isActive ? 8 : 3, x: 0, y: 2)
        .opacity(segment.isActive ? 1 : ChromaTheme.segmentOpacity)
        .overlay {
            if segment.isActive {
                SegmentArc(startAngle: startAngle, endAngle: endAngle, innerRadius: innerR, outerRadius: outerR, center: center, color: .clear, isActive: true)
                    .stroke(Color.white, lineWidth: 2)
            }
        }
    }
    
    private func ringRadius(ringIndex: Int, size: CGFloat) -> CGFloat {
        let maxR = max(60, size / 2 - 40)
        switch ringIndex {
        case 0: return maxR * 0.25
        case 1: return maxR * 0.50
        case 2: return maxR * 0.85
        default: return maxR * 0.5
        }
    }
    
    private func ringAt(point: CGPoint, size: CGFloat, center: CGPoint) -> Int? {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let r = sqrt(dx * dx + dy * dy)
        let maxR = max(60, size / 2 - 40)
        if r < maxR * 0.35 { return 0 }
        if r < maxR * 0.65 { return 1 }
        if r < maxR + 30 { return 2 }
        return nil
    }
    
    private func coreView(size: CGFloat, center: CGPoint) -> some View {
        let coreSize = size * 0.2
        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ChromaTheme.balancing.opacity(0.95),
                            ChromaTheme.balancing.opacity(0.7),
                            ChromaTheme.background
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: coreSize * 0.5
                    )
                )
                .frame(width: coreSize, height: coreSize)
                .position(center)
                .shadow(color: ChromaTheme.balancing.opacity(0.8), radius: ChromaTheme.glowRadius, x: 0, y: 0)
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [ChromaTheme.balancing, ChromaTheme.balancing.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: coreSize, height: coreSize)
                .position(center)
        }
    }
}

struct SegmentArc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var innerRadius: CGFloat
    var outerRadius: CGFloat
    var center: CGPoint
    var color: Color
    var isActive: Bool
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let innerStart = CGPoint(
            x: center.x + innerRadius * cos(CGFloat(startAngle.radians)),
            y: center.y + innerRadius * sin(CGFloat(startAngle.radians))
        )
        let outerStart = CGPoint(
            x: center.x + outerRadius * cos(CGFloat(startAngle.radians)),
            y: center.y + outerRadius * sin(CGFloat(startAngle.radians))
        )
        p.move(to: innerStart)
        p.addArc(center: center, radius: innerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        p.addLine(to: CGPoint(
            x: center.x + outerRadius * cos(CGFloat(endAngle.radians)),
            y: center.y + outerRadius * sin(CGFloat(endAngle.radians))
        ))
        p.addArc(center: center, radius: outerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        p.closeSubpath()
        return p
    }
}

#Preview {
    ZStack {
        ChromaTheme.background.ignoresSafeArea()
        ReactorRingsView(
            rings: ReactorCore.createInitialRings(),
            selectedRingIndex: nil,
            lockedRingIndex: nil,
            onRotateRing: { _, _ in },
            onSelectRing: nil
        )
        .padding(40)
    }
}
