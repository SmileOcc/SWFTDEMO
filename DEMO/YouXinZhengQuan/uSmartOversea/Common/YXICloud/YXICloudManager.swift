//
//  YXICloudManager.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/12/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXICloudManager: NSObject, UIDocumentPickerDelegate {
    @objc public static let documentTypes = [
        "public.content",
        "public.text",
        "public.source-code",
        "public.image",
        "public.audiovisual-content",
        "com.adobe.pdf",
        "com.apple.keynote.key",
        "com.microsoft.word.doc",
        "com.microsoft.excel.xls",
        "com.microsoft.powerpoint.ppt"
    ]
    
    static let MAX_FILE_SIZE: Int = 10 * 1024 * 1024;
    
    @objc public enum YXPickDocumentError: Int {
        case iCloudDisable  // 没有访问权限
        case wasCancelled   // 用户取消
        case tooLarge       // 文件太大
    }
    
    @objc static let shared = YXICloudManager()
    
    var picker: UIDocumentPickerViewController?
    
    var successBlock: ((String, Data)->Void)?
    var failureBlock: ((YXPickDocumentError)->Void)?
    
    private override init() {
        
    }
    
    override func copy() -> Any {
        self
    }
    
    override func mutableCopy() -> Any {
        self
    }
    
    // Optional
    func reset() -> Void {
        // Reset all properties to default value
    }
    
    @objc public class func iCloudEnable() -> Bool {
        let manager = FileManager.default
        if manager.ubiquityIdentityToken != nil {
            return true
        }
        return false
    }
    
    @objc public func pickerDocument(documentTypes: [String] = YXICloudManager.documentTypes, inViewController viewController: UIViewController, successBlock: ((String, Data)->Void)? = nil, failureBlock: ((YXPickDocumentError)->Void)? = nil) {
        self.picker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
        if let picker = self.picker {
            picker.delegate = self
            picker.modalPresentationStyle = .fullScreen
            if #available(iOS 11.0, *) {
                picker.allowsMultipleSelection = false
            }
            viewController.present(picker, animated: true, completion: nil)
        }
        self.successBlock = successBlock
        self.failureBlock = failureBlock
    }
    
    public static func downloadFile(documentUrl url: URL, completion: ((Data) -> Void)? = nil) {
        let document = YXDocument(fileURL: url)
        document.open { (success) in
            if success {
                document.close(completionHandler: nil)
            }
            if let completion = completion {
                completion(document.data)
            }
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let fileName = url.lastPathComponent
        
        YXICloudManager.downloadFile(documentUrl: url) { (data) in
            if data.count >= YXICloudManager.MAX_FILE_SIZE {
                if let failureBlock = self.failureBlock {
                    failureBlock(YXPickDocumentError.tooLarge)
                }
            } else if let successBlock = self.successBlock {
                successBlock(fileName, data)
            }
        }
        
        self.picker?.delegate = nil
        self.picker = nil
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        if let failureBlock = self.failureBlock {
            failureBlock(YXPickDocumentError.wasCancelled)
        }
        
        self.picker?.delegate = nil
        self.picker = nil
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let fileName = urls.first?.lastPathComponent ?? "unknown"
        if let url = urls.first {
            YXICloudManager.downloadFile(documentUrl: url) { (data) in
                if data.count >= YXICloudManager.MAX_FILE_SIZE {
                    if let failureBlock = self.failureBlock {
                        failureBlock(YXPickDocumentError.tooLarge)
                    }
                } else if let successBlock = self.successBlock {
                    successBlock(fileName, data)
                }
            }
        }
        self.picker?.delegate = nil
        self.picker = nil
    }
}
