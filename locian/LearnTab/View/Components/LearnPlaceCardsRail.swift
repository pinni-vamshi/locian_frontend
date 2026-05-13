import SwiftUI

struct LearnPlaceCardsRail: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var pinControlOn = false

    let recommendations: [PlaceRecommendation]
    let activeRecommendation: PlaceRecommendation?
    let isFetchingData: Bool
    let selectedRecommendationIndex: Int
    let screenEdgePadding: CGFloat
    let animateIn: Bool
    let onSelectRecommendation: (Int) -> Void

    var body: some View {
        GeometryReader { geo in
            let railW = geo.size.width
            let railH = geo.size.height
            let hSpacing = learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 14)
            let minChipW = learnScaled(100, hSizeClass: horizontalSizeClass, min: 100, max: 130)
            let usableW = railW - hSpacing
            let detailSide = min(railH, max(0, usableW - minChipW))
            let chipColumnWidth = usableW - detailSide

            HStack(alignment: .center, spacing: hSpacing) {
                placeDetailPanel
                    .frame(width: detailSide, height: detailSide, alignment: .topLeading)
                placeChipColumn
                    .frame(width: chipColumnWidth)
            }
            .frame(width: railW, height: railH, alignment: .center)
        }
        .diagnosticBorder(.yellow.opacity(0.7), width: 1, style: .dashed)
        .opacity(animateIn ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.1), value: animateIn)
        .onChange(of: activeRecommendation?.place_id) { _, _ in
            pinControlOn = false
        }
    }

    private var placeChipColumn: some View {
        GeometryReader { colGeo in
            let totalH = colGeo.size.height
            let totalW = colGeo.size.width
            let topH = totalH * 0.62
            let chipSide = max(learnScaled(52, hSizeClass: horizontalSizeClass, min: 52, max: 66), min(topH, totalW * 0.42))

            VStack(spacing: 0) {
                horizontalPlaceChipsScroll(chipSide: chipSide, topH: topH)

                let placeName = activeRecommendation?.place_id.capitalized ?? "here"
                Text("your context at \(placeName)")
                    .font(learnFont(size: 18, weight: .black, hSizeClass: horizontalSizeClass))
                    .foregroundColor(Color(white: 0.4))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .background(Color.clear)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 1)
                    }
                    .layoutPriority(0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .diagnosticBorder(.yellow, width: 1)
    }

    @ViewBuilder
    private func horizontalPlaceChipsScroll(chipSide: CGFloat, topH: CGFloat) -> some View {
        let scroll = ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 14)) {
                if isFetchingData && recommendations.isEmpty {
                    ForEach(0..<3, id: \.self) { _ in
                        skeletonPlaceChip(side: chipSide)
                    }
                }
                ForEach(Array(recommendations.enumerated()), id: \.1.id) { index, rec in
                    placeChip(rec: rec, index: index, side: chipSide)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: topH, alignment: .center)

        scroll
    }

    private func skeletonPlaceChip(side: CGFloat) -> some View {
        VStack(spacing: 6) {
            Rectangle().fill(Color(white: 0.75)).frame(width: learnScaled(20, hSizeClass: horizontalSizeClass, min: 20, max: 26), height: learnScaled(20, hSizeClass: horizontalSizeClass, min: 20, max: 26))
            Rectangle().fill(Color(white: 0.8)).frame(width: learnScaled(40, hSizeClass: horizontalSizeClass, min: 40, max: 52), height: learnScaled(8, hSizeClass: horizontalSizeClass, min: 8, max: 10))
        }
        .frame(width: side, height: side)
        .background(Color.white)
        .opacity(0.5)
    }

    private func placeChip(rec: PlaceRecommendation, index: Int, side: CGFloat) -> some View {
        let isSelected = selectedRecommendationIndex == index

        return Button(action: {
            onSelectRecommendation(index)
        }) {
            VStack(spacing: 6) {
                Image(systemName: CategoryUI.icon(for: rec.place_id))
                    .font(.system(size: learnScaled(24, hSizeClass: horizontalSizeClass, min: 24, max: 30), weight: .light))
                    .foregroundColor(isSelected ? ThemeColors.secondaryAccent : .black)
                Text(rec.place_id.uppercased())
                    .font(learnFont(size: 8, weight: .black, hSizeClass: horizontalSizeClass))
                    .foregroundColor(isSelected ? ThemeColors.secondaryAccent : .black)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(width: side, height: side)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .strokeBorder(
                        isSelected ? ThemeColors.secondaryAccent : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func placeNameStack(for rec: PlaceRecommendation) -> some View {
        let trimmedName = rec.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let pid = rec.place_id.trimmingCharacters(in: .whitespacesAndNewlines)
        let pidLower = pid.lowercased()

        VStack(alignment: .leading, spacing: 4) {
            if !trimmedName.isEmpty {
                Text(trimmedName)
                    .font(learnFont(size: 15, weight: .bold, hSizeClass: horizontalSizeClass))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .truncationMode(.tail)
                if trimmedName.lowercased() != pidLower {
                    Text(pid.uppercased())
                        .font(learnFont(size: 9, weight: .bold, hSizeClass: horizontalSizeClass))
                        .foregroundColor(.white.opacity(0.72))
                        .kerning(0.9)
                        .lineLimit(1)
                }
            } else {
                Text(pid.capitalized)
                    .font(learnFont(size: 15, weight: .bold, hSizeClass: horizontalSizeClass))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
        }
    }

    @ViewBuilder
    private var placeDetailPanel: some View {
        if let rec = activeRecommendation {
            VStack(alignment: .leading, spacing: 0) {
                    // Full-width row: category icon (left) · Pin (right, placeholder tap)
                    HStack(alignment: .center, spacing: 0) {
                        Image(systemName: CategoryUI.icon(for: rec.place_id))
                            .font(.system(size: learnScaled(24, hSizeClass: horizontalSizeClass, min: 24, max: 30), weight: .light))
                            .foregroundColor(.white)
                            .frame(minWidth: learnScaled(32, hSizeClass: horizontalSizeClass, min: 32, max: 40), minHeight: learnScaled(32, hSizeClass: horizontalSizeClass, min: 32, max: 40), alignment: .leading)

                        Spacer(minLength: 8)

                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            pinControlOn.toggle()
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: learnScaled(12, hSizeClass: horizontalSizeClass, min: 12, max: 16), weight: .semibold))
                                Text("Pin")
                                    .font(learnFont(size: 11, weight: .bold, hSizeClass: horizontalSizeClass))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                            }
                            .foregroundColor(pinControlOn ? ThemeColors.secondaryAccent : .white)
                            .padding(.horizontal, learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 14))
                            .padding(.vertical, learnScaled(6, hSizeClass: horizontalSizeClass, min: 6, max: 8))
                            .background(pinControlOn ? Color.white : Color.white.opacity(0.2))
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, learnScaled(10, hSizeClass: horizontalSizeClass, min: 10, max: 14))

                    placeNameStack(for: rec)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 4)

                    // Score
                    VStack(alignment: .leading, spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 2)
                                Rectangle()
                                    .fill(.white)
                                    .frame(width: max(0, geo.size.width * rec.confidence), height: 2)
                            }
                        }
                        .frame(height: 2)

                        Text("\(Int(rec.confidence * 100))% MATCH")
                            .font(learnFont(size: 9, weight: .bold, hSizeClass: horizontalSizeClass))
                            .foregroundColor(.white.opacity(0.85))
                            .kerning(1.4)
                            .lineLimit(1)
                    }
            }
            .padding(learnScaled(9, hSizeClass: horizontalSizeClass, min: 9, max: 12))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(ThemeColors.secondaryAccent)
            .clipped()
            .id(rec.id)
            .transition(.opacity)
            .contentShape(Rectangle())
        } else {
            VStack(spacing: 6) {
                Image(systemName: "hand.point.right")
                    .font(.system(size: learnScaled(16, hSizeClass: horizontalSizeClass, min: 16, max: 20), weight: .light))
                    .foregroundColor(Color(white: 0.3))
                Text("SELECT A PLACE")
                    .font(learnFont(size: 9, weight: .bold, hSizeClass: horizontalSizeClass))
                    .foregroundColor(Color(white: 0.35))
                    .kerning(1.5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(white: 0.055))
            .overlay(Rectangle().stroke(Color(white: 0.13), lineWidth: 1))
        }
    }
}
