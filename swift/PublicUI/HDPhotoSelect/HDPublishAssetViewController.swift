//
//  HDdddViewController.swift
//  HDPublicUIProject
//
//  Created by MountainZhu on 2020/7/27.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit
import Photos

typealias HandlePhotos = ([PHAsset], [UIImage]) -> Void

protocol HDPublishAssetViewControllerDelegate : NSObject {
    func publishAssetViewController(_ vc: HDPublishAssetViewController, _ images: [UIImage])
}

class HDPublishAssetViewController : UIViewController {
    //选择图片数
    public var count: Int = 9
    //选择回调
    public var handlePhotos: HandlePhotos?
    
    //MARK: - 👉Properties
    fileprivate var collectionView: UICollectionView!
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumnailSize = CGSize()
    fileprivate var previousPreheatRect = CGRect.zero
    
    //展示选择数量
    fileprivate var countView: UIView!
    fileprivate var countLabel: UILabel!
    fileprivate var countButton: UIButton!
    fileprivate let countViewHeight: CGFloat = 50
    fileprivate var isShowCountView = false
    
    //回调Asset
    fileprivate var selectedAssets = [PHAsset]() {
        willSet {
            updateCountView(with: newValue.count)
        }
    }
    //回调Image
    fileprivate var selectedImages = [UIImage]()
    
    //选择标识
    fileprivate var flags = [Bool]()
    
    //itemSize
    fileprivate let shape: CGFloat = 3
    fileprivate let numbersInSingleLine: CGFloat = 4
    fileprivate var cellWidth: CGFloat? {
        return (UIScreen.main.bounds.width - (numbersInSingleLine - 1) * shape) / numbersInSingleLine
    }
    weak var assetDelegate: HDPublishAssetViewControllerDelegate?
    
    // MARK: - 👉Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        setupUI()
        
        // 添加数量视图
        addCountView()
        
        // 监测数据源
        if fetchAllPhtos == nil {
            let allOptions = PHFetchOptions()
            allOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchAllPhtos = PHAsset.fetchAssets(with: allOptions)
            collectionView.reloadData()
        }
        
        (0 ..< fetchAllPhtos.count).forEach { _ in
            flags.append(false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 定义缓存照片尺寸
        thumnailSize = CGSize(width: cellWidth! * UIScreen.main.scale, height: cellWidth! * UIScreen.main.scale)
        
        // collectionView 滑动到最底部
        guard fetchAllPhtos.count > 0 else { return }
        let indexPath = IndexPath(item: fetchAllPhtos.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 更新
        updateCachedAssets()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    // MARK: - 👉Public
    //所有图片
    internal var fetchAllPhtos: PHFetchResult<PHAsset>!
    //单个相册
    internal var assetCollection: PHAssetCollection!
    
    // MARK: - 👉Private
    
    //展示
    private func setupUI() {
        self.title = "图片选择"
        
        let cvLayout = UICollectionViewFlowLayout()
        cvLayout.itemSize = CGSize(width: cellWidth!, height: cellWidth!)
        cvLayout.minimumLineSpacing = shape
        cvLayout.minimumInteritemSpacing = shape
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: HDConst.HEIGHT_STATUSBAR_NAVBAR, width: HDConst.SCREENW, height: HDConst.SCREENH - HDConst.HEIGHT_STATUSBAR_NAVBAR), collectionViewLayout: cvLayout)
        view.addSubview(collectionView)
        collectionView.register(GridViewCell.self, forCellWithReuseIdentifier: GridViewCell.cellIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
        addCancleItem()
    }
    
    /// count
    private func addCountView() {
        countView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: countViewHeight))
        countView.backgroundColor = UIColor(white: 0.85, alpha: 1)
        view.addSubview(countView)
        
        countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 35))
        countLabel.backgroundColor = .clear
        countLabel.textColor = .green
        countLabel.textAlignment = .center
        countLabel.text = "0/\(count)"
        countLabel.font = UIFont.systemFont(ofSize: 17)
        countLabel.center = CGPoint(x: countView.bounds.width / 2, y: countView.bounds.height / 2)
        countView.addSubview(countLabel)
        
        countButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 68, y: 0, width: 50, height: countViewHeight))
        countButton.setTitle("完成", for: .normal)
        countButton.setTitleColor(.blue, for: .normal)
        countButton.addTarget(self, action: #selector(selectedOverAction), for: .touchUpInside)
        countView.addSubview(countButton)
    }
    
    
    //照片选择结束
    @objc func selectedOverAction() {
        handlePhotos?(selectedAssets, selectedImages)
        dismissAction()
    }
    
    
    //根据选择照片数量动态展示CountView
    private func updateCountView(with photoCount: Int) {
        countLabel.text = "\(String(describing: photoCount))/\(count)"
        
        if isShowCountView && photoCount != 0 {
            return
        }
        
        if photoCount == 0 {
            isShowCountView = false
            UIView.animate(withDuration: 0.3, animations: {
                self.countView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height)
                //self.collectionView.contentOffset = CGPoint(x: 0, y: self.collectionView.contentOffset.y - self.countViewHeight)
            })
        } else {
            isShowCountView = true
            UIView.animate(withDuration: 0.3, animations: {
                self.countView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - self.countViewHeight)
                //self.collectionView.contentOffset = CGPoint(x: 0, y: self.collectionView.contentOffset.y + self.countViewHeight)
            })
        }
    }
    
    //添加取消按钮
    private func addCancleItem() {
        let barItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(dismissAction))
        navigationItem.rightBarButtonItem = barItem
    }
    @objc func dismissAction() {
        if #available(iOS 13.0, *) {
            let navBar = UINavigationBar.appearance()
            navBar.barTintColor = UIColor.WhiteToBlack()
            navBar.tintColor = UIColor.WhiteToBlack()
        } else {
            self.navigationController?.navigationBar.barTintColor = UIColor.WhiteToBlack()
        }
        dismiss(animated: true, completion: nil)
    }
    
    // 展示选择数量的视图
    
    
    // MARK: PHAsset Caching
    
    //重置图片缓存
    private func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    //更新图片缓存设置
    fileprivate func updateCachedAssets() {
        // 视图可访问时才更新
        guard isViewLoaded && view.window != nil else {
            return
        }
        
        // 预加载视图的高度是可见视图的两倍，这样滑动时才不会有阻塞
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // 只有可见视图与预加载视图有明显不同时，才会更新
        let delta = abs(preheatRect.maxY - previousPreheatRect.maxY)
        guard delta > view.bounds.height / 3 else {
            return
        }
        
        
        // 计算 assets 用来开始和结束缓存
        let (addedRects, removeRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect)}
            .map { indexPath in fetchAllPhtos.object(at: indexPath.item) }
        let removedAssets = removeRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchAllPhtos.object(at: indexPath.item) }
        
        // 更新图片缓存
        imageManager.startCachingImages(for: addedAssets, targetSize: thumnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets, targetSize: thumnailSize, contentMode: .aspectFill, options: nil)
        
        // 保存最新的预加载尺寸用来和后面的对比
        previousPreheatRect = preheatRect
    }
    
    
    //计算新旧位置的差值
    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        
        // 新旧有交集
        if old.intersects(new) {
            
            // 增加值
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY, width: new.width, height: new.maxY - old.maxY)]
            }
            if new.minY < old.minY {
                added += [CGRect(x: new.origin.x, y: new.minY, width: new.width, height: old.minY - new.minY)]
            }
            
            // 移除值
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY, width: new.width, height: old.maxY - new.maxY)]
            }
            if new.minY > old.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY, width: new.width, height: new.minY - old.minY)]
            }
            
            return (added, removed)
        }
        
        // 没有交集
        return ([new], [old])
    }
    
}

extension HDPublishAssetViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchAllPhtos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridViewCell.cellIdentifier, for: indexPath) as! GridViewCell
        
        let asset = fetchAllPhtos.object(at: indexPath.item)
        cell.representAssetIdentifier = asset.localIdentifier
        // 从缓存中取出图片
        imageManager.requestImage(for: asset, targetSize: thumnailSize, contentMode: .aspectFill, options: nil) { img, _ in
            
            // 代码执行到这里时cell可能已经被重用了，所以设置标识用来展示
            if cell.representAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = img
            }
        }
        
        // 防止重复
        cell.cellIsSelected = flags[indexPath.item]
        cell.handleSelectionAction = { isSelected in
            
            // 判断是否超过最大值
            if self.selectedAssets.count > self.count - 1 && !cell.cellIsSelected {
                self.showAlert(with: "haha")
                cell.selectedButton.isSelected = false
                return
            }
            
            self.flags[indexPath.item] = isSelected
            cell.cellIsSelected = isSelected
            
            if isSelected {
                self.selectedAssets.append(self.fetchAllPhtos.object(at: indexPath.item))
                self.selectedImages.append(cell.thumbnailImage!)
            } else {
                let deleteIndex1 = self.selectedAssets.firstIndex(of: self.fetchAllPhtos.object(at: indexPath.item))
                self.selectedAssets.remove(at: deleteIndex1!)
                
                let deleteIndex2 = self.selectedImages.firstIndex(of: cell.thumbnailImage!)
                self.selectedImages.remove(at: deleteIndex2!)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = collectionView.cellForItem(at: indexPath) as! GridViewCell
        handlePhotos?([fetchAllPhtos.object(at: indexPath.item)], [currentCell.thumbnailImage!])
        dismissAction()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    func showAlert(with title: String) {
        let alertVC = UIAlertController(title: "最多只能选择 \(count) 张图片", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
}

// MARK: - 👉PHPhotoLibraryChangeObserver
extension HDPublishAssetViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
}

// MARK: - 👉UICollectionView Extension
private extension UICollectionView {
    //获取可见视图内的所有对象，用于更高效刷新
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

// MARK: - 👉GridViewCell
class GridViewCell: UICollectionViewCell {
    
    // MARK: - 👉Properties
    private var cellImageView: UIImageView!
    private var selectionIcon: UIButton!
    var selectedButton: UIButton!
    
    private let slectionIconWidth: CGFloat = 20
    
    static let cellIdentifier = "GridViewCell-Asset"
    
    // MARK: - 👉LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - 👉Public
    var representAssetIdentifier: String!
    var thumbnailImage: UIImage? {
        willSet {
            cellImageView?.image = newValue
        }
    }
    
    var cellIsSelected: Bool = false {
        willSet {
            selectionIcon.isSelected = newValue
        }
    }
    
    
    //隐藏选择按钮和图标
    func hiddenIcons() {
        selectionIcon.isHidden = true
        selectedButton.isHidden = true
    }
    
    // 点击选择回调
    var handleSelectionAction: ((Bool) -> Void)?
    
    // MARK: - 👉Private
    private func setupUI() {
        // 图片
        cellImageView = UIImageView(frame: bounds)
        cellImageView?.clipsToBounds = true
        cellImageView?.contentMode = .scaleAspectFill
        contentView.addSubview(cellImageView!)
        
        // 选择图标
        selectionIcon = UIButton(frame: CGRect(x: 0, y: 0, width: slectionIconWidth, height: slectionIconWidth))
        selectionIcon.center = CGPoint(x: bounds.width - 2 - selectionIcon.bounds.width / 2, y: selectionIcon.bounds.height / 2)
        let normalPath = "未选中.png"
        let selectPath = "选中.png"
        selectionIcon.setImage(UIImage.init(named: normalPath), for: .normal)
        selectionIcon.setImage(UIImage.init(named: selectPath), for: .selected)
        
        contentView.addSubview(selectionIcon)
        
        // 选择按钮
        selectedButton = UIButton(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        selectedButton.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        selectedButton.backgroundColor = .clear
        contentView.addSubview(selectedButton)
        
        selectedButton.addTarget(self, action: #selector(selectionItemAction(btn:)), for: .touchUpInside)
    }
    
    @objc private func selectionItemAction(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        handleSelectionAction?(btn.isSelected)
    }
}
