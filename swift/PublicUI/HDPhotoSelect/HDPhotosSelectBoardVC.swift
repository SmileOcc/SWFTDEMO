//
//  HDPhotosSelectBoardVC.swift
//  HDPublicUIProject
//
//  Created by MountainZhu on 2020/7/27.
//  Copyright © 2020 航电. All rights reserved.
//
//照片选择，拍照，使用方法，HDPhotosSelectBoardVC.shared.showSelectPhotoSheet(self)

import UIKit
import Photos

public protocol HDPhotosSelectBoardVCDelegate : NSObject {
    func photosSelectBoardVC(boardView: HDPhotosSelectBoardVC, image: UIImage)
    func photosSelectBoardVC(boardView: HDPhotosSelectBoardVC, multipleImages: [UIImage])
}

public class HDPhotosSelectBoardVC: UIViewController {

    public static let shared = HDPhotosSelectBoardVC()
    public weak var delegate: HDPhotosSelectBoardVCDelegate?
    var boardVC = UIViewController()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //拍照和单张图片选择
    public func showSelectPhotoSheet(_ vc: UIViewController) {
        self.show(vc, 1)
    }
    
    //拍照和多张图片选择,multiple为最多选择照片张数
    public func showSelectPhotoSheet(_ vc: UIViewController, _ multiple: Int) {
        self.show(vc, multiple)
    }
    
    //私有方法
    private func show(_ vc: UIViewController, _ multiple: Int) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title:"取消", style: .cancel, handler: nil)
        let takingPictures = UIAlertAction(title:"拍照", style: .default) { action in
            self.goCamera(vc)
        }
        let localPhoto = UIAlertAction(title:"本地图片", style: .default) { action in
            if multiple == 1 {
                self.goSingleImage(vc)
            } else {
                self.goMultipleImage(vc, multiple)
            }
        }
        
        alertController.addAction(cancel)
        alertController.addAction(takingPictures)
        alertController.addAction(localPhoto)
        vc.present(alertController, animated:true, completion:nil)
        
        PHPhotoLibrary.shared().register(self)
    }
    
    //直接拍照
    public func goCamera(_ vc: UIViewController) {
        self.delegate = vc as? HDPhotosSelectBoardVCDelegate
        self.boardVC = vc
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = .camera
            cameraPicker.modalPresentationStyle = .fullScreen
            //在需要的地方present出来
            vc.present(cameraPicker, animated: true, completion: nil)
        } else {
            print("不支持拍照")
        }
    }
    
    //直接选择单张图片
    public func goSingleImage(_ vc: UIViewController) {
        self.delegate = vc as? HDPhotosSelectBoardVCDelegate
        self.boardVC = vc
        let photoPicker =  UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.allowsEditing = true
        photoPicker.sourceType = .photoLibrary
        photoPicker.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            let navBar = UINavigationBar.appearance()
            navBar.barTintColor = UIColor.LightGrayTitle()
            navBar.tintColor = UIColor.white
        } else {
             photoPicker.navigationBar.barTintColor = UIColor.LightGrayTitle()
        }
        //在需要的地方present出来
        vc.present(photoPicker, animated: true, completion: nil)
    }
    
    //直接选择多张图片
    public func goMultipleImage(_ vc: UIViewController, _ multiple: Int) {
        self.delegate = vc as? HDPhotosSelectBoardVCDelegate
        self.boardVC = vc
        let assetVC = HDPublishAssetViewController()
        assetVC.count = multiple
        assetVC.handlePhotos = { (assetArray, imageArray) in
            self.delegate?.photosSelectBoardVC(boardView: self, multipleImages: imageArray)
        }
        let naviVC = UINavigationController(rootViewController: assetVC)
        naviVC.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            let navBar = UINavigationBar.appearance()
            navBar.barTintColor = UIColor.LightGrayTitle()
            navBar.tintColor = UIColor.white
        } else {
            naviVC.navigationBar.barTintColor = UIColor.LightGrayTitle()
        }
        vc.present(naviVC, animated: true, completion: nil)
    }
}
    
extension HDPhotosSelectBoardVC : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("获得照片============= \(info)")
        let image : UIImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        //显示设置的照片
        self.delegate?.photosSelectBoardVC(boardView: self, image: image)
        if #available(iOS 13.0, *) {
            let navBar = UINavigationBar.appearance()
            navBar.barTintColor = UIColor.WhiteToBlack()
            navBar.tintColor = UIColor.WhiteToBlack()
        } else {
             picker.navigationBar.barTintColor = UIColor.WhiteToBlack()
        }
        self.boardVC.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if #available(iOS 13.0, *) {
            let navBar = UINavigationBar.appearance()
            navBar.barTintColor = UIColor.WhiteToBlack()
            navBar.tintColor = UIColor.WhiteToBlack()
        } else {
             picker.navigationBar.barTintColor = UIColor.WhiteToBlack()
        }
        self.boardVC.dismiss(animated: true, completion: nil)
    }
}

extension HDPhotosSelectBoardVC: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
}
