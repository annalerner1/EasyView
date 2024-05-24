//
//  WarningView.swift
//  EasyInterview
//
//  Created by Anna Lerner on 5/11/24.
//

import SwiftUI

struct WarningView: View {
    @Binding var warnings: [String]
    var body: some View {
        if !warnings.isEmpty {
            ZStack {
                VStack {
                    HStack {
                        Text("Warning:")
                            .foregroundColor(.red)
                            .bold()
                            .font(.title2)
                        
                        Text(warnings.joined(separator: ", "))
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                    .padding()
                    Spacer()

                }
                .padding()
                
                Color.red
                    .ignoresSafeArea()
                    .opacity(0.3)
            }
        }
    }
}

struct WarningView_Previews: PreviewProvider {
    static var previews: some View {
        WarningView(warnings: .constant(["shaky hands", "bad sound quality"]))
    }
}
