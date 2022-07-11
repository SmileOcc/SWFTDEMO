//
//  YXPersonDataViewController.swift
//  uSmartOversea
//
//  Created by rrd on 2019/5/10.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MobileCoreServices
import QCloudCore
import QMUIKit


import SnapKit

class YXPersonDataViewController: YXHKTableViewController, HUDViewModelBased {
    
    var networkingHUD: YXProgressHUD! = YXProgressHUD()
    var viewModel: YXPersonalDataViewModel!
    
    var tempImage:UIImage? //暂存图片
    
    //头像
    lazy var avatarUrl: String = YXUserManager.shared().curLoginUser?.avatar ?? ""
    
    var dataSource: [[CommonCellData]] = {
        //section = 0
        var cellArr = [CommonCellData]()
        var avatarName:String = "user_default_photo"
        var nickName:String = ""
        if YXUserManager.isLogin() {
            avatarName = YXUserManager.shared().curLoginUser?.avatar ?? ""
            nickName = YXUserManager.shared().curLoginUser?.nickname ?? ""
        }
        //头像
        var headPortaitCell = CommonCellData(imageUrl: ("",""), title: YXLanguageUtility.kLang(key: "user_headPortrait"), describeStr: nil, showArrow: true, showLine: true, describeImgUrl: (avatarName, UIImage(named: "user_default_photo")!))
        //昵称
        var nickNameCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_nickName"), describeStr: nickName, showArrow: true, showLine: false)
        cellArr.append(headPortaitCell)
        cellArr.append(nickNameCell)
        
        return [cellArr]
    }()
    
    override var pageName: String {
            return "Personal Information"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindViewModel()
        bindHUD()
        // Do any additional setup after loading the view.
    }
    func bindViewModel() {
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: YXUserManager.notiUpdateUserInfo))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let strongSelf = self else { return }
                strongSelf.reloadData()
            })
    }
    func initUI() {
        //右导航
        self.view.backgroundColor = QMUITheme().foregroundColor()
        self.tableView.backgroundColor = QMUITheme().foregroundColor()
        self.title = YXLanguageUtility.kLang(key: "user_personalData")
        self.tableView.separatorStyle = .none
        
    }
    func reloadData() {
        self.avatarUrl = YXUserManager.shared().curLoginUser?.avatar ?? ""
        
        var headPortaitCell = self.dataSource[0][0]
        var nickNameCell = self.dataSource[0][1]
        
        var avatar:UIImage?
        if let temp = self.tempImage {
            avatar = temp
        }
        var nickName:String = ""
        if YXUserManager.isLogin() {
            //avatarName = YXUserManager.shared().curLoginUser?.avatar ?? ""
            
            nickName = YXUserManager.shared().curLoginUser?.nickname ?? ""
        }
        //头像
        headPortaitCell = CommonCellData(imageUrl: ("",""), title: YXLanguageUtility.kLang(key: "user_headPortrait"), describeStr: nil, showArrow: true, showLine: true, describeImgUrl: ((YXUserManager.shared().curLoginUser?.avatar ?? ""), avatar ?? nil))
        //昵称
        nickNameCell = CommonCellData(image: nil, title: YXLanguageUtility.kLang(key: "user_nickName"), describeStr: nickName, showArrow: true, showLine: false)
        self.dataSource[0][0] = headPortaitCell
        self.dataSource[0][1] = nickNameCell
        
        self.tableView.reloadData()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension YXPersonDataViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = YXPersonalDataTableViewCell(style: .default, reuseIdentifier: "YXPersonalDataTableViewCell")
        cell.cellModel = dataSource[indexPath.section][indexPath.row]
        cell.refreshUI()
        return cell
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            //头像
            showPhotoAlert()
        }
        else if indexPath.section == 0 && indexPath.row == 1 {
            //昵称
            //self.viewModel.steps.accept(YXUserCenterStep.modifyNickName)
            self.viewModel.navigator.push(YXModulePaths.modifyNickName.url)
        }
        
    }
    //row的高度
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 80
        }
        return 50
    }
}
extension YXPersonDataViewController:UIImagePickerControllerDelegate, YYImageClipDelegate {
    
    //UINavigationControllerDelegate
    
    
    //MARK: - 1、点击头像的 弹框选择
    func showPhotoAlert() {
        
        let sheet = YXSheetViewController.init(.zero)
        let cancleAction = YXSheetAction.init(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancelStyle,hiddenLine: false,handel: nil)
        let viewAction = YXSheetAction.init(title: YXLanguageUtility.kLang(key: "mine_userDataHeader"), style: .defaultStyle,hiddenLine: true) {[weak self] in
            self?.previewImage()
        }
        let takeActon = YXSheetAction.init(title: YXLanguageUtility.kLang(key: "mine_camera"), style: .defaultStyle, hiddenLine: false) {[weak self] in
            self?.showCamera()
        }
        
        let albumActon = YXSheetAction.init(title: YXLanguageUtility.kLang(key: "mine_userDataAlbum"), style: .defaultStyle, hiddenLine: false) {[weak self] in
            self?.showImageLibrary()
        }
        sheet.addAction(albumActon)
        sheet.addAction(takeActon)
        if avatarUrl.isNotEmpty() {
            sheet.addAction(viewAction)
        }
        sheet.addAction(cancleAction)
        sheet.showIn(self)
        
    }
    //从相册选择
    private func showImageLibrary() {
        let iPickerVC:TZImagePickerController = TZImagePickerController.init(maxImagesCount: 1, delegate: nil)
        iPickerVC.preferredLanguage = YXLanguageUtility.identifier()
        iPickerVC.naviTitleColor = QMUITheme().textColorLevel1();
        iPickerVC.barItemTextColor = QMUITheme().textColorLevel1();
        iPickerVC.iconThemeColor = QMUITheme().themeTextColor();
        iPickerVC.naviBgColor = QMUITheme().foregroundColor()
        iPickerVC.allowCrop = true
        iPickerVC.cropRect = CGRect(x: 0, y: (YXConstant.screenHeight - YXConstant.screenWidth) / 2, width: YXConstant.screenWidth, height: YXConstant.screenWidth)
        iPickerVC.naviTitleFont = UIFont.systemFont(ofSize: 16)
        iPickerVC.navLeftBarButtonSettingBlock = {(leftButton) in
            leftButton?.setImage(UIImage(named: "nav_back"), for: .normal)
            leftButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: -32, bottom: 0, right: 0)
        }
        iPickerVC.oKButtonTitleColorNormal = QMUITheme().themeTextColor()
        iPickerVC.oKButtonTitleColorDisabled = QMUITheme().themeTextColor().withAlphaComponent(0.4)
        iPickerVC.sortAscendingByModificationDate = false
        iPickerVC.allowPickingOriginalPhoto = false
        iPickerVC.allowPickingVideo = false
        iPickerVC.allowTakePicture = false
        iPickerVC.showSelectedIndex = true
        //iPickerVC.statusBarStyle = .lightContent
        
        iPickerVC.didFinishPickingPhotosHandle = {[weak self] (photos, assets, isSelectOriginalPhoto) in
            guard let `self` = self else {return}
            if let photos = photos {
                for image in photos {
                    let compressImage = image.compressImageQuality(withMaxLength: 3072 * 1000)
                    self.tempImage = compressImage.drawCorner(in: CGRect(x: 0, y: 0, width: 50, height: 50), cornerRadius: 25)//把图片存起来
                    let tempPath = QCloudTempFilePathWithExtension("png")
                    let data = compressImage.pngData()
                    do {
                        try data?.write(to: URL(fileURLWithPath: tempPath ?? ""), options: .atomic)
                    } catch {
                        print("image write failed")
                    }
                    self.viewModel.tempPath = tempPath
                    self.viewModel.image = image
                }
                self.viewModel.assets = assets
                let fileName = String(format: "avatar/iOS_avatar_%llu_%ld.jpg", YXUserManager.userUUID(), Int(Date().timeIntervalSince1970 * 1000))
                var region = YXQCloudService.keyQCloudHongKong
                if YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk {
                    region = YXQCloudService.keyQCloudSingapore
                } else {
                    region = YXQCloudService.keyQCloudGuangZhou
                }
                let bucket = YXUrlRouterConstant.headerImageBucket()
                YXUserManager.updateToken(fileName: fileName, region: region, bucket: bucket) {
                    self.viewModel.hudSubject.onNext(.hide)
                    self.viewModel.uploadImageRequest(fileName: fileName, region: region, bucket: bucket)
                } failed: { (msg) in
                    self.viewModel.hudSubject.onNext(.error(msg, false))
                }

            }
        }
        iPickerVC.modalPresentationStyle = .fullScreen
        self.present(iPickerVC, animated: true) {
            
        }
    }
    //相机
    private func showCamera() {
        
        
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let ipController = UIImagePickerController()
            ipController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            //ipController.allowsEditing = true
            ipController.sourceType = .camera
            ipController.cameraDevice = .rear
            ipController.mediaTypes = [(kUTTypeImage as String)]
            self.present(ipController, animated: true) {
            }
        }
    }
    //查看图像
    private func previewImage() {
        if avatarUrl.isNotEmpty(), let url = URL(string: avatarUrl) {
            //XLPhotoBrowser.show(withImages: [url], currentImageIndex: 0)
            XLPhotoBrowser.showAndSave(withImages: [url], currentImageIndex: 0)
        }
    }
    
    //MARK:UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        let clipVC: YYImageClipViewController = YYImageClipViewController.init(image: image, cropFrame: CGRect(x:0, y:(YXConstant.screenHeight - YXConstant.screenWidth) / 2.0, width:YXConstant.screenWidth, height: YXConstant.screenWidth), limitScaleRatio: 3)
        clipVC.delegate = self as YYImageClipDelegate
        picker.pushViewController(clipVC, animated: false)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: YYImageClipDelegate
    func imageCropper(_ clipViewController: YYImageClipViewController!, didFinished editedImage: UIImage!) {
        DispatchQueue.global().async(execute: {
            //临时保存路径
            let compressImage = editedImage.compressImageQuality(withMaxLength: 3072 * 1000)
            self.tempImage = compressImage.drawCorner(in: CGRect(x: 0, y: 0, width: 50, height: 50), cornerRadius: 25)//把图片存起来
            let tempPath = QCloudTempFilePathWithExtension("png")
            let data = compressImage.pngData() //compressImage.pngData()
            do {
                try data?.write(to: URL(fileURLWithPath: tempPath ?? ""), options: .atomic)
            } catch {
                print("image write failed")
            }
            self.viewModel.tempPath = tempPath
            DispatchQueue.main.async(execute: {                
                let fileName = String(format: "avatar/iOS_avatar_%llu_%ld.jpg", YXUserManager.userUUID(), Int(Date().timeIntervalSince1970 * 1000))
                var region = YXQCloudService.keyQCloudHongKong
                if YXConstant.targetMode() == .prd || YXConstant.targetMode() == .prd_hk {
                    region = YXQCloudService.keyQCloudHongKong
                } else {
                    region = YXQCloudService.keyQCloudGuangZhou
                }
                let bucket = YXUrlRouterConstant.headerImageBucket()
                YXUserManager.updateToken(fileName: fileName, region: region, bucket: bucket) {
                    self.viewModel.hudSubject.onNext(.hide)
                    self.viewModel.uploadImageRequest(fileName: fileName, region: region, bucket: bucket)
                } failed: { (msg) in
                    self.viewModel.hudSubject.onNext(.error(msg, false))
                }
            })
        })
        self.viewModel.image = editedImage
        
        clipViewController.dismiss(animated: true, completion: nil)
    }
    
    func imageCropperDidCancel(_ clipViewController: YYImageClipViewController!) {
        clipViewController.dismiss(animated: true, completion: nil)
    }
}

