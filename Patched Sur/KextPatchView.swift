//
//  KextPatchView.swift
//  Patched Sur
//
//  Created by Benjamin Sova on 10/29/20.
//

import SwiftUI

struct KextPatchView: View {
    @Binding var at: Int
    var body: AnyView {
        AnyView(VStack {
            TopKextsView()
            ButtonsView(at: $at)
        }.navigationTitle("Patched Sur"))
    }
}

struct ButtonsView: View {
    @Binding var at: Int
    @State var p = 0
    @State var password = ""
    @State var buttonBG = Color.blue
    @State var errorMessage = ""
    var body: some View {
        if p == 0 {
            DoubleButtonView(first: {
                at = 0
            }, second: {
                p = 1
            }, text: "Continue")
        } else if p == 1 {
            RunActionsDisplayView(action: {
                do {
                    try shellOut(to: "[[ -d /Volumes/Install\\ macOS\\ Big\\ Sur\\ Beta/Install\\ macOS\\ Big\\ Sur\\ Beta.app ]]")
                    p = 2
                } catch {
                    p = -1
                }
            }, text: "Detecting Volumes")
        } else if p == -1 {
            DoubleButtonView(first: {
                at = 0
            }, second: {
                p = 1
            }, text: "Plug in USB Installer and Try Again")
        } else if p == 2 {
            EnterPasswordButton(password: $password) {
                p = 3
            }
        } else if p == 3 {
            RunActionsDisplayView(action: {
                do {
                    let model = (try? shellOut(to: "sysctl -n hw.model")) ?? "MacModelX,Y"
                    if model == "MacBookPro8,1"{
                        try shellOut(to: "echo '\(password)' | sudo -S '/Volumes/Install macOS Big Sur Beta/patch-kexts.sh --2011'")
                        p = 4
                    }
                    else if model == "MacBookAir4,2"{
                        try shellOut(to: "echo '\(password)' | sudo -S '/Volumes/Install macOS Big Sur Beta/patch-kexts.sh --2011'")
                        p = 4
                    }
                    else if model == "iMac12,2"{
                        try shellOut(to: "echo '\(password)' | sudo -S '/Volumes/Install macOS Big Sur Beta/patch-kexts.sh --2011'")
                        p = 4
                    }
                    else if model == "iMac12,1"{
                        try shellOut(to: "echo '\(password)' | sudo -S '/Volumes/Install macOS Big Sur Beta/patch-kexts.sh --2011'")
                        p = 4
                    }
                    else {
                        try shellOut(to: "echo '\(password)' | sudo -S '/Volumes/Install macOS Big Sur Beta/patch-kexts.sh'")
                        p = 4
                    }
                } catch {
                    errorMessage = error.localizedDescription
                    p = -2
                }
            }, text: "Patching Kexts...")
        } else if p == -2 {
            Button {
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(errorMessage, forType: .string)
            } label: {
                ZStack {
                    buttonBG
                        .cornerRadius(10)
                        .frame(minWidth: 200, maxWidth: 450)
                        .onHover(perform: { hovering in
                            buttonBG = hovering ? Color.red.opacity(0.7) : .red
                        })
                        .onAppear(perform: {
                            if buttonBG != .red && buttonBG != Color.red.opacity(0.7) {
                                buttonBG = .red
                            }
                        })
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .lineLimit(6)
                        .padding(6)
                        .padding(.horizontal, 4)
                }
            }.buttonStyle(BorderlessButtonStyle())
            .fixedSize()
        } else if p == 4 {
            Button {
                DispatchQueue.global(qos: .background).async {
                    do {
                        try shellOut(to: "echo \"\(password)\" | sudo -S sudo reboot")
                    } catch {
                        print("Error, but they can do it themselves.")
                    }
                }
            } label: {
                ZStack {
                    buttonBG
                        .cornerRadius(10)
                        .onHover(perform: { hovering in
                            buttonBG = hovering ? Color.accentColor.opacity(0.7) : Color.accentColor
                        })
                    Text("Restart to Finish")
                        .foregroundColor(.white)
                        .padding(5)
                        .padding(.horizontal, 50)
                }
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct TopKextsView: View {
    var body: some View {
        Text("Patch Kexts").bold()
        Text("Patching your kexts gets you Wifi, USB, and many other things working on your Big Sur installation. Without these kexts, your Mac would not be at its full potential on Big Sur, and several things would not work. Makes sense right?")
            .padding()
            .multilineTextAlignment(.center)
    }
}
