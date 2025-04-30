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
    static let surface: Color = Color("brainwalletSurface")
    static let background: Color = Color("brainwalletBackground")
    static let content: Color = Color("brainwalletContent")
    static let border: Color = Color("brainwalletBorder")
    static let info: Color = Color("brainwalletInfo")
    static let affirm: Color = Color("brainwalletAffirm")
    static let warn: Color = Color("brainwalletWarn")
    static let error: Color = Color("brainwalletError")
    static let gray: Color = Color("brainwalletGray")
    
    ///Static theme colors
    static let midnight = Color(#colorLiteral(red: 0.07334695011, green: 0.07277505845, blue: 0.4002133608, alpha: 1))
    static let cheddar = Color(#colorLiteral(red: 1, green: 0.6823529412, blue: 0, alpha: 1))
    static let pesto = Color(#colorLiteral(red: 0.1450980392, green: 0.6666666667, blue: 0.1725490196, alpha: 1))
    static let grape = Color(#colorLiteral(red: 0.2509803922, green: 0.1764705882, blue: 0.6823529412, alpha: 1))
    static let chili = Color(#colorLiteral(red: 0.8078431373, green: 0.1882352941, blue: 0.1450980392, alpha: 1))
    static let blue = Color(#colorLiteral(red: 0.1607843137, green: 0.4078431373, blue: 0.9490196078, alpha: 1))
    static let nearBlack = Color(#colorLiteral(red: 0.08235294118, green: 0.08235294118, blue: 0.08235294118, alpha: 1))
}

struct BrainwalletUIColor {
    static let surface: UIColor = UIColor(Color("brainwalletSurface"))
    static let background: UIColor = UIColor(Color("brainwalletBackground"))
    static let content: UIColor = UIColor(Color("brainwalletContent"))
    static let border: UIColor = UIColor(Color("brainwalletBorder"))
    static let info: UIColor = UIColor(Color("brainwalletInfo"))
    static let affirm: UIColor = UIColor(Color("brainwalletAffirm"))
    static let warn: UIColor = UIColor(Color("brainwalletWarn"))
    static let error: UIColor = UIColor(Color("brainwalletError"))
    static let gray: UIColor = UIColor(Color("brainwalletGray"))
    ///Static theme colors
    static let midnight = UIColor(#colorLiteral(red: 0.07334695011, green: 0.07277505845, blue: 0.4002133608, alpha: 1))
    static let cheddar = UIColor(#colorLiteral(red: 1, green: 0.6823529412, blue: 0, alpha: 1))
    static let pesto = UIColor(#colorLiteral(red: 0.1450980392, green: 0.6666666667, blue: 0.1725490196, alpha: 1))
    static let grape = UIColor(#colorLiteral(red: 0.2509803922, green: 0.1764705882, blue: 0.6823529412, alpha: 1))
    static let chili = UIColor(#colorLiteral(red: 0.8078431373, green: 0.1882352941, blue: 0.1450980392, alpha: 1))
    static let blue = UIColor(#colorLiteral(red: 0.1607843137, green: 0.4078431373, blue: 0.9490196078, alpha: 1))
    static let nearBlack = UIColor(#colorLiteral(red: 0.08235294118, green: 0.08235294118, blue: 0.08235294118, alpha: 1))
}
