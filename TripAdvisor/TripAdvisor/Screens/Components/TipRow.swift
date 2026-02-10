//
//  TipRow.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 16.06.2025.
//

import Foundation
import SwiftUI

struct TipRow: View {
    let tip: TripTip
    var isSelected: Bool
    var onToggleSelection: () -> Void
    var onTapTitle: () -> Void

    var body: some View {
        HStack {
            if let imageURL = tip.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 50, height: 50)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure(let error):
                        VStack {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                            // Debug info – můžeš později smazat
                            #if DEBUG
                            Text("⚠️ Chyba")
                                .font(.caption2)
                                .foregroundColor(.red)
                            #endif
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
            Button(action: {
                onTapTitle()
            }) {
                Text(tip.title)
                    .font(.callout)
                    .foregroundColor(.primary)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Button(action: {
                onToggleSelection()
            }) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                    .imageScale(.large)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

