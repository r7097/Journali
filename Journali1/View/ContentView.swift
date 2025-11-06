//
//  ContentView.swift
//  Journali1
//
//  Created by Raghad Alamoudi on 13/05/1447 AH.
//

import SwiftUI

struct ContentView: View {
    // متغير يتحكم في عرض صفحة البداية أو الصفحة الرئيسية
    @State private var startApp = false

    var body: some View {
        NavigationStack {
            // إذا كانت startApp = true، يعرض الصفحة الرئيسية
            if startApp {
                MainPage()
            } else {
                // واجهة شاشة البداية (Splash Screen)
                ZStack {
                    // خلفية متدرجة من لون بنفسجي غامق إلى أسود
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.15, green: 0.1, blue: 0.2),
                            Color.black
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    // محتوى الشاشة
                    VStack(spacing: 20) {
                        // شعار التطبيق
                        Image("url")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 140)
                            .shadow(color: .pink.opacity(0.4), radius: 10, x: 0, y: 5)

                        // اسم التطبيق
                        Text("Journali")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)

                        // العبارة التعريفية
                        Text("Your thoughts, your story")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                // بعد ظهور الشاشة، ينتظر ثانيتين ثم ينتقل إلى الصفحة الرئيسية مع حركة انتقال
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            startApp = true
                        }
                    }
                }
            }
        }
        // يحدد الوضع الداكن كتفضيل للتصميم
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
