import UIKit



class StaggeredHexGridView: UIView {
    
    private var buttons: [HexagonalButton] = []
    private let buttonSize: CGSize
    private let spacing: CGFloat
    
    init(frame: CGRect, buttonSize: CGSize, spacing: CGFloat) {
        self.buttonSize = buttonSize
        self.spacing = spacing
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        self.buttonSize = CGSize(width: 110, height: 110)
        self.spacing = 20
        super.init(coder: coder)
    }
    
    func setupGrid(data: [(number: String, title: String, subtitle: String)]) {
        // Remove existing buttons
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        
        // Constants for layout
        let hexWidth = buttonSize.width
        let hexHeight = buttonSize.height
        
        // Calculate spacing between hexagons (centers)
        let horizontalSpacing = hexWidth + spacing
        let verticalSpacing = hexHeight + spacing
        
        // Calculate how many columns we can fit in a row
        let columnsPerRow = 3 // Based on your screenshot
        
        // Calculate total rows needed
        let totalRows = Int(ceil(Double(data.count) / Double(columnsPerRow)))
        
        var dataIndex = 0
        
        for row in 0..<totalRows {
            // Determine if this is an even or odd row for offset
            let isOddRow = row % 2 == 1
            
            // Calculate how many columns for this row
            let columnsInThisRow = min(columnsPerRow, data.count - dataIndex)
            
            for column in 0..<columnsInThisRow {
                // Calculate position based on row and column
                // Odd rows are offset to the right
                let xOffset = isOddRow ? horizontalSpacing / 2 : 0
                let x = xOffset + CGFloat(column) * horizontalSpacing
                let y = CGFloat(row) * verticalSpacing * 0.75 // Reduce vertical spacing for better interlocking
                
                // Create button
                let button = HexagonalButton(frame: CGRect(
                    x: x,
                    y: y,
                    width: hexWidth,
                    height: hexHeight
                ))
                
                // Configure with data
                let buttonData = data[dataIndex]
                button.configure(
                    number: buttonData.number,
                    title: buttonData.title,
                    subtitle: buttonData.subtitle
                )
                
                // Add button
                button.tag = dataIndex
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                addSubview(button)
                buttons.append(button)
                
                dataIndex += 1
                
                // Break if we've used all data
                if dataIndex >= data.count {
                    break
                }
            }
        }
        
        // Calculate content size
        let contentWidth = CGFloat(columnsPerRow) * horizontalSpacing
        let contentHeight = CGFloat(totalRows) * verticalSpacing * 0.75 + hexHeight * 0.25
        
        // Update frame if needed
        if frame.size.width < contentWidth || frame.size.height < contentHeight {
            frame.size = CGSize(width: max(frame.width, contentWidth),
                               height: max(frame.height, contentHeight))
        }
    }
    
    @objc private func buttonTapped(_ sender: HexagonalButton) {
        print("Button tapped: \(sender.tag)")
        // You can add a delegate method here to handle button taps
    }
}
