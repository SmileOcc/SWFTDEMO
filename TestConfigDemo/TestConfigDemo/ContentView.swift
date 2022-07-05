//
//  ContentView.swift
//  TestConfigDemo
//
//  Created by 欧冬冬 on 2022/5/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!1")
            .padding()
        
        #if DEV
        Text("--dev").padding()
        #elseif SIT
        Text("--sit").padding()
        #else
        Text("--else").padding()
        #endif
        
        #if TEST_SIT
        Text("--sit app").padding()
        #elseif TEST_DEV
        Text("--dev app").padding()
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
