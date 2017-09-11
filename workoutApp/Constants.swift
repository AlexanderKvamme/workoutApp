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
        static let muscle = "Undefined"
        static let exerciseType = "Normal"
        static let measurement = "Sets"
    }
    
    enum exampleValues {
        static let exampleMuscles = ["Undefined", "Arms", "Back", "Legs", "Glutes", "Shoulders", "Core"]
        static let workoutStyles = ["Normal", "Drop Set", "Superset", "Cardio", "For fun"]
        static let exerciseStyles = ["Normal", "Assisted", "Weighted", "Slow", "Explosive", "Inclined"]
        static let measurementStyles = ["Timer", "Countdown", "Sets"]
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
        
        enum Box {
            static let spacingFromSides: CGFloat = 10
            static let shimmerInset: CGFloat = 7
            
            enum Standard {
                static let height = standardBoxHeight
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
        }
        
        enum PickerLabelStack {
            static let height: CGFloat = 150
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
