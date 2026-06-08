import SwiftUI

public struct ErrorStateView: View {
    private let message: String
    private let retryAction: () -> Void

    public init(message: String, retryAction: @escaping () -> Void) {
        self.message = message
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Something went wrong")
                .font(AppTypography.title)
            Text(message)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            PrimaryButton("Try Again", action: retryAction)
                .frame(maxWidth: 240)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
