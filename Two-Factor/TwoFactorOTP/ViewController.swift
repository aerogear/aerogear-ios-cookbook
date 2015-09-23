/**
* JBoss, Home of Professional Open Source
* Copyright Red Hat, Inc., and individual contributors
* by the @authors tag. See the copyright.txt in the distribution for a
* full listing of individual contributors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* http://www.apache.org/licenses/LICENSE-2.0
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit
import AVFoundation
import AeroGear_OTP

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var displayQRCode: UILabel!
    @IBOutlet weak var progressBarView: UIProgressView!
    @IBOutlet weak var scanQRCodeButton: UIButton!
    
    var otp: AGTotp?
    var timer = NSTimer()
    
    var counter:Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 30.0
            let animated = counter != 0
            
            progressBarView.setProgress(fractionalProgress, animated: animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = otp {
            displayQRCode.hidden = false
            progressBarView.hidden = false
            progressBarView.setProgress(0, animated: true)
            scanQRCodeButton.hidden = true
            self.generateOTPAndStartCount()

        } else {
            displayQRCode.hidden = true
            progressBarView.hidden = true
            scanQRCodeButton.hidden = false
        }

    }
    
    private func generateOTPAndStartCount() {
        displayQRCode.text = self.otp!.generateOTP()
        self.counter = 0
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
    internal func update() {
        counter++
        if counter == 30 {
            timer.invalidate()
            // Do again
            generateOTPAndStartCount()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func captureQRCode(sender: AnyObject) {
        self.performSegueWithIdentifier("qrcodecapture:", sender: sender)
    }

}

