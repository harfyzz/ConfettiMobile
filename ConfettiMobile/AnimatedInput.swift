//
//  AnimtedTypo.swift
//  ConfettiMobile
//
//  Created by Afeez Yunus on 21/11/2025.
//

import SwiftUI
import RiveRuntime

struct AnimatedInput: View {
    var animatedText = RiveViewModel(fileName: "animated_typo", stateMachineName: "State Machine 1", alignment:.centerLeft, artboardName: "main")
    @State var numCount = 0
    @State var textNum:String
    @FocusState var isFocused:Bool
    // Store references to avoid recreating them
    @State private var textInstance: RiveDataBindingViewModel.Instance?
    @State private var isSetup = false
    let deviceWidth = UIScreen.main.bounds.width
    var textTitle:String
    
    
    var body: some View {
            VStack(alignment:.leading, spacing: -4){
                Text(textTitle)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(isFocused ? .white : .gray)
            TextField(text: $textNum) {
                
            }
            .opacity(0)
            .focused($isFocused)
            .keyboardType(.numberPad)
            .onChange(of: isFocused) { oldValue, newValue in
                textInstance?.booleanProperty(fromPath: "isFocused")?.value = isFocused
            }
            animatedText.view()
               // .padding(.leading, 12)
                .frame(height: 40)
                .onTapGesture {
                    isFocused = true
                }
        }
            .padding(12)
            .background(
                .gray.opacity(isFocused ? 0.2 : 0.0))
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
    AnimatedInput(textNum: "1", textTitle: "Enter serial ID")
}
