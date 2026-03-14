import SwiftUI

/// A grid that arranges its children in rows, justifying each row to fill the available width perfectly.
/// This creates a solid "brick wall" effect where the left and right edges are perfectly aligned.
struct JustifiedBrickGrid<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let rows: Int
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    
    init(data: Data, rows: Int = 10, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.rows = max(1, rows)
        self.spacing = spacing
        self.content = content
    }
    
    @State private var gridWidth: CGFloat = 300 // Default fallback

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            let rowPiles = partitionIntoRows(totalWidth: gridWidth)
            
            ForEach(0..<rowPiles.count, id: \.self) { rowIndex in
                let rowItems = rowPiles[rowIndex]
                
                HStack(spacing: spacing) {
                    let rowWidth = calculateRowWidth(rowItems)
                    let extraSpace = gridWidth - rowWidth - (CGFloat(max(0, rowItems.count - 1)) * spacing)
                    // ALWAYS JUSTIFY EVERY ROW FOR A PERFECT RECTANGLE
                    let expansionPerItem = rowItems.count > 0 ? (extraSpace / CGFloat(rowItems.count)) : 0
                    
                    ForEach(rowItems, id: \.self) { item in
                        content(item)
                            .frame(width: estimateWidth(item) + expansionPerItem)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { gridWidth = geo.size.width }
                    .onChange(of: geo.size.width) { _, newWidth in gridWidth = newWidth }
            }
        )
    }
    
    // MARK: - Internal Logic
    
    /// Groups data into rows based on the available width
    private func partitionIntoRows(totalWidth: CGFloat) -> [[Data.Element]] {
        var rowsList: [[Data.Element]] = []
        var currentRow: [Data.Element] = []
        var currentX: CGFloat = 0
        
        for item in data {
            let itemWidth = estimateWidth(item)
            
            // If the item doesn't fit in the current row (plus spacing)
            if !currentRow.isEmpty && (currentX + spacing + itemWidth) > totalWidth {
                rowsList.append(currentRow)
                currentRow = [item]
                currentX = itemWidth
            } else {
                if !currentRow.isEmpty {
                    currentX += spacing
                }
                currentRow.append(item)
                currentX += itemWidth
            }
            
            // Limit to the requested number of rows
            if rowsList.count >= rows { break }
        }
        
        // Add the last row if we haven't reached the limit
        if !currentRow.isEmpty && rowsList.count < rows {
            rowsList.append(currentRow)
        }
        
        return rowsList
    }
    
    private func calculateRowWidth(_ items: [Data.Element]) -> CGFloat {
        return items.reduce(0) { $0 + estimateWidth($1) }
    }
    
    /// Estimates width based on text content. 
    /// This is an approximation since we can't easily measure views inside the partition logic.
    private func estimateWidth(_ item: Data.Element) -> CGFloat {
        let text: String
        if let place = item as? LocationManager.NearbyAmbience {
            text = place.name.uppercased()
        } else if let str = item as? String {
            text = str.uppercased()
        } else {
            return 80 // Fallback
        }
        
        // Approx: 8px per character for monospaced 12pt + 20px horizontal padding (10 left, 10 right)
        return CGFloat(text.count) * 7.5 + 24
    }
}
