//
//  AppSettings.swift
//  WizardryMouse
//
//  Created by Qingbo Zhou on 8/22/21.
//

import SwiftUI

struct AppSettings: View {
    @AppStorage("warnThreshold")
    private var warnThreshold = 20
    
    private var intProxy: Binding<Double>{
        Binding<Double>(get: {
            return Double(warnThreshold)
        }, set: {
            warnThreshold = Int($0)
        })
    }
    
    var body: some View {
        VStack {
            List {
                VStack(alignment: .leading) {
                    Text("Warn when battery level is under: \(warnThreshold)%")
                        .font(.title2)
                    Slider(
                        value: intProxy,
                        in: 5...40,
                        step: 5
                    )
                }
                .padding(10)
            }
            .frame(width: 500, height: 120, alignment: .center)
            .listStyle(InsetListStyle())
        }.padding(10)
    }
}

struct AppSettings_Previews: PreviewProvider {
    static var previews: some View {
        AppSettings()
    }
}
