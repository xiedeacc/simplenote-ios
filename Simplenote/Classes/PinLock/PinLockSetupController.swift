import Foundation

// MARK: - PinLockSetupControllerDelegate
//
protocol PinLockSetupControllerDelegate: class {
    func pinLockSetupController(_ controller: PinLockSetupController, didSelectPin pin: String)
    func pinLockSetupControllerDidCancel(_ controller: PinLockSetupController)
}

// MARK: - PinLockSetupController
//
class PinLockSetupController: PinLockController {
    private var configuration: PinLockControllerConfiguration = PinLockControllerConfiguration(title: Localization.createPasscode, message: nil)

    var isCancellable: Bool {
        return true
    }

    var configurationObserver: ((PinLockControllerConfiguration, UIView.ReloadAnimation?) -> Void)? {
        didSet {
            configurationObserver?(configuration, nil)
        }
    }

    private var pin: String?
    private weak var delegate: PinLockSetupControllerDelegate?

    init(delegate: PinLockSetupControllerDelegate) {
        self.delegate = delegate
    }

    func handlePin(_ pin: String) {
        guard !pin.isEmpty else {
            self.pin = nil
            switchTo(PinLockControllerConfiguration(title: Localization.createPasscode, message: nil),
                     with: .shake)
            return
        }

        guard let firstPin = self.pin else {
            self.pin = pin
            switchToPinConfirmation()
            return
        }

        guard pin == firstPin else {
            self.pin = nil
            switchTo(PinLockControllerConfiguration(title: Localization.createPasscode, message: Localization.passcodesDontMatch),
                     with: .slideTrailing)
            return
        }

        delegate?.pinLockSetupController(self, didSelectPin: pin)
    }

    func handleCancellation() {
        delegate?.pinLockSetupControllerDidCancel(self)
    }
}

// MARK: - Private
//
private extension PinLockSetupController {
    func switchToPinConfirmation() {
        let configuration = PinLockControllerConfiguration(title: Localization.confirmPasscode, message: nil)
        switchTo(configuration, with: .slideLeading)
    }

    func switchTo(_ configuration: PinLockControllerConfiguration, with animation: UIView.ReloadAnimation) {
        self.configuration = configuration
        configurationObserver?(configuration, animation)
    }
}

// MARK: - Localization
//
private enum Localization {
    static let createPasscode = NSLocalizedString("Choose a 4 digit passcode", comment: "Title on the PinLock screen asking to create a passcode")
    static let confirmPasscode = NSLocalizedString("Confirm your passcode", comment: "Title on the PinLock screen asking to confirm a passcode")
    static let passcodesDontMatch = NSLocalizedString("Passcodes did not match. Try again.", comment: "Pin Lock")
}
