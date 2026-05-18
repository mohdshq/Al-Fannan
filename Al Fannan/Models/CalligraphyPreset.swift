//
//  CalligraphyPreset.swift
//  Al Fannan
//
//  Created by Mohammed Alshaqra on 15/05/2026.
//

import SwiftUI

struct CalligraphyPreset: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let fontName: String         // PostScript name of a bundled font
    let fontSize: CGFloat
    let gradientColors: [String] // hex strings
    let curveAngle: CGFloat
    let isPro: Bool

    static let presets: [CalligraphyPreset] = [
        CalligraphyPreset(text: "بسم الله الرحمن الرحيم", fontName: "Amiri-Bold",          fontSize: 36, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"], curveAngle: 0,  isPro: false),
        CalligraphyPreset(text: "الحمد لله",               fontName: "ArefRuqaa-Regular",    fontSize: 56, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"], curveAngle: 0,  isPro: false),
        CalligraphyPreset(text: "ما شاء الله",             fontName: "ArefRuqaa-Regular",    fontSize: 56, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"], curveAngle: 0,  isPro: false),
        CalligraphyPreset(text: "سبحان الله",              fontName: "Amiri-Bold",           fontSize: 50, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"], curveAngle: 0,  isPro: false),
        CalligraphyPreset(text: "لا إله إلا الله",          fontName: "ReemKufi",             fontSize: 44, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"], curveAngle: 0,  isPro: false),
        CalligraphyPreset(text: "الله أكبر",                fontName: "ReemKufi",             fontSize: 60, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"], curveAngle: 0,  isPro: false),
        CalligraphyPreset(text: "استغفر الله",              fontName: "Amiri-Regular",        fontSize: 50, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"], curveAngle: 0,  isPro: false),
        CalligraphyPreset(text: "اللهم صل على محمد",        fontName: "Amiri-Bold",           fontSize: 36, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"], curveAngle: 60, isPro: false),
        CalligraphyPreset(text: "بارك الله فيك",            fontName: "ArefRuqaa-Regular",    fontSize: 44, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"], curveAngle: 0,  isPro: false),
        CalligraphyPreset(text: "إن شاء الله",              fontName: "ReemKufi",             fontSize: 50, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"], curveAngle: 0,  isPro: false),
        CalligraphyPreset(text: "جزاك الله خيراً",          fontName: "Amiri-Regular",        fontSize: 40, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"], curveAngle: 0,  isPro: false),
        CalligraphyPreset(text: "رمضان كريم",               fontName: "Amiri-Bold",           fontSize: 52, gradientColors: ["#D4A853", "#F0D48A", "#D4A853"], curveAngle: 80, isPro: false),
    ];
}
