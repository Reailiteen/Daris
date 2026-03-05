import SwiftUI
import FamilyControls

private struct PickerSheet: View {
  @Binding var selection: FamilyActivitySelection
  let onDone: () -> Void

  var body: some View {
    NavigationView {
      FamilyActivityPicker(selection: $selection)
        .navigationTitle("Block Apps")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Done") { onDone() }
              .fontWeight(.semibold)
          }
        }
    }
  }
}

class NativePickerHelper: ObservableObject {
  static let shared = NativePickerHelper()

  @Published var selection = FamilyActivitySelection()

  func presentPicker(from viewController: UIViewController, completion: @escaping (FamilyActivitySelection) -> Void) {
    var hostingController: UIHostingController<PickerSheet>?

    let sheet = PickerSheet(
      selection: Binding(
        get: { self.selection },
        set: { self.selection = $0 }
      ),
      onDone: {
        completion(self.selection)
        hostingController?.dismiss(animated: true)
      }
    )

    hostingController = UIHostingController(rootView: sheet)
    viewController.present(hostingController!, animated: true)
  }
}
