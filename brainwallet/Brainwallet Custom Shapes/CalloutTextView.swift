//
//  CalloutTextView.swift
//  brainwallet
//
//  Created by Kerry Washington on 24/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct CalloutTextView: View {

   @Binding
   var userPrefersDarkTheme: Bool

    @Binding
    var corner: ShapeCorner

   private
   let title: String

   private
   let description: String

   init(title: String,
        description: String,
        corner: Binding<ShapeCorner>,
        userPrefersDarkTheme: Binding<Bool>) {
       _userPrefersDarkTheme = userPrefersDarkTheme
       _corner = corner
       self.title = title
       self.description = description
    }

        var body: some View {
            GeometryReader { geometry in

                let width = geometry.size.width
                let height = geometry.size.height

                ZStack {
                    VStack {
                        HStack {
                            BentoCalloutShape(shapeCorner: $corner,
                                              userPrefersDarkTheme: $userPrefersDarkTheme)
                          Spacer()
                        }
                        Spacer()
                    }

                    VStack {
                        HStack {
                            Text(title)
                                .font(.system(size: 17, weight: .bold, design: .default))
                                .lineLimit(2)
                                .minimumScaleFactor(0.9)
                                .frame(alignment: .leading)
                                .foregroundColor(.black)
                                .padding([.trailing], 16)
                          Spacer()
                        }
                        .padding(.top, 8)

                        HStack {
                            Text(description)
                                .font(.system(size: 14, weight: .light, design: .default))
                                .lineLimit(3)
                                .minimumScaleFactor(0.7)
                                .frame(alignment: .leading)
                                .foregroundColor(.black)
                                .padding([.trailing], 16)
                          Spacer()
                        }
                        .padding(.top, 1)
                        Spacer()
                    }
                    .padding([.leading], 16)

                }
                .frame(height: calloutHeight)
            }
        }

    }
