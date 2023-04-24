//
//  WelcomePage.swift
//  Incubator
//
//  Created by Alikhan Tangirbergen on 23.04.2023.
//

import SwiftUI

struct WelcomePage: View {
    @Binding var screenState : AppScreenState
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image("logo")
                    Spacer()
                    Text("Nfactorial Incubator App")
                    Spacer()
                } .padding()
                Spacer()
                Text("Draw a perfect circle game")
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .fontWeight(.semibold)
                    .font(.system(size: 36))
                    .frame(width: 358, height: 92)
                    .padding(.trailing)
                Text("The game was developed by Alikhan Tangirbergen as a test assignment for selection for Incubator by Nfactorial")
                    .multilineTextAlignment(.center)
                Spacer()
                Button {
                    UserDefaults.standard.set(true, forKey: "isOnboardingSeen")
                    screenState = .main
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: 358, height: 58)
                            .foregroundColor(.black)
                            .padding()
                        Text("Let's start playing!")
                            .foregroundColor(.white)
                            .frame(width: 310, height: 22)
                            .font(.system(size: 16))
                    }
                }
            }
        }
    }

}

struct WelcomePage_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePage(screenState: .constant(.onboarding))
    }
}
