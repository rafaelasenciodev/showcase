import DesignSystem
import Domain
import SwiftUI

public struct SettingsView: View {
    @Bindable private var viewModel: SettingsViewModel

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
        .task {
            if viewModel.settings == nil {
                await viewModel.onAppear()
            }
        }
    }
}
