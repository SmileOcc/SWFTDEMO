//
//  YXFaceIdIDCardQuality.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2018/12/28.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import MobileCoreServices
import MGFaceIDIDCardKit

class YXFaceIdIDCardQuality: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    lazy var imagePicker: UIImagePickerController = {
        let p = UIImagePickerController()
        p.sourceType = .camera
        p.cameraCaptureMode = .photo
        p.cameraDevice = .rear
        p.delegate = self
        return p
    }()
    
    var shootPage: YXIDCardShootPage?
    
    weak var viewController: (UIViewController & YXFaceIdIDCardQualityProtocol)?
    
    @objc public enum YXIDCardShootPage: Int {
        // 双面\人物面\国徽面
        case Double, Portrait, NationalEmblem
    }
    
    /// 开始检测身份证
    ///
    /// - Parameters:
    ///   - viewController: 调用开始检测照片的ViewController
    ///   - shootPage: 检测哪一面(人物面\国徽面\双面)
    ///   - useSystemCameraWhenFailed: 当调用Faceid失败时，是否使用系统默认相机进行拍照替代
    @objc func startDetect(viewController: UIViewController & YXFaceIdIDCardQualityProtocol, shootPage: YXIDCardShootPage, useSystemCameraWhenFailed: Bool = true) -> Void {
#if targetEnvironment(simulator)
#else
        var errorItem: MGFaceIDIDCardErrorItem?
        
        self.shootPage = shootPage
        self.viewController = viewController
        
        let idcardManager = MGFaceIDIDCardManager.init(mgFaceIDIDCardManagerWithExtraData: nil, error: &errorItem)
        if errorItem != nil && idcardManager == nil {
            if let errorMessage = errorItem?.errorMessage {
                print(errorMessage)
                // 如果是同时拍双面的画，那么采用系统拍摄的代码逻辑得调整
                // 此处仅支持拍人物面或国徽面
                if shootPage == .Portrait || shootPage == .NationalEmblem {
                    startSystemCapture(viewController: viewController, shootPage: shootPage)
                }
                return
            }
        }
        
        var faceIdShootPage: MGFaceIDIDCardShootPage
        switch shootPage {
        case .Portrait:
            faceIdShootPage = MGFaceIDIDCardShootPagePortrait
        case .NationalEmblem:
            faceIdShootPage = MGFaceIDIDCardShootPageNationalEmblem
        default:
            faceIdShootPage = MGFaceIDIDCardShootPagePortrait
        }
        idcardManager?.startMGFaceIDIDCardDetect(viewController, screenOrientation: MGFaceIDIDCardScreenOrientationLandscape, shootPage: faceIdShootPage, detectConfig: nil, callback: { (errorItem, detectItem, extraOutDataDic) in
            if (errorItem == nil || errorItem?.errorType == MGFaceIDIDCardErrorNone) {
                if let detectItem = detectItem {
                    let portraitMethod = #selector(viewController.detectFinish(portraitImage:))
                    if viewController.responds(to: portraitMethod) {
                        viewController.performSelector(inBackground: portraitMethod, with: detectItem.idcardImageItem.idcardImage)
                    }
                    
                    let emblemMethod = #selector(viewController.detectFinish(emblemImage:))
                    if viewController.responds(to: emblemMethod) {
                        viewController.performSelector(inBackground: emblemMethod, with: detectItem.idcardImageItem.idcardImage)
                    }
                }
            } else {
                if let errorItem = errorItem {
                    print(errorItem.errorMessage)
                    if errorItem.errorType == MGFaceIDIDCardErrorUserCancel {
                        
                    } else if errorItem.errorType == MGFaceIDIDCardErrorNoCameraPermission {
                        QMUITips.showError("需要相机权限才能使用")
                    } else if errorItem.errorType == MGFaceIDIDCardErrorNoIDCardBothSide || errorItem.errorType == MGFaceIDIDCardErrorNoIDCardFrontSideSingle || errorItem.errorType == MGFaceIDIDCardErrorNoIDCardBackSideSingle {
                        QMUITips.showError("拍摄失败,请重试")
                    } else {
                        QMUITips.showError("拍摄失败,请从相册选择照片")
                    }
                }
            }
        })
#endif
    }
    
    func startSystemCapture(viewController: UIViewController & YXFaceIdIDCardQualityProtocol, shootPage: YXIDCardShootPage) -> Void {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.delegate = self
            self.shootPage = shootPage
            self.viewController = viewController
            viewController.present(self.imagePicker, animated: true, completion: nil);
        } else {
            QMUITips.showError("拍摄失败,请重试")
        }
    }
    
    @objc fileprivate func image(_ image: UIImage?, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("保存照片成功")
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[.mediaType] as? String {
            if mediaType == kUTTypeImage as String {
                var image: UIImage?
                if picker.allowsEditing {
                    image = info[.editedImage] as? UIImage
                } else {
                    image = info[.originalImage] as? UIImage
                }
                
                if let image = image {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                    
                    
                    if let viewController = self.viewController {
                        if self.shootPage == .Portrait {
                            let portraitMethod = #selector(viewController.detectFinish(portraitImage:))
                            if viewController.responds(to: portraitMethod) {
                                viewController.performSelector(inBackground: portraitMethod, with: image)
                            }
                        } else if self.shootPage == .NationalEmblem {
                            let emblemMethod = #selector(viewController.detectFinish(emblemImage:))
                            if viewController.responds(to: emblemMethod) {
                                viewController.performSelector(inBackground: emblemMethod, with: image)
                            }
                        }
                    }
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil);
    }
}
