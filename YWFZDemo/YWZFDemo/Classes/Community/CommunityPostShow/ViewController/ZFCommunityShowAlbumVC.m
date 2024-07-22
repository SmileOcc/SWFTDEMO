//
//  ZFCommunityShowAlbumVC.m
//  ZZZZZ
//
//  Created by YW on 2019/10/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityShowAlbumVC.h"
#import "ZFCameraViewController.h"

#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFAlbumManager.h"
#import "ZFFrameDefiner.h"
#import "ZFCommunityNavBarView.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFCommunityAlbumCCell.h"
#import "ZFCommunityAlbumGroupCell.h"

#import "Masonry.h"
#import "ZFProgressHUD.h"
#import "YWCFunctionTool.h"
#import "NSStringUtils.h"
#import "ZFCommunityAlbumOperateView.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "LBXPermissionSetting.h"
#import "LBXPermission.h"
#import "ZFCommunityAlbumCollectionView.h"

@interface ZFCommunityShowAlbumVC ()
<
ZFInitViewProtocol,
UICollectionViewDelegateFlowLayout,
UICollectionViewDataSource,
UITableViewDelegate,
UITableViewDataSource,
UIScrollViewDelegate
>

@property (nonatomic, strong) ZFCommunityNavBarView      *showNavigationBar;
@property (nonatomic, strong) UIControl                  *titleViewControl;
@property (nonatomic, strong) UILabel                    *titleLabel;
@property (nonatomic, strong) UIImageView                *arrowImageView;



@property (nonatomic, strong) UIView                        *mainView;
@property (nonatomic, strong) ZFCommunityAlbumOperateView   *pictureOperateView;


@property (nonatomic, strong) ZFCommunityAlbumCollectionView           *albumCollectionView;
@property (nonatomic, strong) UITableView                *albumGroupTableView;

@property (nonatomic, strong) UIView                     *emptTipView;
@property (nonatomic, strong) UILabel                    *photoAuthMessageLabel;



@property (nonatomic, strong) NSIndexPath                *markIndexPath;


@property (nonatomic, assign) CGFloat                    operateOffsetY;

@property (nonatomic, assign) CGFloat                    lastContentOffsetY;
@property (nonatomic, assign) CGFloat                    endContentOffsetY;
@property (nonatomic, assign) CGFloat                    startMoveOffsetY;
@property (nonatomic, assign) CGFloat                    startOperateDownMoveOffsetY;
@property (nonatomic, assign) BOOL                       isOperateStartMoveDown;
@property (nonatomic, assign) BOOL                       moveDirection;





@property (nonatomic,strong) NSMutableArray <PYAblumModel *> *fetchResultsArray;
@property (nonatomic,strong) NSMutableArray <PYAssetModel *> *assetModelArray;
@property (nonatomic, strong) NSMutableArray <PYAssetModel *> *selectAssetModelArray;

@property (nonatomic, assign) CGFloat phototWidth;

@end

@implementation ZFCommunityShowAlbumVC


- (void)dealloc {
    [[PYAblum defaultAblum] removeSelectedAssetModelArray];
}

- (void)showParentController:(UIViewController *)parentViewController topGapHeight:(CGFloat)topGapHeight {
    
    dispatch_async(dispatch_get_main_queue(), ^{

        ZFCommunityShowPostTransitionDelegate *transitionDelegate = [[ZFCommunityShowPostTransitionDelegate alloc] init];
        self.modalTransitionStyle = UIModalPresentationCustom;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.transitionDelegate = transitionDelegate;
        self.transitioningDelegate = transitionDelegate;
        self.topGapHeight = topGapHeight;
        transitionDelegate.height = KScreenHeight - self.topGapHeight;
        
        if (parentViewController) {
            [parentViewController presentViewController:self animated:YES completion:nil];
        }
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (CGRectGetMinY(self.view.frame) <= 0) {
        CGRect rect = self.view.frame;
        rect.origin.y = self.topGapHeight;
        self.view.frame = rect;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (CGRectGetMinY(self.view.frame) <= 0) {
        CGRect rect = self.view.frame;
        rect.origin.y = self.topGapHeight;
        self.view.frame = rect;
    }
    self.operateOffsetY = CGRectGetMaxY(self.pictureOperateView.frame);
    YWLog(@"------- %f",self.operateOffsetY);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.moveDirection = YES;
    self.startMoveOffsetY = -[ZFCommunityAlbumOperateView operateHeight];
    self.phototWidth = KScreenWidth / 4.0;
    [self zfInitView];
    [self zfAutoLayoutView];

    
    @weakify(self)
    [LBXPermission authorizeWithType:LBXPermissionType_Photos completion:^(BOOL granted, BOOL firstTime) {
        @strongify(self)
        if (granted) {
            self.emptTipView.hidden = YES;
            self.pictureOperateView.hidden = NO;
            self.albumCollectionView.hidden = NO;
            [self loadAlbumDatas];
        } else if (!firstTime) {
            self.emptTipView.hidden = NO;
            [LBXPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"" msg:[NSString stringWithFormat:ZFLocalizedString(@"photoPermisson", nil),[LBXPermission queryAppName]] cancel:ZFLocalizedString(@"Cancel", nil) setting:ZFLocalizedString(@"Setting_VC_Title", nil)];
        }
    }];
    
}

- (void)zfInitView {
        
    self.view.backgroundColor = ZFCClearColor();
    [self.view addSubview:self.showNavigationBar];
    [self.view addSubview:self.mainView];
    [self.mainView addSubview:self.albumCollectionView];
    [self.mainView addSubview:self.pictureOperateView];
    [self.mainView addSubview:self.albumGroupTableView];
    [self.mainView addSubview:self.emptTipView];
    
    [self.showNavigationBar addSubview:self.titleViewControl];
    [self.titleViewControl addSubview:self.titleLabel];
    [self.titleViewControl addSubview:self.arrowImageView];
    [self.emptTipView addSubview:self.photoAuthMessageLabel];
    
    self.mainView.layer.masksToBounds = YES;
    self.albumCollectionView.contentInset = UIEdgeInsetsMake([ZFCommunityAlbumOperateView operateHeight], 0, 0, 0);
}

- (void)zfAutoLayoutView {
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.showNavigationBar.mas_bottom);
    }];
    
    [self.pictureOperateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.mainView);
        make.top.mas_equalTo(self.mainView.mas_top);
        make.height.mas_equalTo([ZFCommunityAlbumOperateView operateHeight]);
    }];
    
    [self.albumCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.mainView);
        make.top.mas_equalTo(self.mainView.mas_top);
        make.bottom.mas_equalTo(self.mainView.mas_bottom);
    }];
    
    [self.albumGroupTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.mainView);
        make.bottom.mas_equalTo(self.mainView.mas_bottom);
    }];
    
    [self.titleViewControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.showNavigationBar.mas_centerX);
        make.centerY.mas_equalTo(self.showNavigationBar.mas_centerY);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleViewControl.mas_leading);
        make.top.mas_equalTo(self.titleViewControl.mas_top).offset(5);
        make.bottom.mas_equalTo(self.titleViewControl.mas_bottom).offset(-5);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.titleViewControl.mas_trailing);
        make.centerY.mas_equalTo(self.titleViewControl.mas_centerY);
        make.leading.mas_equalTo(self.titleLabel.mas_trailing).offset(5);
    }];
    
    [self.emptTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.mainView);
    }];
    
    [self.photoAuthMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.emptTipView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.emptTipView.mas_trailing).offset(-16);
        make.top.mas_equalTo(self.emptTipView.mas_top).offset(20);
    }];
}


- (void)loadAlbumDatas {
    PYAblum *ablumManager = [PYAblum defaultAblum];
    
    self.assetModelArray = [ablumManager.allPhotoAblumModelArray mutableCopy];
    // 临时外部导入的
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, ablumManager.externalImportAssetModelArray.count)];
    [self.assetModelArray insertObjects:ablumManager.externalImportAssetModelArray atIndexes:indexSet];

    if (self.assetModelArray.count > 0) {
        PYAssetModel *firseAssetModel = self.assetModelArray.firstObject;
        [self updateOperatePicture:firseAssetModel];
        
    }
    self.fetchResultsArray = [ablumManager.fetchResultsArray mutableCopy];
    [self.fetchResultsArray enumerateObjectsUsingBlock:^(PYAblumModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ablumManager.imageManager getPotoWithAlbum:obj.assetfetchResult andPotoWidth:self.phototWidth andSortAscendingByDate:true andCompletion:^(UIImage *image) {
            obj.coverImageView = image;
        }];
    }];
    [self.albumGroupTableView reloadData];

    [self updateTitleName:ablumManager.currentAblumModel.name];
    [self updateNavBarDone:ablumManager.selectedAssetModelArray.count];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pictureOperateView showScaleTipView];
    });

}

- (void)updateTitleName:(NSString *)name {
    if (!ZFIsEmptyString(name)) {
        self.titleLabel.text = name;
    } else {
        self.titleLabel.text = @"Recent Project";
    }
}

- (void)takePhotoes {
    @weakify(self)
    [LBXPermission authorizeWithType:LBXPermissionType_Camera completion:^(BOOL granted, BOOL firstTime) {
        @strongify(self)
        if (granted) {
//            [self pushToViewController:@"ZFCameraViewController" propertyDic:nil];
            ZFCameraViewController *cameraVC = [[ZFCameraViewController alloc] init];
            cameraVC.isReturnSourceVC = YES;
            cameraVC.phtotTipString = ZFLocalizedString(@"Community_TapTakePhoto", nil);
            cameraVC.modalPresentationStyle = UIModalPresentationFullScreen;
            @weakify(self)
            cameraVC.photoBlock = ^(UIImage *iamge) {
                @strongify(self)
                [self handlePhotos:iamge];
            };
            [self presentViewController:cameraVC animated:YES completion:nil];
        }
        else if(!firstTime) {
            NSString *msg = [NSString stringWithFormat:ZFLocalizedString(@"cameraPermisson", nil), @"ZZZZZ"];
            [LBXPermissionSetting showAlertToDislayPrivacySettingWithTitle:ZFLocalizedString(@"Can not use camera", nil) msg:msg cancel:ZFLocalizedString(@"Cancel", nil) setting:ZFLocalizedString(@"Setting_VC_Title", nil)];
        }
    }];
}

- (void)handlePhotos:(UIImage *)image {
    PYAssetModel *assetModel = [[PYAssetModel alloc] init];
    assetModel.originImage = image;
    assetModel.delicateImage = image;
    assetModel.degradedImage = image;
    assetModel.localIdentifier = [NSString stringWithFormat:@"album_%@",[NSStringUtils getCurrentTimestamp]];
    [self.assetModelArray insertObject:assetModel atIndex:0];
    [[PYAblum defaultAblum].externalImportAssetModelArray addObject:assetModel];
    [self.albumCollectionView reloadData];
    
    [self updateOperatePicture:assetModel];
}

#pragma mark - action

- (void)actionAlbum:(UIControl *)sender {
    [self showAlbumGroupView:self.albumGroupTableView.isHidden];
    
}

- (void)showAlbumGroupView:(BOOL)isShow {
    
    self.albumGroupTableView.hidden = !isShow;
    if (self.albumGroupTableView.isHidden) {
        self.arrowImageView.image = [UIImage imageNamed:@"album_arrow_down"];
    } else {
        self.arrowImageView.image = [UIImage imageNamed:@"album_arrow_up"];
    }
}

- (BOOL)isSelected:(PYAssetModel *)assetModel {
    
    if (assetModel.isSelected) {
        return assetModel.isSelected;
    }
    
    __block BOOL isFlag = NO;
    [[PYAblum defaultAblum].selectedAssetModelArray enumerateObjectsUsingBlock:^(PYAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.localIdentifier isEqualToString:assetModel.localIdentifier]) {
            isFlag = YES;
            *stop = YES;
            assetModel.orderNumber = obj.orderNumber;
            assetModel.isSelected = YES;
        }
    }];
    
    return isFlag;
    
}

- (void)updateAblumFrame:(CGRect)frame zoomScale:(CGFloat)zoomScale{
    if (self.assetModelArray.count + 1 > self.markIndexPath.row) {
        if (self.assetModelArray.count > self.markIndexPath.row - 1) {
            PYAssetModel *selectAssetModel = self.assetModelArray[self.markIndexPath.row-1];
            if (!CGRectEqualToRect(frame, CGRectZero)) {
                selectAssetModel.screenshotRect = frame;
                selectAssetModel.zoomScale = zoomScale;
            }
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.assetModelArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZFCommunityAlbumCCell *cell = [ZFCommunityAlbumCCell albumPhotoCellWithCollectionView:collectionView forIndexPath:indexPath];
    cell.backgroundColor = ZFCOLOR_RANDOM;
    cell.imageWidth = self.phototWidth;
    if (indexPath.row == 0) {
        [cell setCameraImage:[UIImage imageNamed:@"album_photo_white"]];
    } else if (self.assetModelArray.count + 1 > indexPath.row) {
        PYAssetModel *assetModel = self.assetModelArray[indexPath.row-1];
        [self isSelected:assetModel];
        cell.assetModel = assetModel;
        
        if (!self.markIndexPath) {
            self.markIndexPath = indexPath;
        }
        if (self.markIndexPath.row == indexPath.row) {
            [cell showSelectMaskView:YES];
        } else {
            [cell showSelectMaskView:NO];
        }
    }
    
    @weakify(self);
    cell.selectBlock = ^(PYAssetModel *assetModel) {
        @strongify(self);
        [self selectAssetModel:assetModel RowAtIndexPath:indexPath];
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        YWLog(@"--- 拍照");
        [self takePhotoes];

    } else if (self.assetModelArray.count + 1 > indexPath.row) {
        
        if (self.assetModelArray.count > (self.markIndexPath.row - 1) && indexPath.row != self.markIndexPath.row && self.markIndexPath) {
            PYAssetModel *lastAssetModel = self.assetModelArray[self.markIndexPath.row-1];
            ZFCommunityAlbumCCell *cell = (ZFCommunityAlbumCCell*)[collectionView cellForItemAtIndexPath:self.markIndexPath];
            cell.assetModel = lastAssetModel;
            [cell showSelectMaskView:NO];
            self.markIndexPath = nil;
        }
        
        PYAssetModel *assetModel = self.assetModelArray[indexPath.row-1];
        ZFCommunityAlbumCCell *cell = (ZFCommunityAlbumCCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.assetModel = assetModel;
        [cell showSelectMaskView:YES];
        self.markIndexPath = indexPath;

        [self updateOperatePicture:assetModel];
        
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.phototWidth;
    return CGSizeMake(width,width);
}

// 两行之间的上下间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

// 两个cell之间的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

-(void)selectAssetModel:(PYAssetModel *)assetModel RowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.assetModelArray.count + 1 > indexPath.row && assetModel) {
        
        if (self.assetModelArray.count > (self.markIndexPath.row - 1) && self.markIndexPath) {
            PYAssetModel *lastAssetModel = self.assetModelArray[self.markIndexPath.row-1];
            ZFCommunityAlbumCCell *cell = (ZFCommunityAlbumCCell*)[self.albumCollectionView cellForItemAtIndexPath:self.markIndexPath];
            cell.assetModel = lastAssetModel;
            [cell showSelectMaskView:NO];
            self.markIndexPath = nil;
        }
        
        PYAssetModel *assetModel = self.assetModelArray[indexPath.row-1];
        ZFCommunityAlbumCCell *cell = (ZFCommunityAlbumCCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
        cell.assetModel = assetModel;
        [cell showSelectMaskView:YES];
        self.markIndexPath = indexPath;
        
        [self updateOperatePicture:assetModel];
        @weakify(self);
        [PYAblum getSelectAssetArrayWithClickedModel:assetModel andMaxCount: 9 andOverTopBlock:^(NSArray<PYAssetModel *> *modelArray, BOOL isVoerTop) {
            @strongify(self);
            if (isVoerTop) {
                YWLog(@"-----超出了");
                ShowToastToViewWithText(self.view, ZFLocalizedString(@"Community_PhotoMax9", nil));
            } else {
                [self updateNavBarDone:modelArray.count];
                [self.albumCollectionView reloadData];
            }
        }];
        
    }
}


#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchResultsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityAlbumGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFCommunityAlbumGroupCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.fetchResultsArray.count > indexPath.row) {
        cell.ablumModel = self.fetchResultsArray[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.fetchResultsArray.count > indexPath.row) {
        
        PYAblum *ablumManager = [PYAblum defaultAblum];

        PYAblumModel *ablumModel = self.fetchResultsArray[indexPath.row];
        if (ablumManager.currentAblumModel == ablumModel) {
            [self showAlbumGroupView:NO];
            return;
        }
        
        self.albumCollectionView.contentOffset = CGPointMake(0, 0);
        if (ablumModel.assetfetchResult.count > 0) {
            [ablumManager getSelectAssetArrayWithAblumModel:ablumModel];
            
            self.assetModelArray = [ablumManager.allPhotoAblumModelArray mutableCopy];
            // 临时外部导入的
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, ablumManager.externalImportAssetModelArray.count)];
            [self.assetModelArray insertObjects:ablumManager.externalImportAssetModelArray atIndexes:indexSet];
            if (self.assetModelArray.count > 0) {
                PYAssetModel *firseAssetModel = self.assetModelArray.firstObject;
                self.markIndexPath = nil;
                [self updateOperatePicture:firseAssetModel];
            }
            [self.albumCollectionView reloadData];
            [self showAlbumGroupView:NO];
            [self updateTitleName:ablumManager.currentAblumModel.name];
        } 
    }
}


- (void)updateOperatePicture:(PYAssetModel *)assetModel {
    
    if (assetModel.originImage) {
        [self.pictureOperateView showLoading:NO];
        [self.pictureOperateView updateImage:assetModel.originImage frame:assetModel.screenshotRect zoomScale:assetModel.zoomScale];
    } else {
        
        [self.pictureOperateView showLoading:YES];
        [self.pictureOperateView updateImage:assetModel.delicateImage ? assetModel.delicateImage : assetModel.degradedImage frame:assetModel.screenshotRect zoomScale:assetModel.zoomScale];
        @weakify(self);
        [assetModel getOriginImage:^(UIImage *image) {
            @strongify(self);
            [self.pictureOperateView showLoading:NO];
            [self.pictureOperateView updateImage:image frame:assetModel.screenshotRect zoomScale:assetModel.zoomScale];
        } progress:^(double progress) {
            YWLog(@"----- 加载进度--- %f",progress);
        }];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    YWLog(@"------ %f",scrollView.contentOffset.y);
    
    if ([scrollView isEqual:self.albumGroupTableView]) {
        return;
    }
    
    if (scrollView.contentOffset.y > self.lastContentOffsetY) {
        YWLog(@"正在向上滑动");
        if (!self.moveDirection) {
        }
        self.moveDirection = YES;
        self.isOperateStartMoveDown = NO;

    } else {
        self.moveDirection = NO;
        YWLog(@"正在向下滑动");
    }
    
    self.albumCollectionView.moveDistance = scrollView.contentOffset.y - self.albumCollectionView.startOffsetY;


    // 开始触发向上滚动
    CGFloat tempDistance = self.albumCollectionView.startToWindowPoint.y - self.albumCollectionView.moveDistance;
    YWLog(@" ----- 移动距离 %f",tempDistance);
    if (tempDistance <= self.operateOffsetY && self.operateOffsetY > 0  && scrollView.contentOffset.y > -[ZFCommunityAlbumOperateView operateHeight]) {
        
        if (CGRectGetMinY(self.pictureOperateView.frame) + CGRectGetHeight(self.pictureOperateView.frame) <= 80) {
            [self.pictureOperateView showBottomTapView:YES];
        }
        //记录开始移动值
        if (self.startMoveOffsetY <= -[ZFCommunityAlbumOperateView operateHeight]) {
            self.startMoveOffsetY = scrollView.contentOffset.y;
            YWLog(@"---- 真实开始拖拽 %f",self.startMoveOffsetY);
        }
        
        if (!self.albumCollectionView.isDraging) {
            YWLog(@"---- 未开始拖拽");
            return;
        }
        
        CGFloat distanceY = scrollView.contentOffset.y - self.startMoveOffsetY;
        BOOL isEnd = CGRectGetMinY(self.pictureOperateView.frame) + CGRectGetHeight(self.pictureOperateView.frame) <= 80;
        
        YWLog(@"----- 真实开始移动距离: %f",distanceY);
        if (distanceY > 0) {
            if (distanceY <= (self.operateOffsetY - 80) && !isEnd) {
                YWLog(@"------ move--- %f --- %f",distanceY,CGRectGetMinY(self.pictureOperateView.frame));
                [self.pictureOperateView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.mainView.mas_top).offset(-distanceY);
                }];
            }
        }
        
    } else if(!self.moveDirection) {

        if (scrollView.contentOffset.y <= [ZFCommunityAlbumOperateView operateHeight]) {
            
            CGFloat operMinY = CGRectGetMinY(self.pictureOperateView.frame);

            // 记录开始下移Y坐标
            if (!self.isOperateStartMoveDown) {
                self.isOperateStartMoveDown = YES;
                self.startOperateDownMoveOffsetY = scrollView.contentOffset.y;
                YWLog(@"---- 下移开始 miny: %f",operMinY);
            }
            
            if (scrollView.contentOffset.y <= -[ZFCommunityAlbumOperateView operateHeight]) {
                [self.pictureOperateView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.mainView.mas_top);
                }];
                [self.pictureOperateView showBottomTapView:NO];

                YWLog(@"---- 下移停止移动offsetY: %f miny: %f",scrollView.contentOffset.y,operMinY);
            } else {
                CGFloat moveY = self.startOperateDownMoveOffsetY - scrollView.contentOffset.y;
                moveY = operMinY + moveY;
                if (operMinY >= 0) {
                    [self.pictureOperateView showBottomTapView:NO];
                    return;
                }
                YWLog(@"---- 下移移动距离 : %f  miny: %f",moveY,operMinY);
                if (moveY >= 0) {
                    moveY = 0;
                }
                [self.pictureOperateView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.mainView.mas_top).offset(moveY);
                }];
            }
        }
    }

    self.lastContentOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    YWLog(@"------scrollViewDidEndDecelerating");
    if ([scrollView isEqual:self.albumCollectionView]) {
        [self checkEndScorllState];
        BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (scrollToScrollStop) {
            
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([scrollView isEqual:self.albumCollectionView]) {
        self.albumCollectionView.isDraging = NO;
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    YWLog(@"------scrollViewDidEndDragging");

    if ([scrollView isEqual:self.albumCollectionView]) {
        [self checkEndScorllState];
        
        self.albumCollectionView.isDraging = NO;
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.albumCollectionView]) {
        self.albumCollectionView.isDraging = YES;
        self.lastContentOffsetY = scrollView.contentOffset.y;
    }
}


- (void)checkEndScorllState {
    
    CGFloat operateY = CGRectGetMinY(self.pictureOperateView.frame);
    CGFloat operateH = CGRectGetHeight(self.pictureOperateView.frame);

    if (operateY + operateH / 2.0 <= 0) {

        [self showAllPicture:NO];
        
    } else {
        BOOL isTop = CGRectGetMinY(self.pictureOperateView.frame) + CGRectGetHeight(self.pictureOperateView.frame) <= 80;
        if (isTop) {
            YWLog(@"----- is Top -----");
        } else {
            [self showAllPicture:YES];

            [UIView animateWithDuration:0.25 animations:^{
                [self.mainView layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        }
    }
}

- (void)showAllPicture:(BOOL)isShow {
    
    CGFloat operateY = CGRectGetMinY(self.pictureOperateView.frame);
    CGFloat operateH = CGRectGetHeight(self.pictureOperateView.frame);
    
    [UIView animateWithDuration:0.25 animations:^{
        if (isShow) {
            
            [self.pictureOperateView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.mainView.mas_top);
            }];
            [self.pictureOperateView showBottomTapView:NO];
            
        } else {
            [self.pictureOperateView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.mainView.mas_top).offset(-(operateH-80));
            }];
            [self.pictureOperateView showBottomTapView:YES];
        }
        [self.mainView layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
    self.startMoveOffsetY = -[ZFCommunityAlbumOperateView operateHeight];
}

- (void)updateNavBarDone:(BOOL)isEnable {
    if (isEnable) {
        [self.showNavigationBar.confirmButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        self.showNavigationBar.confirmButton.enabled = YES;
    } else {
        [self.showNavigationBar.confirmButton setTitleColor:ZFC0xCCCCCC() forState:UIControlStateNormal];
        self.showNavigationBar.confirmButton.enabled = NO;
    }
}

#pragma mark - Public Method

- (NSMutableArray<PYAssetModel *> *)selectAssetModelArray {
    if (!_selectAssetModelArray) {
        _selectAssetModelArray = [[NSMutableArray alloc] init];
    }
    return _selectAssetModelArray;
}

- (ZFCommunityNavBarView *)showNavigationBar {
    if (!_showNavigationBar) {
        _showNavigationBar = [[ZFCommunityNavBarView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
        _showNavigationBar.backgroundColor = ZFC0xFFFFFF();
        [_showNavigationBar zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(22, 22)];
        _showNavigationBar.confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_showNavigationBar.confirmButton setTitleColor:ZFC0xCCCCCC() forState:UIControlStateNormal];
        @weakify(self)
        _showNavigationBar.closeBlock = ^(BOOL flag) {
            @strongify(self)
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        _showNavigationBar.confirmBlock = ^(BOOL flag) {
            @strongify(self)
            if (self.confirmAlbumsBlock) {
                
                // 遍历截图
                [[PYAblum defaultAblum].selectedAssetModelArray enumerateObjectsUsingBlock:^(PYAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (!CGRectEqualToRect(obj.screenshotRect, CGRectZero)) {
                        
                        UIImage *currentImage = obj.originImage;
                        if (!currentImage) {
                            currentImage = obj.delicateImage ? obj.delicateImage : obj.degradedImage;
                        }
                        if (currentImage) {
                            
                            UIImageView *imageView = [[UIImageView alloc] initWithImage:currentImage];
                            imageView.frame = obj.screenshotRect;
                            imageView.contentMode = UIViewContentModeScaleAspectFill;
                            
                            UIView *screenshotView = [[UIView alloc] initWithFrame:[ZFCommunityAlbumOperateView screenshotRect]];
                            screenshotView.backgroundColor = ZFC0xFFFFFF();
                            [screenshotView addSubview:imageView];
                            
                            UIGraphicsImageRendererFormat *format = [[UIGraphicsImageRendererFormat alloc] init];
                            format.prefersExtendedRange = YES;
                            UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:screenshotView.frame.size format:format];
                            __weak typeof(UIView) *weakShot = screenshotView;
                            UIImage *tmpImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
                                return [weakShot.layer renderInContext:rendererContext.CGContext];
                            }];
//                            obj.screenshotImage = tmpImage;
                            
                            
                            CGRect tempRect = obj.screenshotRect;
                            if (obj.screenshotRect.origin.x <= 0) {
                                tempRect.origin.x = 0;
                            }
                            if (obj.screenshotRect.origin.y <= 0) {
                                tempRect.origin.y = 0;
                            }
                            
                            if (CGRectGetMaxX(obj.screenshotRect) >= [ZFCommunityAlbumOperateView operateHeight]) {
                                tempRect.size.width = [ZFCommunityAlbumOperateView operateHeight];
                            }
                            
                            if (CGRectGetMaxY(obj.screenshotRect) >= [ZFCommunityAlbumOperateView operateHeight]) {
                                tempRect.size.height = [ZFCommunityAlbumOperateView operateHeight];
                            }
                            
                            CGFloat x = tempRect.origin.x * KScale;
                            CGFloat y = tempRect.origin.y * KScale;
                            CGFloat width = tempRect.size.width * KScale;
                            CGFloat height = tempRect.size.height * KScale;
                            UIImage * smallImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([tmpImage CGImage], CGRectMake(x, y, width, height))];
                            obj.screenshotImage = smallImage;

                        }
                    }
                }];
                
                self.confirmAlbumsBlock([PYAblum defaultAblum].selectedAssetModelArray);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        };

    }
    return _showNavigationBar;
}


- (UIControl *)titleViewControl {
    if (!_titleViewControl) {
        _titleViewControl = [[UIControl alloc] initWithFrame:CGRectZero];
        [_titleViewControl addTarget:self action:@selector(actionAlbum:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _titleViewControl;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.text = @"Recent Project";
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.image = [UIImage imageNamed:@"album_arrow_down"];
    }
    return _arrowImageView;
}

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectZero];
        _mainView.backgroundColor = ZFC0xFFFFFF();
    }
    return _mainView;
}

- (ZFCommunityAlbumOperateView *)pictureOperateView {
    if (!_pictureOperateView) {
        _pictureOperateView = [[ZFCommunityAlbumOperateView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, [ZFCommunityAlbumOperateView operateHeight])];
        _pictureOperateView.hidden = YES;
        @weakify(self)
        _pictureOperateView.changeFrameBlock = ^(CGRect changeFrame, CGFloat zoomScale) {
          @strongify(self)
            [self updateAblumFrame:changeFrame zoomScale:zoomScale];
        };
        
        _pictureOperateView.tapBottomBlock = ^(BOOL flag) {
            @strongify(self)
            [self showAllPicture:YES];
        };
    }
    return _pictureOperateView;
}

- (ZFCommunityAlbumCollectionView *)albumCollectionView {
    if (!_albumCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//        layout.minimumInteritemSpacing = 10;
//        layout.minimumLineSpacing = 10;
//        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);

        _albumCollectionView = [[ZFCommunityAlbumCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _albumCollectionView.scrollEnabled = YES;
        _albumCollectionView.backgroundColor = [UIColor whiteColor];
        _albumCollectionView.alwaysBounceVertical = YES;
        _albumCollectionView.showsVerticalScrollIndicator = YES;
        _albumCollectionView.delegate = self;
        _albumCollectionView.dataSource = self;
        _albumCollectionView.tag = 100;
        _albumCollectionView.hidden = YES;
        
        @weakify(self)
        _albumCollectionView.touchesBeganPointBlock = ^(CGPoint toWindowPoint) {
            @strongify(self)
        };
        
        [_albumCollectionView registerClass:[ZFCommunityAlbumCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityAlbumCCell class])];
        if (@available(iOS 11.0, *)) {
            _albumCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }    }
    return _albumCollectionView;
}

- (UITableView *)albumGroupTableView {
    if (!_albumGroupTableView) {
        _albumGroupTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _albumGroupTableView.hidden = YES;
        _albumGroupTableView.delegate = self;
        _albumGroupTableView.dataSource = self;
        _albumGroupTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _albumGroupTableView.backgroundColor = ZFC0xFFFFFF();
        
        [_albumGroupTableView registerClass:[ZFCommunityAlbumGroupCell class] forCellReuseIdentifier:NSStringFromClass(ZFCommunityAlbumGroupCell.class)];
    }
    return _albumGroupTableView;
}

- (UIView *)emptTipView {
    if (!_emptTipView) {
        _emptTipView = [[UIView alloc] initWithFrame:CGRectZero];
        _emptTipView.hidden = YES;
        _emptTipView.backgroundColor = ZFC0xFFFFFF();
    }
    return _emptTipView;
}

- (UILabel *)photoAuthMessageLabel {
    if (!_photoAuthMessageLabel) {
        _photoAuthMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _photoAuthMessageLabel.textAlignment = NSTextAlignmentCenter;
        _photoAuthMessageLabel.numberOfLines = 0;
        _photoAuthMessageLabel.textColor = ZFC0x2D2D2D();
        _photoAuthMessageLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"photoPermisson", nil),[LBXPermission queryAppName]];
    }
    return _photoAuthMessageLabel;
}
@end
