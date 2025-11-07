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
    static let transferRed = Color(#colorLiteral(red: 1, green: 0.2823529412, blue: 0.2941176471, alpha: 1))
    static let blue = Color(#colorLiteral(red: 0.1607843137, green: 0.4078431373, blue: 0.9490196078, alpha: 1))
    static let nearBlack = Color(#colorLiteral(red: 0.08235294118, green: 0.08235294118, blue: 0.08235294118, alpha: 1))
    static let lightgray = Color(#colorLiteral(red: 0.8352941176, green: 0.8352941176, blue: 0.8352941176, alpha: 1))
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
    static let lightgray = UIColor(#colorLiteral(red: 0.8352941176, green: 0.8352941176, blue: 0.8352941176, alpha: 1))
}

/// Brainwallet Bento Colors

struct BentoColor {
    /// purple1 - #C8B3EE
    static let purple1 = Color(red: 0.7843137254901961,
                               green: 0.7019607843137254,
                               blue: 0.9333333333333333)
    /// purple2 - #8669BA
    static let purple2 = Color(red: 0.5254901960784314,
                               green: 0.4117647058823529,
                               blue: 0.7294117647058823)
    /// purple3 - #121348
    static let purple3 = Color(red: 0.07058823529411765,
                               green: 0.07450980392156863,
                               blue: 0.2823529411764706)
    /// purple4 - #491FA3
    static let purple4  = Color(red:  0.28627450980392155,
                                green: 0.12156862745098039,
                                blue: 0.6392156862745098)
    /// purple5 - #5754FF
    static let purple5  = Color(red:  0.3411764705882353,
                                green: 0.32941176470588235,
                                blue: 1)
    /// grayBackground- #E8EAEC
    static let grayBackground = Color(red: 0.9098039215686274,
                                      green: 0.9176470588235294,
                                      blue: 0.9254901960784314)
    /// grayBorder - #D9D9D9
    static let grayBorder = Color(red: 0.8509803921568627,
                             green: 0.8509803921568627,
                             blue: 0.8509803921568627)

    /// gameBlue1 - #114CD4
    static let gameBlue1 = Color(red: 0.06666666666666667,
                                 green: 0.2980392156862745,
                                 blue: 0.8313725490196079)

    /// tutorialGreen1- #F2FFF3
    static let tutorialGreen1 = Color(red: 0.9490196078431372,
                                      green: 1.0,
                                      blue: 0.9529411764705882)

    /// tutorialGreen2- #48974E
    static let tutorialGreen2 = Color(red: 0.2823529411764706,
                                      green: 0.592156862745098,
                                      blue: 0.3058823529411765)

    /// darkModeBorder2- #9074FF
    static let darkModeBorder2 = Color(red: 0.5647058823529412,
                                      green: 0.4549019607843137,
                                       blue: 1.0)

    /// darkModeBorder3- #020148
    static let darkModeBorder3 = Color(red: 0.00784313725490196,
                                      green: 0.00392156862745098,
                                      blue: 0.2823529411764706)

    /// darkModeBorder4- #2B193B
    static let darkModeBorder4 = Color(red: 0.16862745098039217,
                                      green: 0.09803921568627451,
                                      blue: 0.23137254901960785)

    /// darkModeBorder5- #6944BE

    static let darkModeBorder5 = Color(red: 0.4117647058823529,
                                      green: 0.26666666666666666,
                                      blue: 0.7450980392156863)

    /// balanceBackgroundPurple - #5827E2

    static let balanceBackgroundPurple = Color(red: 0.34509803921568627,
                                      green: 0.15294117647058825,
                                      blue: 0.8862745098039215)

    /// progressGreen1 #37BE46
    static let progressGreen1 = Color(red: 0.21568627450980393,
                                      green: 0.7450980392156863,
                                      blue: 0.27450980392156865)

    /// progressGreen2 - #AFF64C
    static let progressGreen2 = Color(red: 0.6862745098039216,
                                      green: 0.9647058823529412,
                                      blue: 0.2980392156862745)

}
