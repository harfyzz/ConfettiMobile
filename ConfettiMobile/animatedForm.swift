//
//  animatedForm.swift
//  ConfettiMobile
//
//  Created by Afeez Yunus on 05/12/2025.
//

import SwiftUI

struct animatedForm: View {
    @FocusState var is1Focused: Bool
    var body: some View {
        VStack(spacing:8){
            AnimatedInput(textNum: "",textTitle: "Serial ID")
            AnimatedInput(textNum: "", textTitle: "Card Details")
            AnimatedInput(textNum: "", textTitle: "Some other number")
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    animatedForm()
}
