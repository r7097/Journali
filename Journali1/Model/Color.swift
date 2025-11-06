//
//  Color.swift
//  Journali1
//
//  Created by Raghad Alamoudi on 13/05/1447 AH.
//

import SwiftUI

// هذا الامتداد (Extension) يضيف طريقة جديدة لإنشاء لون (Color) باستخدام كود HEX
extension Color {
    // مهيأ (Initializer) يستقبل كود اللون مثل "#FF5733"
    init(hex: String) {
        // كائن Scanner لقراءة النص وتحويله إلى أرقام
        let scanner = Scanner(string: hex)
        // يتجاهل علامة # إذا كانت موجودة في بداية الكود
        _ = scanner.scanString("#")
        // متغير لتخزين القيمة الرقمية بعد التحويل
        var rgb: UInt64 = 0
        // يحول النص إلى رقم من نوع Hexadecimal
        scanner.scanHexInt64(&rgb)

        // استخراج كل لون (أحمر، أخضر، أزرق) من الكود وتحويله إلى نسبة بين 0 و 1
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        // إنشاء اللون باستخدام القيم الثلاث
        self.init(red: r, green: g, blue: b)
    }
}
