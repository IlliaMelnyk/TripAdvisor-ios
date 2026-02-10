//
//  ContentView.swift
//  TripAdvisor
//
//  Created by Illia Melnyk on 11.06.2025.
//

import SwiftUI

struct ContentView: View {

    @State var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: HomeViewModel())
                            .tabItem {
                                Label("home", systemImage: "house")
                            }
                            .tag(0)
                        
        StatisticView(viewModel: StatisticViewModel())
                            .tabItem {
                                Label("stat", systemImage: "chart.bar")
                            }
                            .tag(1)
            MapView(viewModel: MapViewModel())
                .tabItem {
                    Label("map", systemImage: "map.circle")
                }
                .tag(2)
            
        }
    }
}

#Preview {
    ContentView()
}
