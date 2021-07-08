//
//  ContentView.swift
//  GloboTeste
//
//  Created by Luiz Fernando Salvaterra on 30/06/21.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = ViewModel()

    var body: some View {
        Text("Hello, world!")
            .onAppear {
                async {
                    let result = await viewModel.execute(maxNumber: 1_000_000, numberOfTasks: 4)
                    print(result)
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
