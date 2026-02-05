import SwiftUI

struct HorizontalMasonryLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let rows: Int
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    
    init(data: Data, rows: Int = 3, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.rows = max(1, rows)
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        // Partition data into rows
        let rowData: [[Data.Element]] = {
            var result = Array(repeating: [Data.Element](), count: rows)
            for (index, item) in data.enumerated() {
                result[index % rows].append(item)
            }
            return result
        }()
        
        return ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: spacing) {
                ForEach(0..<rows, id: \.self) { rowIndex in
                    HStack(spacing: spacing) {
                        ForEach(rowData[rowIndex], id: \.self) { item in
                            content(item)
                        }
                    }
                    .diagnosticBorder(.white.opacity(0.1), width: 0.5)
                }
            }
            .diagnosticBorder(.pink.opacity(0.2), width: 1)
            .padding(.trailing, 16)
        }
    }
}
