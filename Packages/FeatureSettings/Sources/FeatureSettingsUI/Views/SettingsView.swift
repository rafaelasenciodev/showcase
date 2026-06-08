#if os(iOS)
import DesignSystem
import Domain
import FeatureSettingsCore
import SwiftUI

public struct SettingsView: View {
    @Bindable private var viewModel: SettingsViewModel

    @State private var isRestoreConfirmationPresented = false

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if let settings = viewModel.settings {
                Form {
                    Section("Appearance") {
                        Picker("Theme", selection: Binding(
                            get: { settings.theme },
                            set: { theme in
                                Task { await viewModel.selectTheme(theme) }
                            }
                        )) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.displayName).tag(theme)
                            }
                        }
                    }

                    Section("Articles") {
                        Button("Restore Demo Articles") {
                            isRestoreConfirmationPresented = true
                        }

                        if let restoreMessage = viewModel.restoreMessage {
                            Text(restoreMessage)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    Section("About") {
                        LabeledContent("Version", value: settings.appVersion)
                    }
                    Section("Architecture") {
                        Text(settings.architectureInfo)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            } else if case let .error(message) = viewModel.viewState {
                ErrorStateView(message: message) {
                    Task { await viewModel.onAppear() }
                }
            } else {
                LoadingView()
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog(
            "Restore Demo Articles?",
            isPresented: $isRestoreConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Restore") {
                Task { await viewModel.restoreDemoContent() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Demo articles from the bundled catalog will be re-imported. Your custom articles are kept.")
        }
        .task {
            if viewModel.settings == nil {
                await viewModel.onAppear()
            }
        }
    }
}
#endif
