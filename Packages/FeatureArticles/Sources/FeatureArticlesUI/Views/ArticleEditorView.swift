#if os(iOS)
import DesignSystem
import Domain
import FeatureArticlesCore
import SwiftUI

public struct ArticleEditorView: View {
    @Bindable private var viewModel: ArticleEditorViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: ArticleEditorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Article") {
                    TextField("Title", text: $viewModel.title)
                    TextField("Author", text: $viewModel.author)
                    TextField("Summary", text: $viewModel.summary, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Content") {
                    TextEditor(text: $viewModel.content)
                        .frame(minHeight: 160)
                }

                if let validationError = viewModel.validationError {
                    Section {
                        Text(validationError)
                            .foregroundStyle(.red)
                            .font(AppTypography.caption)
                    }
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if await viewModel.save() != nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
        }
    }
}
#endif
