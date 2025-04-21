import UIKit

//class ViewController: UIViewController {
//    
//    private var scrollView: UIScrollView!
//    private var gridView: StaggeredHexGridView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Setup scroll view
//        scrollView = UIScrollView(frame: view.bounds)
//        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.addSubview(scrollView)
//        
//        // Sample data for buttons (matching your screenshot)
//        let buttonData: [(number: String, title: String, subtitle: String)] = [
//            ("3", "walk 15 min", "daily"),
//            ("5", "meditate", "weekly"),
//            ("2", "run 5k", "weekly"),
//            ("1", "stretch", "daily"),
//            ("4", "swim", "weekly"),
//            ("6", "bike ride", "monthly"),
//            ("9", "strength", "daily"),
//            ("...", "dance", "weekly"),
//            ("...", "boxing", "monthly")
//        ]
//        
//        // Calculate grid size
//        let buttonSize = CGSize(width: 110, height: 110)
//        let spacing: CGFloat = 30 // Larger spacing to match your screenshot
//        
//        // Create grid view with estimated size
//        gridView = StaggeredHexGridView(
//            frame: CGRect(x: 10, y: 10, width: view.bounds.width - 20, height: 600),
//            buttonSize: buttonSize,
//            spacing: spacing
//        )
//        
//        // Setup grid
//        gridView.setupGrid(data: buttonData)
//        
//        // Add to scroll view
//        scrollView.addSubview(gridView)
//        scrollView.contentSize = CGSize(
//            width: gridView.frame.width,
//            height: gridView.frame.height + 100 // Add extra space at bottom
//        )
//    }
//}
