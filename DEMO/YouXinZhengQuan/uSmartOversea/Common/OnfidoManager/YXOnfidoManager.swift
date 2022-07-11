//
//  YXOnfidoManager.swift
//  uSmartOversea
//
//  Created by 欧冬冬 on 2022/5/31.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import Onfido
//import OnfidoExtended

/**
 
 The SDK supports and maintains the following 7 languages:
 
 English (en) 🇬🇧
 Spanish (es) 🇪🇸
 French (fr) 🇫🇷
 German (de) 🇩🇪
 Italian (it) 🇮🇹
 Portuguese (pt) 🇵🇹
 Dutch (nl) 🇳🇱
 */


//SDK tokens expire after 90 minutes.


//{
//"code":0,
//"desc":"success"，
//"data": {
//"frontDocumentId": "",
//"frontDocumentType": "",
//"backDocumentId": "",
//"backDocumentType": "",
//"documentVideoId": "",
//"faceId": "",
//"faceType": ""
//}
//}

/**
 自定义ui
 let appearance = Appearance()
 appearance.primaryColor = <DESIRED_UI_COLOR_HERE>
 appearance.primaryTitleColor = <DESIRED_UI_COLOR_HERE>
 appearance.secondaryTitleColor = <DESIRED_UI_COLOR_HERE>
 appearance.primaryBackgroundPressedColor = <DESIRED_UI_COLOR_HERE>
 appearance.secondaryBackgroundPressedColor = <DESIRED_UI_COLOR_HERE>
 appearance.borderCornerRadius = <DESIRED_CGFLOAT_BORDER_RADIUS_HERE>
 appearance.fontRegular = <DESIRED_FONT_NAME_HERE>
 appearance.fontBold = <DESIRED_FONT_NAME_HERE>
 appearance.supportDarkMode = <true | false>
 appearance.captureSuccessColors = <CaptureSuccessColors object>

 let configBuilder = OnfidoConfig.builder()
 configBuilder.withAppearance(appearance)
 
 */

/**
 switch response {
 case .error(let error):
     switch error {
         
     case OnfidoFlowError.cameraPermission:
         print("It happens if the user denies permission to the sdk during the flow")
     case OnfidoFlowError.failedToWriteToDisk:
         print("It happens when the SDK tries to save capture to disk, maybe due to a lack of space")
     case OnfidoFlowError.microphonePermission:
         print("It happens when the user denies permission for microphone usage by the app during the flow")
     case OnfidoFlowError.upload(let OnfidoApiError):
         // It happens when the SDK receives an error from a API call see [https://documentation.onfido.com/#errors](https://documentation.onfido.com/#errors) for more information
         print("It happens when the SDK receives an error from a API")

     case OnfidoFlowError.exception(withError: let error, withMessage: let message):
         // It happens when an unexpected error occurs, please contact [ios-sdk@onfido.com](mailto:ios-sdk@onfido.com?Subject=ISSUE%3A) when this happens
         print("It happens when an unexpected error occurs, please contact")

     default: // necessary because swift
         print("necessary because swift")
     }
     
     compelete([:], nil)
 case .success(let results):
     
     
 case .cancel(let reason):
     
     
     
 @unknown default:
     resultCode = "101"
 }
 */

struct YXOnfidoError: Swift.Error {
    
    public let code: Int
    
    public let errorMessageStr: String
    
    public init(_ code: Int, errorMessageStr: String) {
        self.code = code
        self.errorMessageStr = errorMessageStr
    }
}


class YXOnfidoManager: NSObject {

    @objc static let shared = YXOnfidoManager()
    
    func showFaceCheck(_ sdkToken: String, currentVC: UIViewController, compelete: @escaping (_ dictionary: Dictionary<String, Any>?, _ error: YXOnfidoError?) -> Void) -> Void {
        
        //let config = try! OnfidoConfig.builder().withSDKToken(sdkToken, expireHandler: getSDKToken)
        
        var config: OnfidoConfig?
        
        do {
            config = try OnfidoConfig.builder()
                .withSDKToken(sdkToken)
//                .withWelcomeStep()
//                .withDocumentStep()
//                .withProofOfAddressStep()
//                .withFaceStep(ofVariant: .photo(withConfiguration: nil))
//                .withFaceStep(ofVariant: .photo(withConfiguration: PhotoStepConfiguration(showSelfieIntroScreen: true)))
                .withFaceStep(ofVariant: .video(withConfiguration: VideoStepConfiguration(showIntroVideo: true, manualLivenessCapture:true)))
//                .withFaceStep(ofVariant: .activeVideo) //验证是个活人
                //.withCustomLocalization() // will look for localizable strings in your Localizable.strings file
                .build()
            
        } catch let error {
            var errorMsg = ""
            switch error {
            case OnfidoConfigError.missingSDKToken:
                errorMsg = "missingSDKToken"
            case OnfidoConfigError.invalidSDKToken:
                errorMsg = "invalidSDKToken"
            case OnfidoConfigError.invalidCountryCode:
                errorMsg = "invalidCountryCode"
            default:
                errorMsg = "config error"
            }
            print(errorMsg)
            self.showErrorMessage(forError: error)
            
            
            compelete(nil, YXOnfidoError.init(100, errorMessageStr: errorMsg))
            return
        }
       
        
        if (config != nil) {
            
            let responseHandler: (OnfidoResponse) -> Void = { response in
                
                var errorCode = 100
                var errorMsg = ""
                var jsData = Dictionary<String, Any>()

                if case OnfidoResponse.error(let innerError) = response {
                    self.showErrorMessage(forError: innerError)
                    compelete(nil, YXOnfidoError.init(100, errorMessageStr: "innerError"))
                    return
                    
                } else if case OnfidoResponse.success(let results) = response {
                    
                    jsData["frontDocumentId"] = ""
                    jsData["frontDocumentType"] = ""
                    jsData["backDocumentId"] = ""
                    jsData["backDocumentType"] = ""
                    jsData["documentVideoId"] = ""
                    jsData["faceId"] = ""
                    jsData["faceType"] = ""
                    let document: Optional<OnfidoResult> = results.filter({ result in
                      if case OnfidoResult.document = result { return true }
                      return false
                    }).first

                    if let documentUnwrapped = document, case OnfidoResult.document(let documentResult) = documentUnwrapped {
                        jsData["frontDocumentId"] = documentResult.front.id
                        jsData["backDocumentId"] = documentResult.back?.id ?? ""

                    }
                    
                    let face: Optional<OnfidoResult> = results.filter ({ resut  in
                        if case OnfidoResult.face = resut { return true}
                        return false
                    }).first
                    
                    if let faceUnwrapped = face, case OnfidoResult.face(let faceResult) = faceUnwrapped {
                        jsData["faceId"] = faceResult.id
                        jsData["faceType"] = faceResult.variant == .video ? "VIDEO" : "PHOTO"
                    }
                    
                    compelete(jsData, nil)
                    return
                    
                } else if case OnfidoResponse.cancel(let reason) = response {
                   
                    switch reason {
                    case .userExit:
                        errorCode = 101
                        errorMsg = "userExit"
                    case .deniedConsent://拒绝
                        errorCode = 100
                        errorMsg = "deniedConsent"
                    @unknown default:
                        errorCode = 100
                        errorMsg = "cancel"
                    }
                    compelete(nil, YXOnfidoError.init(errorCode, errorMessageStr: errorMsg))
                }
            }
            
            let onfidoFlow = OnfidoFlow(withConfiguration: config!)
                .with(responseHandler: responseHandler)

            do {
                let onfindoRun = try onfidoFlow.run()
                
                // due to iOS 13 you must specify .fullScreen as the default is now .pageSheet
                var modalPresentationStyle: UIModalPresentationStyle = .fullScreen
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    modalPresentationStyle = .formSheet // to present modally on iPads
                }
                
                onfindoRun.modalPresentationStyle = modalPresentationStyle
                
                currentVC.present(onfindoRun, animated: true, completion: nil)
            }
            catch let error {
                var errorMsg = ""
                switch error {
                case OnfidoFlowError.cameraPermission:
                    // do something about it here
                    errorMsg = "cameraPermission"
                case OnfidoFlowError.microphonePermission:
                    // do something about it here
                    errorMsg = "microphonePermission"
                default:
                    // should not happen, so if it does, log it and let us know
                    errorMsg = "onfido unkonw"
                }
                self.showErrorMessage(forError: error)
                compelete(nil, YXOnfidoError.init(100, errorMessageStr: errorMsg))

            }
            
        } else {
            //应该 重新获取sdktonken
            compelete(nil, YXOnfidoError.init(100, errorMessageStr: "config error"))
        }
    }
    
    
    private func showErrorMessage(forError error: Error) {
//        let alert = UIAlertController(title: "Error", message: "Onfido SDK errored \(error)", preferredStyle: .alert)
//        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in })
//        alert.addAction(alertAction)
//        UIViewController.current().present(alert, animated: true, completion: nil)
    }
    
    
    
    /**
     
     func getSDKToken(_ completion: @escaping (String) -> Void) {
     let apiToken = ""
     let bundleId = YXConstant.bundleId ?? ""
     let applicant_id = ""
     
     onfidoProvider.request(.onfidoSDKToken(apiToken, applicant_id, bundleId)) { result in
     switch result {
     case let .success(moyaResponse):
     do {
     let json = try moyaResponse.mapString()
     let jsonData = Data(json.utf8)
     let decoder = JSONDecoder()
     completion("")
     } catch {
     completion("")
     }
     case .failure(_):
     completion("")
     }
     }
     
     }
     */
}
