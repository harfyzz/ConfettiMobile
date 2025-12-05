//
//  AnimatedTypo2.swift
//  ConfettiMobile
//
//  Created by Afeez Yunus on 21/11/2025.
//

import SwiftUI
import RiveRuntime

struct AnimtedTypo2: View {
    var animatedText = RiveViewModel(fileName: "animated_typo 2", stateMachineName: "State Machine 1", artboardName: "main")
    @State var numCount = 0
    @State var textNum = "1"

    @State var numbers: [RiveDataBindingViewModel.Instance] = []
    @State var numberList:RiveDataBindingViewModel.Instance.ListProperty?
    @State var characterVm: RiveDataBindingViewModel?
    // Store references to avoid recreating them
    @State private var textInstance: RiveDataBindingViewModel.Instance?
    @State private var isSetup = false
    
    var body: some View {
        VStack{
            TextField("Enter numbers", text: $textNum)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .padding()
            .opacity(1)
            animatedText.view()
                .frame(height: 120)
    }
            .onAppear {
                setupRiveInstances()
            }
            .onChange(of: textNum) { oldValue, newValue in
                updateNumCount()
            }
    }
    
    private func setupRiveInstances() {
        guard !isSetup else { return }
        
        let textVm = animatedText.riveModel?.riveFile.viewModelNamed("mainVm")
        textInstance = textVm?.createInstance(fromName: "Instance")
        animatedText.riveModel?.stateMachine?.bind(viewModelInstance: textInstance!)
        numberList = textInstance?.listProperty(fromPath: "numbers")
        characterVm = animatedText.riveModel?.riveFile.viewModelNamed("characterVm")
        isSetup = true
        // Set initial value
        updateNumCount()
    }
    
    private func updateNumCount() {
        print("updateNumCount called with textNum: '\(textNum)'")
        
        let targetCount = textNum.count
        let currentCount = numbers.count
        
        print("Target count: \(targetCount), Current count: \(currentCount)")
        
        // If the text is shorter than our current list, we need to manage the reduction
        if targetCount < currentCount {
            // Remove excess instances from both arrays, starting from the end
            for index in (targetCount..<currentCount).reversed() {
                numberList?.remove(at: Int32(index))
                numbers.remove(at: index)
            }
        }
        // If we need more instances, create them
        else if targetCount > currentCount {
            for _ in currentCount..<targetCount {
                if let newInstance = characterVm?.createInstance() {
                    numbers.append(newInstance)
                    numberList?.append(newInstance)
                }
            }
        }
        
        // Update the values for all current instances to match the text
        for (index, character) in textNum.enumerated() {
            guard index < numbers.count else { break }
            
            let characterValue: Float
            if character.isNumber {
                if let digit = character.wholeNumberValue {
                    characterValue = Float(digit)
                    print("Setting character at index \(index): '\(character)' -> \(characterValue)")
                } else {
                    characterValue = 0
                    print("Failed to get wholeNumberValue for '\(character)' at index \(index), defaulting to 0")
                }
            } else {
                characterValue = 0 // Default for non-numeric characters
                print("Non-numeric character at index \(index): '\(character)' -> default 0")
            }
            
            numbers[index].numberProperty(fromPath: "character")?.value = characterValue
        }
        
        animatedText.triggerInput("advance")
    }
}

#Preview {
    AnimtedTypo2()
}
