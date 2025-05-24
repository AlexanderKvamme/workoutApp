//
//  VFScreen.swift
//  flashcardsApp
//
//  Created by Alexander Kvamme on 09/03/2025.
//

import SwiftUI


struct VFScreen: UIViewControllerRepresentable {
    
    // This function creates the UIViewController instance
    func makeUIViewController(context: Context) -> VFontShowcaseVC {
        let showcaseVC = VFontShowcaseVC()
        return showcaseVC
    }
    
    // This function updates the UIViewController if needed
    func updateUIViewController(_ uiViewController: VFontShowcaseVC, context: Context) {
        // Update the UI if necessary
    }
}
