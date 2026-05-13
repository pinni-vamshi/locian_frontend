//
//  LearnCoachTour.swift
//  locian
//
//  Learn-tab coach tour: layout anchors → preference frames → overlay spotlight.
//
//  State (front → back):
//  - **Persistence** (`UserDefaults` via `@AppStorage`): `learnCoachTour_userSawIntro_v1` — after any full
//    completion (Skip or Done), suppresses the automatic first-launch offer only.
//  - **Session** (`@State` on `LearnTabView`): `sessionScheduledAutoCoachTour` — auto-offer at most once per
//    cold launch so leaving/returning the tab does not reschedule.
//  - **Settings replay** (`AppStateManager`): monotonic `learnCoachTourManualTrigger` plus
//    `learnCoachTourManualTriggerPresentedUpTo` — Learn presents when trigger increases, then records the
//    value it satisfied so tab switches do not re-open the same request.
//

import SwiftUI

// MARK: - Layout

enum LearnCoachTourLayout {
    /// Dimming veil strength outside the spotlight.
    static let dimmerOpacity: CGFloat = 0.94
}

// MARK: - Anchors (keys into the preference map)

enum LearnCoachTourAnchor: String, CaseIterable {
    case placeRail
    case brickHeader
    case sentenceStrip
    case transformationGraph
    case startLearning
}

// MARK: - Frame reporting

struct LearnCoachTourFramesKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        let next = nextValue()
        for (k, v) in next {
            value[k] = v
        }
    }
}

extension View {
    /// Reports this view’s bounds in **global** space so the overlay `GeometryReader` always aligns with
    /// the spotlight, regardless of `NavigationStack` / safe-area / overlay sizing mismatches.
    func learnCoachTourHighlight(_ anchor: LearnCoachTourAnchor) -> some View {
        background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: LearnCoachTourFramesKey.self,
                    value: [anchor.rawValue: geo.frame(in: .global)]
                )
            }
        )
    }
}

// MARK: - Script

private struct LearnCoachTourStep: Identifiable {
    var id: String { anchor.rawValue }
    let anchor: LearnCoachTourAnchor
    let title: String
    let message: String

    static let script: [LearnCoachTourStep] = [
        .init(
            anchor: .placeRail,
            title: "Nearby Places",
            message: "Swipe the chips, tap a place. Change it anytime."
        ),
        .init(
            anchor: .brickHeader,
            title: "Script & graph",
            message: "Aa / 文 = native vs target. Toggle word vs sentence when it appears."
        ),
        .init(
            anchor: .sentenceStrip,
            title: "Words",
            message: "Tap a word in the sentence to focus it."
        ),
        .init(
            anchor: .transformationGraph,
            title: "Graph",
            message: "Follow how the focused word changes along the chain."
        ),
        .init(
            anchor: .startLearning,
            title: "Start",
            message: "Hold it to start your lesson."
        )
    ]
}

// MARK: - Overlay

struct LearnCoachTourOverlayView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var isPresented: Bool
    let frames: [String: CGRect]
    var onCompleted: () -> Void

    @State private var stepIndex = 0

    private var steps: [LearnCoachTourStep] { LearnCoachTourStep.script }
    private var current: LearnCoachTourStep {
        steps[min(stepIndex, max(steps.count - 1, 0))]
    }
    private var isLastStep: Bool { stepIndex >= steps.count - 1 }

    private var highlightPad: CGFloat {
        learnScaled(14, hSizeClass: horizontalSizeClass, min: 12, max: 18)
    }

    private var bracketLineHeight: CGFloat {
        learnScaled(3.5, hSizeClass: horizontalSizeClass, min: 3, max: 5)
    }

    /// `anchorRect` must already be in the same coordinate space as `geo` (we use overlay-local = reader space).
    private func spotlightHole(anchorRect: CGRect, in full: CGSize) -> CGRect {
        guard anchorRect.width > 1, anchorRect.height > 1 else { return .zero }
        let p = highlightPad
        let raw = CGRect(
            x: anchorRect.midX - (anchorRect.width + p) / 2,
            y: anchorRect.midY - (anchorRect.height + p) / 2,
            width: anchorRect.width + p,
            height: anchorRect.height + p
        )
        return raw.intersection(CGRect(origin: .zero, size: full))
    }

    var body: some View {
        GeometryReader { geo in
            let safe = geo.safeAreaInsets
            let full = geo.size
            let readerGlobal = geo.frame(in: .global)
            let anchorGlobal = frames[current.anchor.rawValue] ?? .zero
            let anchorLocal: CGRect = {
                guard anchorGlobal.width > 0.5, anchorGlobal.height > 0.5 else { return .zero }
                return CGRect(
                    x: anchorGlobal.minX - readerGlobal.minX,
                    y: anchorGlobal.minY - readerGlobal.minY,
                    width: anchorGlobal.width,
                    height: anchorGlobal.height
                )
            }()
            let hole = spotlightHole(anchorRect: anchorLocal, in: full)

            ZStack(alignment: .topLeading) {
                tourDimmerWithHole(size: full, hole: hole)
                    .zIndex(0)

                if anchorLocal.width > 1, anchorLocal.height > 1 {
                    let hLine = bracketLineHeight
                    let w = full.width
                    let gap = learnScaled(8, hSizeClass: horizontalSizeClass, min: 6, max: 12)
                    let tabReserve = learnScaled(72, hSizeClass: horizontalSizeClass, min: 64, max: 88)
                    let estCaptionHeight = learnScaled(240, hSizeClass: horizontalSizeClass, min: 180, max: 300)
                    let spaceBelow = full.height - hole.maxY - hLine - gap - max(safe.bottom, tabReserve * 0.45) - tabReserve * 0.55
                    let spaceAbove = hole.minY - hLine - gap - safe.top
                    let placeBelow: Bool = {
                        if spaceBelow >= estCaptionHeight { return true }
                        if spaceAbove >= estCaptionHeight { return false }
                        return spaceBelow >= spaceAbove
                    }()
                    let guideTop = hole.minY - hLine - gap
                    let raw = placeBelow ? max(0, spaceBelow - 6) : max(0, spaceAbove - 10)
                    let cap = learnScaled(320, hSizeClass: horizontalSizeClass, min: 240, max: 380)
                    let baseScrollMaxH = min(cap, max(raw, learnScaled(72, hSizeClass: horizontalSizeClass, min: 64, max: 84)))
                    let scrollMaxH = placeBelow
                        ? baseScrollMaxH
                        : min(
                            baseScrollMaxH,
                            max(spaceAbove - 2, learnScaled(56, hSizeClass: horizontalSizeClass, min: 48, max: 64))
                        )
                    let captionTop: CGFloat = {
                        if placeBelow {
                            let y = hole.maxY + hLine + gap
                            let maxY = full.height - scrollMaxH - max(safe.bottom, 8)
                            return min(y, max(0, maxY))
                        }
                        return max(safe.top + 4, guideTop - scrollMaxH - 4)
                    }()

                    Rectangle()
                        .fill(ThemeColors.secondaryAccent)
                        .frame(width: w, height: hLine)
                        .offset(x: 0, y: hole.minY - hLine)
                        .allowsHitTesting(false)
                        .zIndex(1)
                    Rectangle()
                        .fill(ThemeColors.secondaryAccent)
                        .frame(width: w, height: hLine)
                        .offset(x: 0, y: hole.maxY)
                        .allowsHitTesting(false)
                        .zIndex(1)

                    ScrollView(.vertical, showsIndicators: false) {
                        tourCaptionStrip(safe: safe, placeBelow: placeBelow)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(width: w, height: scrollMaxH, alignment: .top)
                    .offset(x: 0, y: captionTop)
                    .zIndex(2)
                } else {
                    Color.clear
                        .frame(width: full.width, height: full.height)
                        .allowsHitTesting(false)
                        .overlay(alignment: .bottom) {
                            tourCaptionStrip(safe: safe, placeBelow: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear {
            stepIndex = 0
        }
    }

    @ViewBuilder
    private func tourCaptionStrip(safe: EdgeInsets, placeBelow: Bool) -> some View {
        let hPad = learnScaled(14, hSizeClass: horizontalSizeClass, min: 12, max: 18)
        let bottomPad = placeBelow
            ? learnScaled(8, hSizeClass: horizontalSizeClass, min: 6, max: 12) + safe.bottom
            : learnScaled(6, hSizeClass: horizontalSizeClass, min: 4, max: 10)

        VStack(alignment: .leading, spacing: learnScaled(6, hSizeClass: horizontalSizeClass, min: 5, max: 8)) {
            Text(current.title)
                .font(learnFont(size: 16, weight: .bold, hSizeClass: horizontalSizeClass))
                .foregroundColor(.white.opacity(0.92))

            Text(current.message)
                .font(learnFont(size: 14, weight: .regular, hSizeClass: horizontalSizeClass))
                .foregroundColor(Color(white: 0.72))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .center, spacing: learnScaled(10, hSizeClass: horizontalSizeClass, min: 8, max: 14)) {
                Text("\(stepIndex + 1) / \(steps.count)")
                    .font(learnFont(size: 12, weight: .medium, hSizeClass: horizontalSizeClass))
                    .foregroundColor(Color(white: 0.4))

                Spacer(minLength: 0)

                Button("Skip") {
                    finish()
                }
                .font(learnFont(size: 17, weight: .semibold, hSizeClass: horizontalSizeClass))
                .foregroundColor(Color(white: 0.6))
                .padding(.horizontal, learnScaled(16, hSizeClass: horizontalSizeClass, min: 14, max: 20))
                .padding(.vertical, learnScaled(10, hSizeClass: horizontalSizeClass, min: 8, max: 12))
                .buttonStyle(.plain)

                Button(isLastStep ? "Done" : "Next") {
                    if isLastStep {
                        finish()
                    } else {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.easeInOut(duration: 0.22)) {
                            stepIndex += 1
                        }
                    }
                }
                .font(learnFont(size: 17, weight: .bold, hSizeClass: horizontalSizeClass))
                .foregroundColor(ThemeColors.secondaryAccent)
                .padding(.horizontal, learnScaled(16, hSizeClass: horizontalSizeClass, min: 14, max: 20))
                .padding(.vertical, learnScaled(10, hSizeClass: horizontalSizeClass, min: 8, max: 12))
                .buttonStyle(.plain)
            }
            .padding(.top, learnScaled(2, hSizeClass: horizontalSizeClass, min: 0, max: 4))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, hPad)
        .padding(.bottom, bottomPad)
    }

    /// Single full-screen veil with a **punched** hole (`destinationOut`) so there are no hairline gaps
    /// between dark and bright regions (unlike stacked `HStack`/`VStack` bands).
    @ViewBuilder
    private func tourDimmerWithHole(size: CGSize, hole: CGRect) -> some View {
        let opacity = LearnCoachTourLayout.dimmerOpacity
        let w = max(size.width, 1)
        let h = max(size.height, 1)

        if hole.width <= 1 || hole.height <= 1 || hole.isEmpty {
            Color.black.opacity(opacity)
                .frame(width: w, height: h)
        } else {
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(opacity))
                Rectangle()
                    .fill(Color.white)
                    .frame(width: max(hole.width, 1), height: max(hole.height, 1))
                    .position(x: hole.midX, y: hole.midY)
                    .blendMode(.destinationOut)
            }
            .frame(width: w, height: h)
            .compositingGroup()
            // Transparent cutout passes touches to the Learn UI; veil is visual-only.
            .allowsHitTesting(false)
        }
    }

    private func finish() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isPresented = false
        onCompleted()
    }
}
