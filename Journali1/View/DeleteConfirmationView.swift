//
//  DeleteConfirmationView.swift
//  Journali1
//
//  Created by Raghad Alamoudi on 13/05/1447 AH.
//

import SwiftUI

// 🔹 هذا الـ View يمثل نافذة تأكيد الحذف (Alert مخصص)
struct DeleteConfirmationView: View {
    // متغير يربط حالة ظهور النافذة بالـ View الأساسي
    @Binding var isPresented: Bool
    // دالة تُنفذ عند الضغط على "Delete"
    var onDelete: () -> Void

    var body: some View {
        ZStack {
            if isPresented {
                //  الخلفية الداكنة اللي تغطي الشاشة عند ظهور النافذة
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .transition(.opacity)

                //  محتوى نافذة التأكيد نفسها
                VStack(spacing: 20) {
                    // العنوان الرئيسي
                    Text("Delete Journal?")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)

                    // النص التوضيحي تحت العنوان
                    Text("Are you sure you want to delete this journal?")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    //  أزرار "Cancel" و "Delete"
                    HStack(spacing: 16) {
                        // زر الإلغاء
                        Button("Cancel") {
                            withAnimation {
                                isPresented = false // يغلق النافذة
                            }
                        }
                        .font(.headline)
                        .frame(width: 120, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(.white)

                        // زر الحذف
                        Button("Delete") {
                            withAnimation {
                                isPresented = false // يغلق النافذة
                                onDelete() // ينفذ عملية الحذف
                            }
                        }
                        .font(.headline)
                        .frame(width: 120, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(.red)
                    }
                }
                //  تصميم واجهة النافذة نفسها
                .padding()
                .background(.ultraThinMaterial) // خلفية شفافة ناعمة
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 6)
                .frame(maxWidth: 340)
                .transition(.scale) // حركة عند الظهور/الإخفاء
                .zIndex(1) // يخلي النافذة فوق كل العناصر
            }
        }
        //  أنيميشن ناعم عند ظهور أو إخفاء النافذة
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}
