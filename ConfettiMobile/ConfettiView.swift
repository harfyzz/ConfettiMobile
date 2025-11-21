//
//  ContentView.swift
//  ConfettiMobile
//
//  Created by Afeez Yunus on 14/11/2025.
//

import SwiftUI
import RiveRuntime

struct ConfettiView: View {
    @State var textInput: String = ""
    var confetti = RiveViewModel(fileName: "confetti", stateMachineName: "State Machine 1", artboardName: "main")
    @State var confettiEffect: Effect = .gift
    @State var confettiCount: Float = 0
    @State var emitterYPosition: CGFloat = .zero
    @State var emitterXPosition: CGFloat = .zero
    @FocusState var isFocused: Bool
    @State var increment:Int = 10
    // Keep a reference to the pending reset task so it can be canceled on new input
    @State private var resetWorkItem: DispatchWorkItem?
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment:.bottom){
                //  confetti.view()
                VStack{
                    Spacer()
                    HStack(spacing:12){
                        Button {
                            withAnimation(.spring){
                                increment -= 2
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                            .foregroundStyle(Color.gray.opacity(0.7))
                        }
                        Text("\(increment)")
                            .font(.system(size: 70, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                       
                        Button {
                            withAnimation(.spring){
                                increment += 2
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.gray.opacity(0.7))
                        }
                        
                    }
                    .font(.system(size: 30))
                    HStack{
                        EffectPicker(effectImage: "gift.fill", isSelected: confettiEffect == .gift) { confettiEffect = .gift}
                        EffectPicker(effectImage: "heart.fill", isSelected: confettiEffect == .heart){ confettiEffect = .heart}
                        EffectPicker(effectImage: "basketball.fill", isSelected: confettiEffect == .ball) { confettiEffect = .ball}
                    }
                    Spacer()
                }
                VStack(spacing:12){
                    TextField("Type something...", text: $textInput)
                        .focused($isFocused)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        updateEmitterFrom(geo: geo)
                                    }
                                    .onChange(of: proxy.size.height) { _, _ in
                                        updateEmitterFrom(geo: geo)
                                    }
                            }
                        )
                    // .frame(width: 300)
                        .onChange(of: textInput) { oldValue, newValue in
                            let characterCount = newValue.count
                            emitterXPosition = CGFloat(characterCount) * 8
                            confettiCount += Float(increment)
                            updateBind()
                            scheduleReset()
                        }
                        .onAppear {
                            updateBind()
                            confetti.setInput("canvasWidth", value: proxy.size.width)
                            confetti.setInput("canvasHeight", value: proxy.size.height)
                        }
                        .onChange(of: proxy.size.height) { oldValue, newValue in
                            confetti.setInput("canvasHeight", value: proxy.size.height)
                            updateBind()
                        }
                        .onChange(of: proxy.size.width) { oldValue, newValue in
                            confetti.setInput("canvasWidth", value: proxy.size.width)
                            updateBind()
                        }
                    
                
                    HStack{
                        VStack{
                            VStack{
                                Image(systemName: "plus")
                                    .font(.subheadline)
                            }
                            .frame(width:32, height: 32)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                        }
                        VStack{
                            VStack{
                                Image(systemName: "magnifyingglass")
                                    .font(.subheadline)
                            }
                            .frame(width:32, height: 32)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                        }
                        Spacer()
                    }
            }
                .padding(18)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 20))
               // .padding(.bottom, 32)
                .padding(.horizontal,16)
                        confetti.view()
                            .allowsHitTesting(false)
                        
                    }
        //    .preferredColorScheme(.dark)
               
            
        }
        
       // .ignoresSafeArea(.keyboard, edges:.bottom)
    }
    private func updateEmitterFrom(geo: GeometryProxy) {
        let frame = geo.frame(in: .global)
        emitterYPosition = frame.origin.y - 70
        updateBind()
    }
    
    func scheduleReset() {
        // Cancel any previously scheduled reset
        resetWorkItem?.cancel()

        // Create a new work item that resets the count after 2 seconds
        let workItem = DispatchWorkItem {
            confettiCount = 0
            updateBind()
        }
        resetWorkItem = workItem

        // Dispatch after 2 seconds on the main queue
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem)
    }

    
    func updateBind() {
        let confettiVm = confetti.riveModel!.riveFile.viewModelNamed("mainVm")
        let confettiInstance = confettiVm?.createInstance(fromName: "MainInstance")
        confetti.riveModel?.stateMachine?.bind(viewModelInstance: confettiInstance!)
        confettiInstance?.stringProperty(fromPath: "text")?.value = textInput
        confettiInstance?.numberProperty(fromPath: "confettiCount")?.value = confettiCount
        confettiInstance?.numberProperty(fromPath: "emitterYPos")?.value = Float(emitterYPosition)
        confettiInstance?.numberProperty(fromPath: "emitterXPos")?.value = Float(emitterXPosition)
        confettiInstance?.enumProperty(fromPath: "effect")?.value = effectString(for: confettiEffect)
        confetti.triggerInput("advance")
    }
    
    func effectString(for effect: Effect) -> String {
        switch effect {
        case .heart: return "heart"
        case .android: return "android"
        case .ball: return "ball"
        case .gift: return "gift"
        }
    }
}

#Preview {
    ConfettiView()
}

enum Effect {
    case heart
    case android
    case ball
    case gift
}


struct EffectPicker: View {
    var effectImage:String
    var isSelected:Bool
    var action: (() -> Void)
    var body: some View {
        VStack{
            VStack{
                Image(systemName: effectImage)
                    .font(.subheadline)
                    .opacity(isSelected ? 1.0 : 0.4)
            }
            .frame(width:40, height: 24)
            .background(.gray.opacity(isSelected ? 0.2 : 0.1))
            .clipShape(Capsule())
        }
        .padding(4)
        .onTapGesture {
            action()
        }
        .overlay{
            if isSelected{
                Capsule()
                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 2))
            }
        }
    }
}
/*
class SharedRiveModel: ObservableObject {
    static let shared = SharedRiveModel()
    let riveImage: RiveViewModel
    var text: String = "Hello"
    var confettiCount: Float = 0
    
    init () {
        riveImage = RiveViewModel(fileName: "confetti", stateMachineName: "State Machine 1", artboardName: "main")
    }
}

*/
