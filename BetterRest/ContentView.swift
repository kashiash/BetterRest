//
//  ContentView.swift
//  BetterRest
//
//  Created by Jacek Placek on 11/07/2022.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1.0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State var isEditing  = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    
    var sleepResults: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
     
         
            return  "Your ideal bedtime is " + sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {

            return "Sorry, there was a problem calculating your bedtime."
        }
        
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }

                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }

//                Section("Daily coffee intake") {
//                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
//                }
                
                Section("Daily coffee intake") {

                    Text("\(coffeeAmount.formatted())")
                    Slider(
                        value: $coffeeAmount,
                        in: 0...20, step: 1.0,
                        onEditingChanged: { editing in
                            isEditing = editing
                        }
                        )
                }
                
                Text(sleepResults)
                    .font(.title3)
            }
            .navigationTitle("BetterRest")

        }
        
    }
    

    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
