//
//  VFTextViewAnimatorView.swift
//  flashcardsApp
//
//  Created by Alexander Kvamme on 09/03/2025.
//

import SwiftUI
import VFont // Ensure you import the VFont library

// Wrapper for VFTextViewAnimator
struct VFTextViewAnimatorWrapper: UIViewControllerRepresentable {
    
    // Create the UIViewController instance
    func makeUIViewController(context: Context) -> VFTextViewAnimator {
        let animatorVC = VFTextViewAnimator() // Initialize your VFTextViewAnimator here
        return animatorVC
    }
    
    // Update the UIViewController if needed
    func updateUIViewController(_ uiViewController: VFTextViewAnimator, context: Context) {
        // Call the animate function with the provided parameters
        uiViewController.animateWordInTextView()
    }
}

// Preview for SwiftUI Canvas
struct VFTextViewAnimatorWrapper_Previews: PreviewProvider {
    static var previews: some View {
        VFTextViewAnimatorWrapper()
            .edgesIgnoringSafeArea(.all) // Optional: to extend the view to the edges
    }
}
