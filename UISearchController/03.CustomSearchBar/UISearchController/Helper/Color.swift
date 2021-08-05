//
//  Color.swift
//  Color
//
//  Created by 蔡志文 on 2021/8/4.
//

import UIKit

struct Color {
    var name: String
    var value: UIColor
}

class ColorStore {
    static let `default` = ColorStore()
    let colors: [Color] = [
        Color(name: "red", value: .systemRed),
        Color(name: "blue", value: .systemBlue),
        Color(name: "green", value: .systemGreen),
        Color(name: "yellow", value: .systemYellow),
        Color(name: "orange", value: .systemOrange),
        Color(name: "pink", value: .systemPink),
        Color(name: "brown", value: .brown),
        Color(name: "white", value: .white),
        Color(name: "cyan", value: .cyan),
        Color(name: "gray", value: .gray),
        Color(name: "magenta", value: .magenta),
        Color(name: "purple", value: .purple),
        Color(name: "black", value: .black),
    ]
    
}
