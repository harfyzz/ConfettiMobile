//
//  AnimtedTypo.swift
//  ConfettiMobile
//
//  Created by Afeez Yunus on 21/11/2025.
//

import SwiftUI
import RiveRuntime

struct AnimtedTypo1: View {
    var animatedText = RiveViewModel(fileName: "animated_typo0", stateMachineName: "State Machine 1", alignment:.centerRight, artboardName: "main")
    @State var numCount = 0
    @State var textNum = "1"
    @FocusState var isFocused:Bool
    // Store references to avoid recreating them
    @State private var textInstance: RiveDataBindingViewModel.Instance?
    @State private var isSetup = false
    let deviceWidth = UIScreen.main.bounds.width
    
    
    var body: some View {
            VStack(alignment:.trailing){
            TextField(text: $textNum) {
                
            }
            .opacity(0)
            .focused($isFocused)
            .keyboardType(.numberPad)
            animatedText.view()
                .padding(.trailing, 12)
                .frame(height: 90)
                .onTapGesture {
                    isFocused = true
                }
        }
        .onAppear {
            animatedText.setInput("canvasWidth", value: deviceWidth * 2.2)
            setupRiveInstances()
        }
        .onChange(of: textNum) { _, newValue in
            updateNumCount()
        }
    
    }
    
    private func setupRiveInstances() {
        guard !isSetup else { return }
        
        let textVm = animatedText.riveModel?.riveFile.viewModelNamed("mainVm")
        textInstance = textVm?.createInstance(fromName: "Instance")
        animatedText.riveModel?.stateMachine?.bind(viewModelInstance: textInstance!)
        
        
        isSetup = true
        // Set initial value
        updateNumCount()
    }
    
    private func updateNumCount() {
        guard isSetup, let instance = textInstance else { return }
        
        let count = Float(textNum.count)
        let newNumber = Float(textNum.last?.wholeNumberValue ?? 0)
        
        print("Updating Rive: count=\(count), newNumber=\(newNumber), text='\(textNum)'")
        
        // Update properties
        instance.numberProperty(fromPath: "numCount")?.value = count
        instance.numberProperty(fromPath: "newNumber")?.value = newNumber
        
        
        // Force the Rive model to update
       // animatedText.riveModel?.advance(by: 0)
        animatedText.triggerInput("advance")
    }
}

#Preview {
    AnimtedTypo1()
}
