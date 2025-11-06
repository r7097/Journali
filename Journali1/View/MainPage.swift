//
//  Untitled.swift
//  Journali1
//
//  Created by Raghad Alamoudi on 15/05/1447 AH.
//

import SwiftUI

// نموذج بيانات اليومية
struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let title: String
    let body: String
    let date: Date
    var bookmarked: Bool = false
}

struct MainPage: View {
    // حالة التركيز على حقل العنوان داخل الـ composer
    @FocusState private var titleFieldFocused: Bool

    // تنسيق التاريخ الحالي بشكل نص
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }

    // تخزين البيانات محليًا باستخدام AppStorage
    @AppStorage("journalEntriesData") private var journalEntriesData: Data = Data()

    // الحالات (States) للتحكم بسلوك الصفحة
    @State private var entries: [JournalEntry] = []
    @State private var showingComposer = false
    @State private var composeTitle: String = ""
    @State private var composeBody: String = ""
    @State private var sortNewestFirst: Bool = true
    @State private var searchText: String = ""
    @State private var selectedEntryID: UUID? = nil
    @State private var showDeleteAlert = false
    @State private var entryToDelete: JournalEntry? = nil
    @State private var showDiscardAlert = false

    // لون خاص للعناوين
    private let journalTitlePurple = Color(red: 0.76, green: 0.68, blue: 0.90)

    var body: some View {
        ZStack {
            // الخلفية سوداء
            Color.black.ignoresSafeArea()

            VStack(spacing: 18) {
                // رأس الصفحة (العنوان + الأزرار)
                HStack {
                    Text("Journal")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    // أزرار الفلترة والإضافة
                    if #available(iOS 26.0, *) {
                        HStack(spacing: 0) {
                            // قائمة الفلترة
                            Menu {
                                Button("Sort by Bookmark") {
                                    entries.sort { $0.bookmarked && !$1.bookmarked }
                                    saveEntries()
                                }
                                Button("Sort by Entry Date") {
                                    sortEntries()
                                    saveEntries()
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(10)
                            }

                            // زر إضافة ملاحظة جديدة
                            Button(action: {
                                composeTitle = ""
                                composeBody = ""
                                showingComposer = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(10)
                            }
                        }
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .glassEffect(.clear)
                    }
                }
                .padding(.horizontal)

                // المحتوى الرئيسي
                if entries.isEmpty {
                    // حالة عدم وجود أي مذكرات
                    Spacer()
                    Image("Book")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)

                    VStack(spacing: 8) {
                        Text("Begin Your Journal")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(journalTitlePurple)

                        Text("Craft your personal diary, tap the plus icon to begin")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 59)
                    }
                    Spacer()
                } else {
                    // عرض قائمة المذكرات الموجودة
                    List {
                        ForEach(filteredEntries()) { entry in
                            LargeJournalCard(
                                entry: entry,
                                titleColor: journalTitlePurple,
                                isSelected: entry.id == selectedEntryID,
                                onTap: {
                                    withAnimation(.spring()) {
                                        // تحديد البطاقة عند الضغط
                                        selectedEntryID = (selectedEntryID == entry.id) ? nil : entry.id
                                    }
                                },
                                onToggleBookmark: { toggleBookmark(entryID: entry.id) }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            // سحب لحذف المذكرة
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    entryToDelete = entry
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(Color.red)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .padding(.top)

            // شريط البحث أسفل الشاشة
            .overlay(alignment: .bottom) {
                if #available(iOS 26.0, *) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.7))
                        TextField("Search your entries...", text: $searchText)
                            .foregroundColor(.white)
                            .accentColor(journalTitlePurple)
                            .disableAutocorrection(true)
                        Spacer()
                        Image(systemName: "mic.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .background(Color.gray.opacity(0))
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .padding(.horizontal,1)
                    .padding(.bottom, 1)
                    .glassEffect(.clear)
                }
            }
        }
        .onAppear {
            // ترتيب الإدخالات عند تحميل الصفحة
            sortEntries()
        }

        // شاشة إضافة المذكرة الجديدة (Composer)
        .sheet(isPresented: $showingComposer) {
            NavigationView {
                VStack(spacing: 12) {
                    // حقل العنوان
                    TextField("Title", text: $composeTitle)
                        .font(.system(size: 30, weight: .semibold))
                        .padding(.leading, 9)
                        .foregroundColor(.white)
                        .accentColor(journalTitlePurple)
                        .focused($titleFieldFocused)

                    // عرض التاريخ
                    Text(formattedDate)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 9)

                    // حقل كتابة النص
                    TextField("Type your Journal...", text: $composeBody)
                        .font(.system(size: 20))
                        .padding(.horizontal)
                        .foregroundColor(.white)
                        .accentColor(journalTitlePurple)

                    Spacer()
                }
                .padding(.top, 25)
                .toolbar {
                    // زر الإلغاء (X)
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            // تحقق إن فيه كتابة قبل الإغلاق
                            if !composeTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                !composeBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                showDiscardAlert = true
                            } else {
                                showingComposer = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        }
                    }

                    // زر الحفظ (صح)
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            addEntry(title: composeTitle, body: composeBody)
                            showingComposer = false
                        }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(journalTitlePurple)
                        }
                        .disabled(
                            composeTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                            composeBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        )
                    }
                }

                // تنبيه التخلي عن التعديلات
                .alert("Discard Changes?", isPresented: $showDiscardAlert) {
                    Button("Discard Changes", role: .destructive) {
                        composeTitle = ""
                        composeBody = ""
                        showingComposer = false
                    }
                    Button("Keep Editing", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to discard your changes?")
                }
            }
        }

        // تنبيه الحذف
        .alert("Delete Journal?", isPresented: $showDeleteAlert, presenting: entryToDelete) { entry in
            Button("Delete", role: .destructive) {
                deleteEntry(entry)
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("Are you sure you want to delete this journal?")
        }
    }

    // MARK: - الدوال المساعدة

    // حذف إدخال
    private func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }

    // إضافة إدخال جديد
    private func addEntry(title: String, body: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmedTitle.isEmpty ? "Untitled" : trimmedTitle
        let entry = JournalEntry(id: UUID(), title: finalTitle, body: body, date: Date())
        entries.append(entry)
        sortEntries()
        saveEntries()
    }

    // ترتيب الإدخالات حسب التاريخ
    private func sortEntries() {
        if sortNewestFirst {
            entries.sort { $0.date > $1.date }
        } else {
            entries.sort { $0.date < $1.date }
        }
    }

    // فلترة الإدخالات حسب نص البحث
    private func filteredEntries() -> [JournalEntry] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return entries
        }
        let q = searchText.lowercased()
        return entries.filter {
            $0.title.lowercased().contains(q) || $0.body.lowercased().contains(q)
        }
    }

    // حفظ الإدخالات في AppStorage
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            journalEntriesData = encoded
        }
    }

    // تفعيل أو إلغاء الإشارة (bookmark)
    private func toggleBookmark(entryID: UUID) {
        if let i = entries.firstIndex(where: { $0.id == entryID }) {
            entries[i].bookmarked.toggle()
            saveEntries()
        }
    }
}

// المعاينة في Xcode Preview
#Preview {
    MainPage()
}
