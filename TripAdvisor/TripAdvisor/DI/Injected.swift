//
//  Injected.swift
//  CityGuide
//
//  Created by Illia Melnyk on 18.03.2025.
//

@propertyWrapper
struct Injected<T> {
    let wrappedValue: T

    init() {
        wrappedValue = DIContainer.shared.resolve()
    }
}
