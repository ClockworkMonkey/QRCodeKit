# QRCodeKit

* Generate a QR Code.
* Scan the QR Code.

![Generate QR Code](https://i.loli.net/2020/09/23/BAS4huaJm3LMct9.png)

![Scan QR Code](https://i.loli.net/2020/09/23/XBJjVzaOvkDgbmR.png)

# Installation

## Swift Package Manager

using Xcode:

File > Swift Packages > Add Package Dependency

# How to use

* import

```swift
import QRCodeKit
```
* info.plist

```swift
Privacy - Camera Usage Description
```

## QRCGenerator

```swift
  let url = "https://github.com/ClockworkMonkeyStudios/QRCodeKit.git"
  guard let qrCodeImage = QRCGenerator.generateQRCode(from: url) else { return }
```
## QRCScannerView

```swift
import UIKit
import QRCodeKit

class ScannerViewController: UIViewController {

    @IBOutlet weak var scannerView: QRCScannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scannerView.setupScanner(delegate: self)
        scannerView.startScanning()
    }

}

extension ScannerViewController: QRCScannerViewDelegate {
    
    func scannerView(_ scannerView: QRCScannerView, didFinishWithMessage message: String) {
        print(message)
        scannerView.stopScanning()
    }
    
    func scannerView(_ scannerView: QRCScannerView, didFailWithError error: Error) {
        print(error)
        scannerView.stopScanning()
    }
    
}
```
