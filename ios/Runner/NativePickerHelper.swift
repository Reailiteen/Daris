import SwiftUI
import FamilyControls

class NativePickerHelper: ObservableObject {
  static let shared = NativePickerHelper()
  
  @Published var selection = FamilyActivitySelection()
  
  func presentPicker(from viewController: UIViewController, completion: @escaping (FamilyActivitySelection) -> Void) {
    let picker = FamilyActivityPicker(selection: Binding(
      get: { self.selection },
      set: { newValue in
        self.selection = newValue
        completion(newValue)
      }
    ))
    
    let hostingController = UIHostingController(rootView: picker)
    viewController.present(hostingController, animated: true)
  }
}
