import SwiftUI

struct SettingsView: View {
    @State private var showProSheet = false
    @State private var isDarkMode = true
    @State private var autoSave = true
    @State private var showGrid = false
    @State private var defaultLanguage = "Arabic"
    @State private var exportQuality = "High"
    
    var body: some View {
        NavigationStack {
            List {
                // Pro Section
                Section {
                    Button { showProSheet = true } label: {
                        HStack(spacing: DS.Spacing.md) {
                            ZStack {
                                RoundedRectangle(cornerRadius: DS.Radius.sm)
                                    .fill(DS.Colors.goldGradient)
                                    .frame(width: 44, height: 44)
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(DS.Colors.textInverse)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Al Fannan Pro")
                                    .font(DS.Typography.titleSmall)
                                    .foregroundColor(DS.Colors.primary)
                                Text("Unlock all premium features")
                                    .font(DS.Typography.caption)
                                    .foregroundColor(DS.Colors.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(DS.Colors.textTertiary)
                        }
                    }
                }
                .listRowBackground(DS.Colors.bgCard)
                
                // Editor Settings
                Section("Editor / المحرر") {
                    Toggle("Auto-Save Projects", isOn: $autoSave)
                    Toggle("Show Grid", isOn: $showGrid)
                    
                    HStack {
                        Text("Default Language")
                        Spacer()
                        Picker("", selection: $defaultLanguage) {
                            Text("Arabic").tag("Arabic")
                            Text("English").tag("English")
                        }
                        .pickerStyle(.menu)
                        .tint(DS.Colors.primary)
                    }
                    
                    HStack {
                        Text("Export Quality")
                        Spacer()
                        Picker("", selection: $exportQuality) {
                            Text("Standard").tag("Standard")
                            Text("High").tag("High")
                            Text("Maximum").tag("Maximum")
                        }
                        .pickerStyle(.menu)
                        .tint(DS.Colors.primary)
                    }
                }
                .listRowBackground(DS.Colors.bgCard)
                
                // Appearance
                Section("Appearance / المظهر") {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
                .listRowBackground(DS.Colors.bgCard)
                
                // About
                Section("About / حول") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(DS.Colors.textTertiary)
                    }
                    
                    Link(destination: URL(string: "https://andalusi.app/legal/terms")!) {
                        HStack {
                            Text("Terms of Use")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                        }
                    }
                    
                    Link(destination: URL(string: "https://www.andalusi.app/legal/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                        }
                    }
                    
                    HStack {
                        Text("Rate the App")
                        Spacer()
                        Image(systemName: "star.fill")
                            .foregroundColor(DS.Colors.primary)
                    }
                }
                .listRowBackground(DS.Colors.bgCard)
                
                // Credits
                Section {
                    VStack(spacing: DS.Spacing.xs) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(DS.Colors.goldGradient)
                        Text("Al Fannan")
                            .font(DS.Typography.titleSmall)
                            .foregroundColor(DS.Colors.textPrimary)
                        Text("الفنان")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DS.Colors.primary)
                        Text("Design Beautifully in Arabic & English")
                            .font(DS.Typography.caption)
                            .foregroundColor(DS.Colors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DS.Spacing.md)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(DS.Colors.bgPrimary)
            .navigationTitle("Settings")
            .tint(DS.Colors.primary)
        }
        .sheet(isPresented: $showProSheet) {
            ProSubscriptionView()
        }
    }
}
