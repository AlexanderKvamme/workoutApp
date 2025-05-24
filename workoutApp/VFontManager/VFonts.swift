//
//  VFonts.swift
//  AKKIT
//
//  Created by Alexander Kvamme on 17/12/2022.
//

import Foundation
import VFont


public struct VFonts {
    
    public static let defaultFontSize: CGFloat = 24.0
    
    // MARK: - VFont accessors
    
//    public static func anyBody(size: CGFloat = defaultFontSize) -> VFont {
//        AnybodyFont(size: size)
//    }
//    
//    public static func crimson(size: CGFloat = defaultFontSize) -> VFont {
//        CrimsonFont(size: size)
//    }
//    
//    public static func epilogue(size: CGFloat = defaultFontSize) -> VFont {
//        EpilogueFont(size: size)
//    }
//    
//    public static func faustina(size: CGFloat = defaultFontSize) -> VFont {
//        FaustinaFont(size: size)
//    }
    
    public static func inter(size: CGFloat = defaultFontSize) -> VFont {
        Inter(size: size)
    }
    
    public static func elza(size: CGFloat = defaultFontSize, boldness: CGFloat = 400) -> VFont {
        Elza(size: size, boldness: boldness)
    }
    
    public static func sono(size: CGFloat = defaultFontSize, monoSpaceness: CGFloat, boldness: CGFloat? = nil) -> VFont {
        Sono(size: size, monoSpaceness: monoSpaceness, boldness: boldness ?? 100)
    }
    
//    public static func all(size: CGFloat = defaultFontSize) -> [VFont] {
//        [Self.anyBody(size: size),
//         Self.crimson(size: size),
//         Self.epilogue(size: size),
//         Self.faustina(size: size),
//         Self.inter(size: size),
//         Self.sono(size: size)]
//    }
}

public final class Inter: VFont {

    public init(size: CGFloat) {
        let name = "Inter"
        super.init(name: name, size: size)!
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public final class Elza : VFont {
    public init(size: CGFloat, boldness: CGFloat = 400) {
        let name = "Elza Round Variable"
        super.init(name: name, size: size)!
        let weightAxis = 2003265652 // Standard weight axis ID
        self.setValue(boldness, forAxisID: weightAxis)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public final class Sono: VFont {

    public init(size: CGFloat, monoSpaceness: CGFloat = 1.0, boldness: CGFloat = 100) {
        let name = "Sono"
        super.init(name: name, size: size)!
        let monoSpaceAxisId = 1297043023
        let weightAxis = 2003265652
        self.setValue(1.0, forAxisID: monoSpaceAxisId) // 0.0...0.1
        self.setValue(boldness, forAxisID: weightAxis)
        print(
            self.getAxesDescription()
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

