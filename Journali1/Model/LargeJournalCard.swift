//
//  LargeJournalCard.swift
//  Journali1
//
//  Created by Raghad Alamoudi on 13/05/1447 AH.
//

import SwiftUI

// هذا الـ View يمثل البطاقة الكبيرة لكل ملاحظة (Journal)
struct LargeJournalCard: View {
    // بيانات اليومية (العنوان، النص، التاريخ، هل هي مفضلة)
    let entry: JournalEntry
    // لون العنوان
    let titleColor: Color
    // يحدد إذا كانت البطاقة محددة حاليًا (مثلاً تم النقر عليها)
    let isSelected: Bool
    // حدث يتم استدعاؤه عند النقر على البطاقة
    let onTap: () -> Void
    // حدث يتم استدعاؤه عند تغيير حالة الإشارة (Bookmark)
    let onToggleBookmark: () -> Void

    var body: some View {
        // الزر الأساسي اللي يحتوي البطاقة
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                // المحتوى الداخلي للبطاقة
                VStack(alignment: .leading, spacing: 10) {
                    // عنوان اليومية
                    Text(entry.title)
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundColor(titleColor)
                        .lineLimit(1)

                    // تاريخ اليومية بتنسيق طويل
                    Text(longDate(entry.date))
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.65))

                    // نص اليومية
                    Text(entry.body)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)

                    // مسافة بسيطة أسفل النص
                    Spacer(minLength: 6)
                }
                // إعدادات التصميم العامة للبطاقة
                .padding(.all, 22)
                .frame(maxWidth: .infinity, minHeight: 180, alignment: .leading)
                .background(Color(red: 0.06, green: 0.06, blue: 0.07))
                .cornerRadius(20)
                // الظل يختلف حسب ما إذا كانت البطاقة محددة أم لا
                .shadow(color: Color.black.opacity(0.35), radius: isSelected ? 8 : 4, x: 0, y: 2)

                // زر الإشارة المرجعية (Bookmark)
                Button(action: {
                    onToggleBookmark()
                }) {
                    Image(systemName: entry.bookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(entry.bookmarked ? titleColor : Color.white.opacity(0.85))
                        .padding(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // دالة لتحويل التاريخ إلى نص بصيغة مقروءة
    private func longDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        return fmt.string(from: date)
    }
}
