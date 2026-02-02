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
            GeometryReader { _ in

                let padding = 12.0

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
                                .font(.ibmPlexSansBold(size: 17.0))
                                .lineLimit(2)
                                .minimumScaleFactor(0.9)
                                .frame(alignment: .leading)
                                .foregroundColor(.black)
                                .padding([.trailing], padding)
                          Spacer()
                        }
                        .padding(.top, 8)

                        HStack {
                            Text(description)
                                .font(.ibmPlexSansRegular(size: 16.0))
                                .lineLimit(4)
                                .minimumScaleFactor(0.7)
                                .frame(alignment: .leading)
                                .foregroundColor(.black)
                                .padding([.trailing], padding)
                          Spacer()
                        }
                        .padding(.top, 1)
                        .padding(.bottom, 8)

                        Spacer()
                    }
                    .padding([.leading], padding)

                }
                .frame(height: calloutHeight)
            }
        }

    }
