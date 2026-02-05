import SwiftUI

/// A container view that arranges its children in a flow layout (wrapping to the next line).
struct FlowLayout<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    let data: Data
    let id: KeyPath<Data.Element, ID>
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    @State private var totalHeight: CGFloat = .zero

    /// Initializer for data with a custom ID keypath (like ForEach)
    init(data: Data, id: KeyPath<Data.Element, ID>, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.id = id
        self.spacing = spacing
        self.content = content
    }
    
    /// Convenience initializer for Hashable data (id is \.self)
    init(data: Data, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) where Data.Element: Hashable, ID == Data.Element {
        self.data = data
        self.id = \.self
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(data, id: id) { item in
                self.content(item)
                    .padding([.horizontal, .vertical], spacing / 2)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if let lastItem = self.data.last {
                            let itemID = item[keyPath: self.id]
                            let lastID = lastItem[keyPath: self.id]
                            if itemID == lastID {
                                width = 0
                            } else {
                                width -= d.width
                            }
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if let lastItem = self.data.last {
                            let itemID = item[keyPath: self.id]
                            let lastID = lastItem[keyPath: self.id]
                            if itemID == lastID {
                                height = 0
                            }
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
