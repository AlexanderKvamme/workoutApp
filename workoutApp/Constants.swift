//
//  Constants.swift
//  workoutApp
//
//  Created by Alexander Kvamme on 12/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Fileprivate

fileprivate let standardBoxWidth: CGFloat = UIScreen.main.bounds.width - 2*Constant.components.Box.spacingFromSides
fileprivate let standardBoxHeight: CGFloat = 80

// MARK: - Globals

enum Constant {
    
    enum defaultValues {
        static let muscle = "OTHER"
        static let exerciseType = "NORMAL"
        static let measurement = "SETS"
    }
    
    enum UI {
        static let width = UIScreen.main.bounds.width
        static let height = UIScreen.main.bounds.height
    }
    
    enum alpha {
        static let faded: CGFloat = 0.5
    }
    
    enum Attributes {
        enum letterSpacing {
            case medium
            case more
        }
    }
    
    enum ViewControllers {
        enum exericeseTable {
            static let verticalSpacing: CGFloat = 50
        }
    }
    
    enum coreData {
        static let name = "workoutApp"
    }
    
    enum components {
        
        enum headers {
            enum pickerHeader {
                static var topSpacing: CGFloat = 100
            }
        }
        
        enum footer {
            static var height: CGFloat = 65
        }
        
        enum collectionViewCells {
            static let width: CGFloat = 50
            static let weightedHeight: CGFloat = 80
            static let unweightedHeight: CGFloat = 50
        }
        
        enum Box {
            
            static let spacingFromSides: CGFloat = 10
            static let shimmerInset: CGFloat = 7
            
            enum Standard {
                static let height = standardBoxHeight
                static let width = standardBoxWidth
            }
            
            enum StandardWeighted {
                static let height = standardBoxHeight + 100
                static let width = standardBoxWidth
            }
            
            enum History {
                static let width = standardBoxWidth
                static let height = standardBoxHeight
            }
            enum Selection {
                static let width: CGFloat = Constant.UI.width/2
                static let height: CGFloat = 60
            }
            enum ExerciseProgress {
                static let width: CGFloat = standardBoxWidth
                static let height: CGFloat = 50
            }
            
            enum TallExerciseProgress {
                static let width: CGFloat = standardBoxWidth
                static let height: CGFloat = Constant.components.collectionViewCells.weightedHeight
            }
        }
        
        enum PickerLabelStack {
            static let height: CGFloat = 90
        }
        
        enum SelectionVC {
            enum Header {
                static let spacingTop: CGFloat = 100
            }
            
            enum Stack {
                static let spacing: CGFloat = 15
            }
        }
        
        enum exerciseTableCells {
            static let fontWhenSelected = UIFont.custom(style: .bold, ofSize: .big)
            static let fontWhenDeselected = UIFont.custom(style: .bold, ofSize: .medium)
            static let textColorWhenSelected = UIColor.darkest
            static let textColorWhenDeselected = UIColor.faded
        }
    }
    
    enum Animation {
        static let pickerVCsShouldAnimateIn = true
        static let pickerVCsShouldAnimateOut = true
    }
}
