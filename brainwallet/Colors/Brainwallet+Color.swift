import SwiftUI
import UIKit

/// Brainwallet Color
/// Matches the scheme in Android and matches behavior in the Asset Catalog
// cheddar: Color { // FFAE00
// brainwalletGray: Color { // B8B8B8
// pesto: Color { // 25AA2C
// midnight: Color { // 0F0853
// grape: Color { // 402DAE
// chili: Color { // CE3025
// brainwalletBlue: UIColor { // 2968F2

struct BrainwalletColor {
    /// surface - midnight or white
    static let surface: Color = Color("brainwalletSurface")
    /// background - Lavender
    static let background: Color = Color("brainwalletBackground")
    /// background -- white or midnight
    static let content: Color = Color("brainwalletContent")
    /// background - NearBorder
    static let border: Color = Color("brainwalletBorder")
    /// info - blue
    static let info: Color = Color("brainwalletInfo")
    /// affirm - pesto
    static let affirm: Color = Color("brainwalletAffirm")
    /// warn - cheddar
    static let warn: Color = Color("brainwalletWarn")
    /// error - chili
    static let error: Color = Color("brainwalletError")
    /// gray - gray
    static let gray: Color = Color("brainwalletGray")
    
    /// Static theme colors
    static let midnight = Color(#colorLiteral(red: 0.07334695011, green: 0.07277505845, blue: 0.4002133608, alpha: 1))
    static let cheddar = Color(#colorLiteral(red: 1, green: 0.6823529412, blue: 0, alpha: 1))
    static let lavender = Color(#colorLiteral(red: 0.8666666667, green: 0.8352941176, blue: 0.9803921569, alpha: 1))
    static let pesto = Color(#colorLiteral(red: 0.1450980392, green: 0.6666666667, blue: 0.1725490196, alpha: 1))
    static let grape = Color(#colorLiteral(red: 0.2509803922, green: 0.1764705882, blue: 0.6823529412, alpha: 1))
    static let chili = Color(#colorLiteral(red: 0.8078431373, green: 0.1882352941, blue: 0.1450980392, alpha: 1))
    static let blue = Color(#colorLiteral(red: 0.1607843137, green: 0.4078431373, blue: 0.9490196078, alpha: 1))
    static let nearBlack = Color(#colorLiteral(red: 0.08235294118, green: 0.08235294118, blue: 0.08235294118, alpha: 1))
}

struct BrainwalletUIColor {
    /// surface - midnight or white
    static let surface: UIColor = UIColor(Color("brainwalletSurface"))
    /// background - Lavender
    static let background: UIColor = UIColor(Color("brainwalletBackground"))
    /// background -- white or midnight
    static let content: UIColor = UIColor(Color("brainwalletContent"))
    /// background - NearBlack
    static let border: UIColor = UIColor(Color("brainwalletBorder"))
    /// info - blue
    static let info: UIColor = UIColor(Color("brainwalletInfo"))
    /// affirm - pesto
    static let affirm: UIColor = UIColor(Color("brainwalletAffirm"))
    /// warn - cheddar
    static let warn: UIColor = UIColor(Color("brainwalletWarn"))
    /// error - chili
    static let error: UIColor = UIColor(Color("brainwalletError"))
    /// gray - gray
    static let gray: UIColor = UIColor(Color("brainwalletGray"))
    /// Static theme colors
    static let midnight = UIColor(#colorLiteral(red: 0.07334695011, green: 0.07277505845, blue: 0.4002133608, alpha: 1))
    static let cheddar = UIColor(#colorLiteral(red: 1, green: 0.6823529412, blue: 0, alpha: 1))
    static let lavender = UIColor(#colorLiteral(red: 0.8666666667, green: 0.8352941176, blue: 0.9803921569, alpha: 1))
    static let pesto = UIColor(#colorLiteral(red: 0.1450980392, green: 0.6666666667, blue: 0.1725490196, alpha: 1))
    static let grape = UIColor(#colorLiteral(red: 0.2509803922, green: 0.1764705882, blue: 0.6823529412, alpha: 1))
    static let chili = UIColor(#colorLiteral(red: 0.8078431373, green: 0.1882352941, blue: 0.1450980392, alpha: 1))
    static let blue = UIColor(#colorLiteral(red: 0.1607843137, green: 0.4078431373, blue: 0.9490196078, alpha: 1))
    static let nearBlack = UIColor(#colorLiteral(red: 0.08235294118, green: 0.08235294118, blue: 0.08235294118, alpha: 1))
}
