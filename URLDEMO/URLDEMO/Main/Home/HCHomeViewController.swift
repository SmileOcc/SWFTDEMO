//
//  HCHomeViewController.swift
//  URLDEMO
//
//  Created by odd on 7/3/22.
//

import UIKit

class HCHomeViewController: HCBaseViewController , HCViewModelBased{

    var viewModel: HCHomeViewModel!

    lazy var homeCollectView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = UIColor.gray
        view.register(HCHomeCCell.self,
                      forCellWithReuseIdentifier: NSStringFromClass(HCHomeCCell.self))
        view.register(HCHomeHeaderView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: NSStringFromClass(HCHomeHeaderView.self))

        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Home"
        
//        #if DEV || SIT
//        self.view.backgroundColor = UIColor.link
//        #elseif UAT
//        self.view.backgroundColor = UIColor.green
//        #else
//        self.view.backgroundColor = UIColor.purple
//        #endif
        
        
        self.view.addSubview(homeCollectView)
        
        homeCollectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let refreshHeader = HCRefreshHeader()
//        let header = MJRefreshNormalHeader()
//        header.setTitle("下拉刷新", for: .idle)
//          header.setTitle("释放更新", for: .pulling)
//          header.setTitle("正在刷新...", for: .refreshing)
//        self.homeCollectView.mj_header = header
        
        refreshHeader.refreshingBlock = { [weak self, weak refreshHeader] in
            print("刷新")
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                print("刷新222")

                // 这种，如果有尾部加载更多的话，会隐藏
                self?.homeCollectView.showRequestTip([:])
                self?.viewModel.testRequest()
                
//                self?.homeCollectView.showRequestTip([kTotalPageKey:"2", kCurrentPageKey: "1"])

//            })
        }
        homeCollectView.mj_header = refreshHeader
        
        homeCollectView.mj_footer = HCRefreshAuotNormalFooter(refreshingBlock: {[weak self, weak refreshHeader] in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                print("加载222")

//                self?.homeCollectView.mj_header.endRefreshing()
//                kTotalPageKey  : @(1),
//                                                       kCurrentPageKey: @(1)
//                self?.homeCollectView.showRequestTip([:])
                
                self?.homeCollectView.showRequestTip([kTotalPageKey:"1", kCurrentPageKey: "1"])

            })
        })
        
//        homeCollectView.mj_header = HCRefreshHeader(refreshingBlock: {
//
//            print("刷新")
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
//                self.homeCollectView.mj_header.endRefreshing()
//            })
//        })
//        homeCollectView.mj_header.ignoredScrollViewContentInsetTop = 40
//        homeCollectView.mj_header.isAutomaticallyChangeAlpha = true

    }
    

    lazy var loginBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.green
        btn.setTitle("xxx", for: .normal)
        return btn
    }()
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension HCHomeViewController:
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        6
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NSStringFromClass(HCHomeCCell.self),
            for: indexPath
        ) as! HCHomeCCell
        cell.backgroundColor = STLRandomColor()
       

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: NSStringFromClass(HCHomeHeaderView.self),
                for: indexPath
            ) as! HCHomeHeaderView

            header.backgroundColor = .white

            return header
        }
        return UICollectionReusableView()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: self.view.bounds.size.width, height: 120)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: self.view.bounds.size.width, height: 0.01)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.viewModel.navigator.push(HCModulePaths.market.url)
    }
}
