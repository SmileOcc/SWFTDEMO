//
//  ZFCommunityShowPostViewController.m
//  ZZZZZ
//
//  Created by YW on 16/11/26.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityShowPostViewController.h"
#import "TZImagePickerController.h"
#import "ZFCommunityShowGoodsPageVC.h" // 关联商品控制器
#import "ZFCommunityShowAlbumVC.h"
#import "ZFCommunityPostHotTopicListVC.h"
#import "ZFCommunityPostPreviewVC.h"

#import "ZFCommunityShowPostPhotoCell.h" // 选择照片Cell
#import "ZFCommunityShowPostGoodsImageCell.h" // 关联商品 Cell
#import "YSTextView.h"
#import "ZFTitleArrowTipView.h"
#import "ZFCommunityDynamicNavBar.h"

#import "IQKeyboardManager.h"
#import "ZFInitViewProtocol.h"
#import "PostApi.h"
#import "ZFCommunityPostViewModel.h"
#import "ZFCommunityGoodsInfosModel.h"
#import "PostPhotosManager.h"
#import "PostGoodsManager.h"
#import "ZFCommunityPostResultModel.h"
#import "ZFCommunityViewModel.h"
#import "ZFThemeManager.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "NSArrayUtils.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "Masonry.h"
#import "Constants.h"
#import "LBXPermission.h"

#import "ZFCommunityAlbumPhotoView.h"

#import "ZFOutfitSearchHotWordView.h"
#import "ZFOutfitSearchHotWordManager.h"

// 最大输入字符数
static const NSInteger  KMaxInputCount = 3000;
static const NSInteger  KImageMargin  = 10;

NSString *const kZFCommunityShowPostViewTip  = @"kZFCommunityShowPostViewTip";
NSString *const kZFCommunityShowPostPhotoViewTip  = @"kZFCommunityShowPostPhotoViewTip";
NSString *const kZFCommunityShowPostLongPressDeleteViewTip  = @"kZFCommunityShowPostLongPressDeleteViewTip";

@interface ZFCommunityShowPostViewController ()
<
ZFInitViewProtocol,
UICollectionViewDelegateFlowLayout,
UICollectionViewDataSource,
TZImagePickerControllerDelegate,
UIActionSheetDelegate,
UIAlertViewDelegate,
UITextViewDelegate,
UIScrollViewDelegate,
ZFOutfitSearchHotWordViewDelegate,
ZFOutfitSearchHotWordManagerDelegate
>

@property (nonatomic, strong) ZFCommunityDynamicNavBar    *navBarView;

@property (nonatomic,strong) UIView                       *containView;
@property (nonatomic,strong) UICollectionView             *imageCollectionView;
@property (nonatomic, strong) UIButton                    *hotTopicButton;
@property (nonatomic, strong) UIView                      *lineView;
@property (nonatomic, strong) UIView                      *showZZZZZBottomLine;

@property (nonatomic, strong) ZFCommunityAlbumPhotoView   *albumPhotoView;


@property (nonatomic,strong) YSTextView                   *textView; // YYTextView

@property (nonatomic, strong) UIView                      *publicView;

@property (nonatomic, strong) UILabel                     *publicTipLabel;
@property (nonatomic, strong) UISwitch                    *publicSwitch;


@property (nonatomic,strong) UIView                       *goodsView;
@property (nonatomic,strong) UICollectionView             *goodsCollectionView;
@property (nonatomic,strong) NSMutableArray               *tipArray;

@property (nonatomic,strong) ZFCommunityPostViewModel     *viewModel;
@property (nonatomic,strong) NSMutableArray               *selectGoods;

@property (nonatomic, strong) ZFTitleArrowTipView         *addGoodsTipView;
@property (nonatomic, strong) ZFTitleArrowTipView         *addPhotoTipView;
@property (nonatomic, strong) ZFTitleArrowTipView         *longPhotoPressTipView;


@property (nonatomic, assign) CGFloat                     itemsWidth;


/// 对ZZZZZ公开
@property (nonatomic, assign) BOOL                        isShowToZF;

@property (nonatomic, assign) BOOL                        isHadSelectHotLabel;


/// 是否移动
@property (nonatomic, assign) BOOL                        isBeganMove;

///键盘高度
@property (nonatomic, assign) CGFloat                      keyboardHeight;
/// 匹配词管理
@property (nonatomic, strong) ZFOutfitSearchHotWordManager        *searchHotWordManager;
@property (nonatomic, strong) ZFOutfitSearchHotWordView           *searchHotWordView;

@property (nonatomic, strong) ZFCommunityViewModel                *communityViewModel;

@property (nonatomic, strong) UIView                      *blackMaskView;
@property (nonatomic, strong) UIImageView                 *tempMaskImageView;
@property (nonatomic, assign) CGPoint                     startMaskPoint;
@property (nonatomic, assign) CGPoint                     startMovePoint;
@property (nonatomic, assign) CGRect                      changeMaskRect;
@property (nonatomic, strong) NSIndexPath                 *changeIndexPath;
@property (nonatomic, strong) NSIndexPath                 *startIndexPath;



@property (nonatomic, strong) ZFCommunityShowPostPhotoCell *startCell;



@end

@implementation ZFCommunityShowPostViewController

- (void)dealloc {
    [[PYAblum defaultAblum] removeExternalImportAssetModelArray];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectAssetModelArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self.navBarView zfChangeSkinToShadowNavgationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_albumPhotoView) {
        [_albumPhotoView showView:NO rect:CGRectZero];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
     self.automaticallyAdjustsScrollViewInsets = NO;
    self.tipArray = [NSMutableArray array];
    
    self.itemsWidth = (KScreenWidth - 12 * 2 - 6 * 4) / 4.3;
    
    [self zfInitView];
    [self zfAutoLayoutView];

    // 持有外部导入的
    if (self.selectAssetModelArray.count > 0) {
        [[PYAblum defaultAblum].externalImportAssetModelArray addObjectsFromArray:self.selectAssetModelArray];
    }

    [self showAddPhotoTipView];
    
    [self loadHotLabelDatas];

    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    self.keyboardHeight = height;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
   return UIStatusBarStyleDefault;
}

- (void)zfInitView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [PYAblum defaultAblum];

    [self.view addSubview:self.navBarView];
    [self.view addSubview:self.containView];
    
    [self.containView addSubview:self.imageCollectionView];
    [self.containView addSubview:self.lineView];
    [self.containView addSubview:self.textView];
    [self.containView addSubview:self.publicView];
    [self.containView addSubview:self.showZZZZZBottomLine];
    [self.containView addSubview:self.goodsView];
    
    [self.publicView addSubview:self.hotTopicButton];
    [self.publicView addSubview:self.publicTipLabel];
    [self.publicView addSubview:self.publicSwitch];
    [self.goodsView addSubview:self.goodsCollectionView];
    
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [previewButton setTitle:ZFLocalizedString(@"Community_Preview", nil) forState:UIControlStateNormal];
    [previewButton addTarget:self action:@selector(previewAction:) forControlEvents:UIControlEventTouchUpInside];
    previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
    previewButton.contentEdgeInsets = UIEdgeInsetsMake(1, 10, 1, 10);
    previewButton.layer.cornerRadius = 12.0;
    previewButton.layer.masksToBounds = YES;
    previewButton.layer.borderWidth = 1.0;
    
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton setTitle:ZFLocalizedString(@"Post_VC_Post",nil) forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postAction:) forControlEvents:UIControlEventTouchUpInside];
    postButton.titleLabel.font = [UIFont systemFontOfSize:16];
    postButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    postButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);

    [itemsArray addObject:previewButton];
    [itemsArray addObject:postButton];
    
    [self.navBarView setRightItemButton:itemsArray];
    
    [self updatePreviewEnable:NO];
    [self updatePostButtonEnable:YES];
}

- (void)zfAutoLayoutView {
        
    [self.navBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top);
        make.height.mas_equalTo(kiphoneXTopOffsetY + 44);
    }];
        
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navBarView.mas_bottom);
        make.leading.trailing.bottom.mas_equalTo(self.view);
    }];
    
    /******************************* 选择照片 ******************************************/
    [self.imageCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.containView);
        make.top.mas_equalTo(self.containView.mas_top).offset(12);
        make.height.mas_equalTo(self.itemsWidth);
    }];
    
    /******************************** 标签 ********************************************/
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.containView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.containView.mas_trailing).offset(-12);
        make.top.equalTo(self.imageCollectionView.mas_bottom).offset(12);
        make.height.mas_equalTo(0.5);
    }];
    
    /******************************* 输入框 *******************************************/
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineView.mas_bottom);
        make.leading.trailing.equalTo(self.containView);
        make.height.mas_equalTo(120);
    }];
    
    
    /******************************** 是否公开 ********************************************/

    
    [self.publicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.containView);
        make.height.mas_equalTo(33);
    }];
    
    [self.publicSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.publicView.mas_trailing).offset(-5);
        make.centerY.mas_equalTo(self.publicView.mas_centerY);
    }];
    
    
    CGFloat tipMaxW = ((KScreenWidth - 12 * 2) - 20) * 180.0 / (180.0 + 150.0);
    CGFloat hotMaxW = ((KScreenWidth - 12 * 2) - 20) * 150.0 / (180.0 + 150.0);

    [self.publicTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.publicSwitch.mas_leading).offset(-3);
        make.centerY.mas_equalTo(self.publicView.mas_centerY);
        make.width.mas_lessThanOrEqualTo(tipMaxW - 60);
    }];
       
    
    [self.hotTopicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.publicView.mas_leading).offset(12);
        make.centerY.mas_equalTo(self.publicView.mas_centerY);
        make.height.mas_equalTo(28);
        make.width.mas_lessThanOrEqualTo(hotMaxW);
    }];

    [self.showZZZZZBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.containView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.containView.mas_trailing).offset(-12);
        make.top.equalTo(self.publicView.mas_bottom).offset(12);
        make.height.mas_equalTo(0.5);
    }];
    
    /********************************* 关联商品 ********************************************/
    
    [self.goodsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showZZZZZBottomLine.mas_bottom);
        make.leading.trailing.equalTo(self.containView);
        make.bottom.equalTo(self.containView.mas_bottom).offset(-(12 + kiphoneXHomeBarHeight));
    }];
    
    [self.goodsCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.goodsView.mas_top).offset(12);
        make.leading.trailing.bottom.equalTo(self.goodsView);
        make.height.mas_equalTo(self.itemsWidth);
    }];
}

- (void)loadHotLabelDatas {
    
    [self.communityViewModel requestReviewTopicList:nil completion:^(NSArray<ZFCommunityHotTopicModel *> *results) {
        
    }];
}

#pragma mark - action

- (void)actionHot:(UIButton *)sender {
    ZFCommunityPostHotTopicListVC *topicListVC = [[ZFCommunityPostHotTopicListVC alloc] init];
    topicListVC.hotTopicModel = self.selectHotTopicModel;
    
    @weakify(self)
    topicListVC.selectTopic = ^(ZFCommunityHotTopicModel *model) {
        @strongify(self)
        self.isHadSelectHotLabel = YES;
        self.selectHotTopicModel = model;
    };
    topicListVC.cancelTopic = ^(BOOL flag) {
        @strongify(self)
        self.isHadSelectHotLabel = NO;
        self.selectHotTopicModel = nil;
    };
    [topicListVC showParentController:self topGapHeight:kiphoneXTopOffsetY];
}

-(void)showZFSwitchAction:(UISwitch *)sender{
    if (sender.isOn) {
        @weakify(self)
        [YSAlertView alertWithTitle:nil message:ZFLocalizedString(@"Community_postSafeTips", nil) cancelButtonTitle:nil cancelButtonBlock:nil otherButtonBlock:^(NSInteger buttonIndex, id buttonTitle) {
            @strongify(self)
            if (buttonIndex == 1) {
                self.isShowToZF = YES;
            } else {
                self.isShowToZF = NO;
                sender.on = NO;
            }
        } otherButtonTitles:ZFLocalizedString(@"community_outfit_leave_cancel", nil), ZFLocalizedString(@"community_outfit_leave_confirm", nil), nil];
    } else {
        self.isShowToZF = NO;
    }
}

- (void)cancleAction{
    
    BOOL isShowAlert = NO;
    if (!ZFIsEmptyString(self.textView.text)
        || self.selectAssetModelArray.count > 0
        || self.selectGoods.count > 0
        || self.isShowToZF
        || (!ZFIsEmptyString(self.selectHotTopicModel.label) && self.isHadSelectHotLabel)) {
        isShowAlert = YES;
    }
    
    if (isShowAlert) {
        
        //    NSString *title = ZFLocalizedString(@"Post_VC_Post_Cancel_Message",nil);
        NSString *title = ZFLocalizedString(@"Community_PostEditTips",nil);
        NSArray *otherBtnArr = @[ZFLocalizedString(@"Post_VC_Post_Cancel_Yes",nil)];
        NSString *cancelTitle = ZFLocalizedString(@"Post_VC_Post_Cancel_No",nil);
        
        ShowAlertView(title, nil, otherBtnArr, ^(NSInteger buttonIndex, id buttonTitle) {
            [self dismissViewControllerAnimated:YES completion:^{
                [[PostPhotosManager sharedManager] clearData];
                [[PostGoodsManager sharedManager] clearData];
            }];
        }, cancelTitle, nil);
        
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [[PostPhotosManager sharedManager] clearData];
            [[PostGoodsManager sharedManager] clearData];
        }];
    }
}

- (void)previewAction:(UIButton *)sender {
    
    NSString *contentStr = ZFToString(self.textView.text);
    NSArray *hotWords = [ZFOutfitSearchHotWordManager queryHotWordInString:contentStr];
    
    NSMutableArray *hotStrsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < hotWords.count; i++) {
        NSTextCheckingResult *checkingResult = hotWords[i];
        NSString *rangString = [contentStr substringWithRange:checkingResult.range];
        [hotStrsArray addObject:rangString];
    }
    if (hotStrsArray.count > 0) {
        for (NSString *hotStr in hotStrsArray) {
            contentStr = [contentStr stringByReplacingOccurrencesOfString:hotStr withString:@""];
        }
    }
    ZFCommunityPostDetailModel *postModel = [[ZFCommunityPostDetailModel alloc] init];
    
    NSMutableArray *photosArrays = [[NSMutableArray alloc] init];
    for (PYAssetModel *assetModel in self.selectAssetModelArray) {
        if (assetModel.screenshotImage) {
            [photosArrays addObject:assetModel.screenshotImage];
        } else if (assetModel.originImage) {
            [photosArrays addObject:assetModel.originImage];
        } else if(assetModel.delicateImage) {
            [photosArrays addObject:assetModel.delicateImage];
        } else if(assetModel.degradedImage) {
            [photosArrays addObject:assetModel.degradedImage];
        }
    }
    postModel.previewImages = [[NSArray alloc] initWithArray:photosArrays];
    postModel.title = @"";
    postModel.content = contentStr;
    
    NSMutableArray *labelsArray = [[NSMutableArray alloc] initWithArray:hotStrsArray];
    if (!ZFIsEmptyString(self.selectHotTopicModel.label)) {
        [labelsArray addObject:self.selectHotTopicModel.label];
    }
    
    postModel.labelInfo = labelsArray;
    
    postModel.avatar = [AccountManager sharedManager].account.avatar;
    postModel.nickname = [AccountManager sharedManager].account.nickname;
    
    __block NSMutableArray *tempGoodsIDsArray = [[NSMutableArray alloc] init];
    [self.selectGoods enumerateObjectsUsingBlock:^(ZFCommunityPostShowSelectGoodsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZFCommunityGoodsInfosModel *goodsModel = [[ZFCommunityGoodsInfosModel alloc] init];
        goodsModel.goodsImg = obj.imageURL;
        goodsModel.shopPrice = obj.shop_price;
        [tempGoodsIDsArray addObject:goodsModel];
    }];
        
    postModel.goodsInfos = tempGoodsIDsArray;
    ZFCommunityPostPreviewVC *preivewVC = [[ZFCommunityPostPreviewVC alloc] init];
    preivewVC.detailModel = postModel;
    preivewVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:preivewVC animated:YES completion:nil];
}

/**
 * 请求发帖
 */
- (void)postAction:(UIButton *)sender {
    if (self.selectAssetModelArray.count <= 0) {
//        [self showAlertMessage:ZFLocalizedString(@"Post_VC_Post_NoPhotos_Tip",nil)];
        [self showAlertMessage:ZFLocalizedString(@"Community_NophotoTips",nil)];
        return;
    }

    [self.tipArray removeAllObjects];
    if (!ZFIsEmptyString(self.selectHotTopicModel.label)) {
        [self.tipArray insertObject:self.selectHotTopicModel.label atIndex:0];
    }
    [self.view endEditing:YES];
    
    NSString *postStr = ZFToString(self.textView.text);
    // 去除首尾空格和换行：
    NSString *postContent = [postStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    __block NSMutableArray *tempGoodsIDsArray = [[NSMutableArray alloc] init];
    [self.selectGoods enumerateObjectsUsingBlock:^(ZFCommunityPostShowSelectGoodsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempGoodsIDsArray addObject:ZFToString(obj.goodsID)];
    }];
    
    NSDictionary *dict = @{@"content" : postContent,
                           @"goodsId" : [NSArrayUtils isEmptyArray:tempGoodsIDsArray] ? @"" : [tempGoodsIDsArray componentsJoinedByString:@","],
                           @"images"  : [self uploadImages],
                           @"topic"   : [NSArrayUtils isEmptyArray:self.tipArray] ? @[] :  self.tipArray,
                           @"nickEncrypt" : self.isShowToZF ? @"1" : @"0"
    };
    ShowLoadingToView(self.view);
    
    @weakify(self)
    [self.viewModel requestPostNetwork:dict completion:^(id obj) {
        @strongify(self)
        
        ZFCommunityPostResultModel *model = obj;
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshPopularNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshTopicNotification object:nil];
            NSDictionary *noteDict = @{@"review_type" : @(0),
                                       @"model"       : @[model],
                                       @"comeFromeType" : @(self.comeFromeType)
                                       };
            [[NSNotificationCenter defaultCenter] postNotificationName:kCommunityPostSuccessNotification object:noteDict];
            
            [[PostPhotosManager sharedManager] clearData];
            [[PostGoodsManager sharedManager] clearData];
            [self.selectAssetModelArray removeAllObjects];
            HideLoadingFromView(self.view);
            
            // 社区发帖成功统计
            NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
            valuesDic[AFEventParamContentId] = [NSString stringWithFormat:@"%@", model.reviewId];
            valuesDic[@"af_userid"] = ZFgrowingToString([AccountManager sharedManager].account.user_id);
            [ZFAnalytics appsFlyerTrackEvent:@"af_post" withValues:valuesDic];
            [ZFGrowingIOAnalytics ZFGrowingIOPostTopic:model.reviewId postType:@"shows"];
        }];
        
    } failure:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"ChangePassword_VC_Request_Failure_Message",nil));
    }];
}

#pragma mark - Image compress
- (NSArray *)uploadImages {
    NSMutableArray *imgArr = [NSMutableArray array];
    if ([self.selectAssetModelArray count]==0) return imgArr;
    
    for (NSInteger i = 0; i<[self.selectAssetModelArray count]; i++) {
        PYAssetModel *assetModel = self.selectAssetModelArray[i];
        
        UIImage *image = assetModel.screenshotImage;
        if (!image) {
            image = assetModel.originImage;
        }
        if (!image) {
            image = assetModel.delicateImage ? assetModel.delicateImage : assetModel.degradedImage;
        }
        
        if (image) {
            if (image.size.width != 640) {
                image = [self scaleImage:image toScale:640/image.size.width];
            }
            //图片压缩
            NSData* imageData = [self compressImageWithOriginImage:image];
            UIImage *temp = [UIImage imageWithData:imageData];
            [imgArr addObject:temp];
        }
    }
    return imgArr;
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (NSData *)compressImageWithOriginImage:(UIImage *)originImg {
    NSData* imageData;
    float i = 1.0;
    do {
        imageData = UIImageJPEGRepresentation(originImg, i);
        i -= 0.1;
    } while (imageData.length > 2*1024*1024);
    
    return imageData;
}

#pragma mark - 手势事件
-(void)moveCollectionViewCell:(UILongPressGestureRecognizer *)gesture {
    
    //计算偏移量
    CGPoint point = [gesture locationInView:WINDOW];
    YWLog(@"------ccc %@",NSStringFromCGPoint(point));
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            if (!self.isBeganMove) {
                self.isBeganMove = YES;
                self.startMovePoint = point;
                
                //获取点击的cell的indexPath
                NSIndexPath *selectedIndexPath = [self.imageCollectionView indexPathForItemAtPoint:[gesture locationInView:self.imageCollectionView]];
            
                ZFCommunityShowPostPhotoCell *cell = (ZFCommunityShowPostPhotoCell *)[self.imageCollectionView cellForItemAtIndexPath:selectedIndexPath];
                
                //开始移动对应的cell
                [self.imageCollectionView beginInteractiveMovementForItemAtIndexPath:selectedIndexPath];
                self.startIndexPath = selectedIndexPath;
                [self showMaskFromCell:cell];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            //获取点击的cell的indexPath
            NSIndexPath *selectedIndexPath = [self.imageCollectionView indexPathForItemAtPoint:[gesture locationInView:self.imageCollectionView]];
            
            ZFCommunityShowPostPhotoCell *cell = (ZFCommunityShowPostPhotoCell *)[self.imageCollectionView cellForItemAtIndexPath:selectedIndexPath];

            //移动cell
            [self.imageCollectionView updateInteractiveMovementTargetPosition:[gesture locationInView:self.imageCollectionView]];
            
            [self moveMaskFromCell:cell point:point];

            break;
        }
        case UIGestureRecognizerStateEnded: {
            self.isBeganMove = false;
            
            NSIndexPath *selectedIndexPath = [self.imageCollectionView indexPathForItemAtPoint:[gesture locationInView:self.imageCollectionView]];
            
            ZFCommunityShowPostPhotoCell *cell = (ZFCommunityShowPostPhotoCell *)[self.imageCollectionView cellForItemAtIndexPath:selectedIndexPath];

            if (selectedIndexPath.row == self.selectAssetModelArray.count || !cell) {
                [self.imageCollectionView cancelInteractiveMovement];
                if (!self.changeIndexPath) {
                    [self moveEndFromCell:cell success:NO complet:nil];
                }
            } else {
                
                //结束移动
                [self.imageCollectionView endInteractiveMovement];
                if (!self.changeIndexPath) {
                    [self moveEndFromCell:cell success:YES complet:nil];
                }
            }

            break;
        }
        default:
            [self.imageCollectionView cancelInteractiveMovement];
            break;
    }
}

- (void)showMaskFromCell:(ZFCommunityShowPostPhotoCell *)imageCell {
    //FIXME: occ Bug 1101 待优化
    return;
    CGRect rect = [imageCell.superview convertRect:imageCell.frame toView:WINDOW];
    self.tempMaskImageView.image = imageCell.photoView.image;
    self.tempMaskImageView.backgroundColor = ZFRandomColor();
    self.tempMaskImageView.frame = rect;
    imageCell.contentView.hidden = YES;
    
    self.startCell = imageCell;
    self.startMaskPoint = self.tempMaskImageView.frame.origin;
    self.changeMaskRect = rect;
    
    if (!self.tempMaskImageView.superview) {
        [self.blackMaskView addSubview:self.tempMaskImageView];
    }
    if (self.blackMaskView.superview) {
        [self.blackMaskView removeFromSuperview];
    }
    self.blackMaskView.hidden = NO;
    [WINDOW addSubview:self.blackMaskView];
    
}

- (void)moveMaskFromCell:(ZFCommunityShowPostPhotoCell *)imageCell point:(CGPoint)point{
    //FIXME: occ Bug 1101 待优化
    return;
    CGFloat moveX = point.x - self.startMovePoint.x + self.startMaskPoint.x;
    CGFloat moveY = point.y - self.startMovePoint.y + self.startMaskPoint.y;
    
    CGRect frame = self.tempMaskImageView.frame;
    frame.origin = CGPointMake(moveX, moveY);
    self.tempMaskImageView.frame = frame;
}

- (void)moveEndFromCell:(ZFCommunityShowPostPhotoCell *)imageCell success:(BOOL)success complet:(void (^)(void))completion{
    //FIXME: occ Bug 1101 待优化
    return;
    CGRect rect = [imageCell.superview convertRect:imageCell.frame toView:WINDOW];
    YWLog(@"------- end: %@",NSStringFromCGRect(rect));
    if (self.changeIndexPath) {
        self.changeMaskRect = rect;
    }
    if (success) {
        
        [UIView animateWithDuration:0.5 animations:^{
                   self.tempMaskImageView.frame = self.changeMaskRect;
               } completion:^(BOOL finished) {
                   self.startCell.contentView.hidden = NO;
                   [UIView animateWithDuration:0.1 animations:^{
                       if (self.blackMaskView.superview) {
                           [self.blackMaskView removeFromSuperview];
                       }
                       self.blackMaskView.hidden = YES;
                   }];
                   self.changeIndexPath = nil;
                   if (completion) {
                       completion();
                   }
               }];
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.tempMaskImageView.frame = self.changeMaskRect;
        } completion:^(BOOL finished) {
            self.startCell.contentView.hidden = NO;
            [UIView animateWithDuration:0.1 animations:^{
                if (self.blackMaskView.superview) {
                    [self.blackMaskView removeFromSuperview];
                }
                self.blackMaskView.hidden = YES;
            }];
            self.changeIndexPath = nil;
            if (completion) {
                completion();
            }
        }];
    }

    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == _imageCollectionView) {
        if (self.selectAssetModelArray.count >= 2) {
            [self showLongPressDeleteTipView];
        }
        return self.selectAssetModelArray.count + 1;
    }
    return self.selectGoods.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _imageCollectionView) {
        ZFCommunityShowPostPhotoCell *cell = [ZFCommunityShowPostPhotoCell postPhotoCellWithCollectionView:collectionView forIndexPath:indexPath];
        cell.isNeedHiddenAddView = indexPath.row == 9 ? YES : NO;
        if (indexPath.row == self.selectAssetModelArray.count) {
            [cell setAddPhotoImage:[UIImage imageNamed:@"add_album_photo"]];
        } else if(self.selectAssetModelArray.count > indexPath.row) {
            
            PYAssetModel *assetModel = self.selectAssetModelArray[indexPath.row];
            if (!assetModel.originImage) {
                @weakify(cell)
                [assetModel getOriginImage:^(UIImage *image) {
                    @strongify(cell)
                    cell.assetModel = assetModel;
                } progress:^(double progress) {
                    
                }];
                YWLog(@"----- 无原图----");
            }
            cell.assetModel = self.selectAssetModelArray[indexPath.row];
            
//            if (self.changeIndexPath) {
//                cell.contentView.hidden = YES;
//            } else if(self.startIndexPath) {
//                cell.contentView.hidden = YES;
//            } else {
//                cell.contentView.hidden = NO;
//            }
        }
        
        @weakify(self)
        cell.deletePhotoBlock = ^(PYAssetModel *assetModel){
            @strongify(self)
            [self deleteCollectionViewPhotot:collectionView withImage:assetModel];
        };
        cell.longPressBlock = ^(UILongPressGestureRecognizer *gesture) {
            @strongify(self)
            if (indexPath.row != self.selectAssetModelArray.count) {
                [self moveCollectionViewCell:gesture];
            }
        };
        
        //FIXME: occ Bug 1101 待优化

//        if (!self.blackMaskView.isHidden) {
//            if (self.startIndexPath.row != indexPath.row) {
//
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    @weakify(cell);
//                    [self moveEndFromCell:cell success:YES complet:^{
//                        @strongify(cell);
//                        cell.contentView.hidden = NO;
//                    }];
//
//                    YWLog(@"------ end ---end: %li",(long)indexPath.row);
//
//                });
//            }
//
//        }
        return cell;
        
    } else {
        ZFCommunityShowPostGoodsImageCell *cell = [ZFCommunityShowPostGoodsImageCell goodsImageCellWithCollectionView:collectionView forIndexPath:indexPath];
        cell.isNeedHiddenAddView = indexPath.row == 6 ? YES : NO;
        if (indexPath.row == self.selectGoods.count) {
            [cell setAddImage:[UIImage imageNamed:@"post_add"]];
        } else{
            cell.model = self.selectGoods[indexPath.row];
        }
                
        @weakify(self)
        cell.deleteGoodBlock = ^(ZFCommunityPostShowSelectGoodsModel *model) {
            @strongify(self)
            [self deleteCollectionViewGoods:collectionView withModel:model];
        };
        return cell;
    }
    return nil;
}
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.selectAssetModelArray.count) {
        return NO;
    }
    YWLog(@"------canMoveIndex %li",(long)indexPath.row);
    return YES;
}
-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //处理数据（删除之前的位置数据，插入到新的位置）
     if (collectionView == _imageCollectionView) {
         if (destinationIndexPath.row == self.selectAssetModelArray.count) {
             [self.imageCollectionView reloadData];
             return;
         }
         self.changeIndexPath = destinationIndexPath;
         PYAssetModel *assetModel = self.selectAssetModelArray[sourceIndexPath.item];
         [self.selectAssetModelArray removeObjectAtIndex:sourceIndexPath.item];
         [self.selectAssetModelArray insertObject:assetModel atIndex:destinationIndexPath.item];
         for (int i=0; i<self.selectAssetModelArray.count; i++) {
             PYAssetModel *model = self.selectAssetModelArray[i];
             model.orderNumber = i+1;
         }
     }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.goodsCollectionView) {
        return CGSizeMake(self.itemsWidth,self.itemsWidth);
    }
    return CGSizeMake(self.itemsWidth,self.itemsWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [self.view endEditing:YES];
    if (indexPath.item >= 9) return;
    
    
    if (collectionView == _imageCollectionView) {
        if (self.selectAssetModelArray.count == indexPath.row) {
            [self jumpToAlbumVC];
        } else {
            
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            CGRect rect = [cell convertRect:cell.frame toView:WINDOW];
            [self.albumPhotoView updateAssets:self.selectAssetModelArray index:indexPath.row];
            [self.albumPhotoView showView:YES rect:rect];
        }
    } else {
        //进入选择商品
        [self pushToGoodsPageVC];
    }
}

#pragma mark -===========Cell按钮操作事件===========

/**
 * 删除相片
 */
- (void)deleteCollectionViewPhotot:(UICollectionView *)collectionView withImage:(PYAssetModel *)assetModel
{
    if (!assetModel) {
        return;
    }
    NSUInteger index = [self.selectAssetModelArray indexOfObject:assetModel];
    [self.selectAssetModelArray removeObjectAtIndex:index];
    
    [[PYAblum defaultAblum] removeSelectedAssetWith:assetModel];
    
    for (int i=0; i<self.selectAssetModelArray.count; i++) {
        PYAssetModel *model = self.selectAssetModelArray[i];
        model.orderNumber = i+1;
    }
    [collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [collectionView deleteItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        if (finished) [collectionView reloadData];
    }];
    
    [self updatePostButtonEnableState];
}

/**
 * 删除商品
 */
- (void)deleteCollectionViewGoods:(UICollectionView *)collectionView withModel:(ZFCommunityPostShowSelectGoodsModel *)model
{
    NSUInteger index = [self.selectGoods indexOfObject:model];
    [self.selectGoods removeObject:model];
//    self.itemsLabel.text = [NSString stringWithFormat:@"%@ (%ld/6)",ZFLocalizedString(@"Post_VC_Post_AddItems",nil),(unsigned long)self.selectGoods.count];
    [[PostGoodsManager sharedManager] removeGoodsWithModel:model];
    [collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [collectionView deleteItemsAtIndexPaths:@[indexPath]];
        NSMutableArray *newGoods = [NSMutableArray arrayWithArray:self.selectGoods];
        self.selectGoods = newGoods;
    } completion:^(BOOL finished) {
        if (finished) [collectionView reloadData];
    }];
}

/**
* 选择相册图片
*/

- (void)jumpToAlbumVC {
    
    @weakify(self)
    [LBXPermission authorizeWithType:LBXPermissionType_Photos completion:^(BOOL granted, BOOL firstTime) {
        @strongify(self)
        ZFCommunityShowAlbumVC *ablumVC = [[ZFCommunityShowAlbumVC alloc] init];
        [[PYAblum defaultAblum] removeSelectedAssetModelArray];
        if (self.selectAssetModelArray.count > 0) {
            for (int i=0; i<self.selectAssetModelArray.count; i++) {
                PYAssetModel *model = self.selectAssetModelArray[i];
                model.orderNumber = i+1;
            }
            [[PYAblum defaultAblum] updateSelectAssetModelArray:self.selectAssetModelArray];
        }
        
        @weakify(self)
        ablumVC.confirmAlbumsBlock = ^(NSMutableArray<PYAssetModel *> *selectAssetModelArray) {
            @strongify(self)
            [self.selectAssetModelArray removeAllObjects];
            [self.selectAssetModelArray addObjectsFromArray:selectAssetModelArray];
            [self.imageCollectionView reloadData];
            [self updatePostButtonEnableState];
        };
        [ablumVC showParentController:self topGapHeight:kiphoneXTopOffsetY];
    }];
     
}
/**
 * 进入选择商品
 */
- (void)pushToGoodsPageVC
{
    ZFCommunityShowGoodsPageVC *pageVC = [[ZFCommunityShowGoodsPageVC alloc] init];
    pageVC.title = ZFLocalizedString(@"Post_VC_Post_AddItems",nil);
    pageVC.hasSelectGoods = self.selectGoods.count > 0 ? YES : NO;
    pageVC.goodsCount = self.selectGoods.count;
    @weakify(self)
    pageVC.doneBlock = ^(NSMutableArray *selectArray){
        @strongify(self)
        self.selectGoods = selectArray;
//        self.itemsLabel.text = [NSString stringWithFormat:@"%@ (%ld/6)",ZFLocalizedString(@"Post_VC_Post_AddItems",nil),(unsigned long)selectArray.count];
        [self.goodsCollectionView reloadData];
    };
    [pageVC showParentController:self topGapHeight:kiphoneXTopOffsetY];
}


- (void)showMaxSelectTagsMessage {
    [self showAlertMessage:ZFLocalizedString(@"Post_VC_Post_MaxTag_Tip",nil)];
}

#pragma mark - YSTextView

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self.searchHotWordManager searchTextView:textView shouldChangeTextInRange:range replacementText:text];

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString * text = textView.text;
    
    [self updatePostButtonEnableState];
    if (textView.markedTextRange == nil && text.length > KMaxInputCount){
        [self showAlertMessage:ZFLocalizedString(@"Post_VC_Post_TextView_Tip",nil)];
        text = [text substringToIndex:KMaxInputCount];
        textView.text = text;
        //截取的操作会入undo栈，之后的setText：方法并不会清空undo栈，导致做undo操作时，逆操作的是字符串截取的操作，操作的数据对不上，导致崩溃，这是我觉得比较合理的解释
        [textView.undoManager removeAllActions];
    }
    [self.searchHotWordManager searchTextViewDidChange:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.searchHotWordManager searchTextViewDidEndEditing:textView];
    [self.searchHotWordView hiddenHotWordView];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [IQKeyboardManager sharedManager].enable  = NO;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = NO;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [IQKeyboardManager sharedManager].enable  = YES;
    return YES;
}

#pragma mark - ZFOutfitSearchHotWordView delegate

- (void)ZFOutfitSearchHotWordViewDidClickHotWord:(NSString *)word
{
    NSString *text = self.textView.text;
    [self.searchHotWordManager replaceInputKeyWithMatchKey:text matchKey:word];
    [self.searchHotWordView hiddenHotWordView];
}

#pragma mark - ZFOutfitSearchHotWordManager delegate

- (void)ZFOutfitSearchHotWordStartSearch:(ZFOutfitSearchHotWordManager *)manager matchList:(NSArray<HotWordModel *> *)list matchKeyword:(NSString *)keyword
{
    
    if (!self.searchHotWordView.superview) {
//        CGSize size = [self.textView.text sizeWithAttributes:@{NSFontAttributeName: self.textView.font}];
//        YWLog(@"----- %f",size.height);
//        CGFloat moveY = size.height < 50 ? 50 : size.height;
//        if (size.height > 100) {
//            moveY = 100;
//        }
//        if (moveY > CGRectGetHeight(self.textView.frame)) {
//            moveY = CGRectGetHeight(self.textView.frame) - 5;
//        }
        CGFloat navHeight = CGRectGetHeight(self.navBarView.frame);
        [self.searchHotWordView showHotWordView:self.view offsetY:CGRectGetMaxY(self.textView.frame) + navHeight contentOffsetY:self.keyboardHeight];
    }
    [self.searchHotWordView reloadHotWord:list key:keyword];
}

- (void)ZFOutfitSearchHotWordEndSearch:(ZFOutfitSearchHotWordManager *)manager
{
    [self.searchHotWordView hiddenHotWordView];
}

- (void)ZFOutfitSearchHotWordDidChangeAttribute:(NSAttributedString *)attribute
{
    self.textView.attributedText = attribute;
}


#pragma mark - ShowTip

- (void)showAddGoodsTipView {
    
    BOOL isShowAddGoodsTip = [GetUserDefault(kZFCommunityShowPostViewTip) boolValue];
    if (!_addGoodsTipView && !isShowAddGoodsTip) {
        SaveUserDefault(kZFCommunityShowPostViewTip, @(YES));
        
        CGRect goodsViewFrame = [ZFTitleArrowTipView sourceViewFrameToWindow:self.goodsCollectionView];
        if (CGRectGetMinY(goodsViewFrame) < KScreenHeight) {
            [self.containView addSubview:self.addGoodsTipView];
            
            CGFloat cellWidth = (KScreenWidth - 5 * KImageMargin) / 4;
            
            //community_Post_Show_Relate_Goods_Guide
            [self.addGoodsTipView updateTipArrowOffset:cellWidth / 2.0 direct:[SystemConfigUtils isRightToLeftShow] ? ZFTitleArrowTipDirectDownRight : ZFTitleArrowTipDirectDownLeft cotent:ZFLocalizedString(@"Community_AddItemHere", nil)];

            [self.addGoodsTipView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.containView.mas_leading).offset(12);
                make.bottom.mas_equalTo(self.goodsCollectionView.mas_top).offset(-10);
                make.width.mas_lessThanOrEqualTo(KScreenWidth - 24);
            }];
            
            [self.addGoodsTipView hideViewWithTime:3.0 complectBlock:nil];
        }
    }
}

- (void)showAddPhotoTipView {
    BOOL isShowAddPhotoTip = [GetUserDefault(kZFCommunityShowPostPhotoViewTip) boolValue];
    if (!_addPhotoTipView && !isShowAddPhotoTip) {
        SaveUserDefault(kZFCommunityShowPostPhotoViewTip, @(YES));
        
        CGRect goodsViewFrame = [ZFTitleArrowTipView sourceViewFrameToWindow:self.imageCollectionView];
        if (CGRectGetMinY(goodsViewFrame) < KScreenHeight) {
            [self.containView addSubview:self.addPhotoTipView];
            
            CGFloat cellWidth = (KScreenWidth - 5 * KImageMargin) / 4;
            
            [self.addPhotoTipView updateTipArrowOffset:cellWidth / 2.0 direct:[SystemConfigUtils isRightToLeftShow] ? ZFTitleArrowTipDirectUpRight : ZFTitleArrowTipDirectUpLeft cotent:ZFLocalizedString(@"Community_AddPhotoHere", nil)];

            [self.addPhotoTipView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.containView.mas_leading).offset(12);
                make.top.mas_equalTo(self.imageCollectionView.mas_bottom).offset(3);
                make.width.mas_lessThanOrEqualTo(KScreenWidth - 24);
            }];
            
            @weakify(self)
            [self.addPhotoTipView hideViewWithTime:3.0 complectBlock:^{
                @strongify(self)
                [self showAddGoodsTipView];
            }];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionHidePhotoTip:)];
            [self.addPhotoTipView addGestureRecognizer:tapGesture];
        }
    } else {
        [self showAddGoodsTipView];
    }
}

- (void)showLongPressDeleteTipView {
    
    BOOL isShowAddPhotoTip = [GetUserDefault(kZFCommunityShowPostLongPressDeleteViewTip) boolValue];
    if (!_longPhotoPressTipView && !isShowAddPhotoTip) {
        SaveUserDefault(kZFCommunityShowPostLongPressDeleteViewTip, @(YES));
        
        CGRect goodsViewFrame = [ZFTitleArrowTipView sourceViewFrameToWindow:self.imageCollectionView];
        if (CGRectGetMinY(goodsViewFrame) < KScreenHeight) {
            [self.containView addSubview:self.longPhotoPressTipView];
            
            CGFloat cellWidth = (KScreenWidth - 5 * KImageMargin) / 4;
            
            [self.longPhotoPressTipView updateTipArrowOffset:cellWidth / 2.0 direct:[SystemConfigUtils isRightToLeftShow] ? ZFTitleArrowTipDirectUpRight : ZFTitleArrowTipDirectUpLeft cotent:ZFLocalizedString(@"Community_LongPressTips", nil)];

            [self.longPhotoPressTipView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.containView.mas_leading).offset(12);
                make.top.mas_equalTo(self.imageCollectionView.mas_bottom).offset(3);
                make.width.mas_lessThanOrEqualTo(KScreenWidth - 24);
            }];
            
            [self.longPhotoPressTipView hideViewWithTime:3.0 complectBlock:nil];
        }
    }
}


- (void)actionHidePhotoTip:(UIGestureRecognizer *)gesture {
    [_addPhotoTipView hideView];
    BOOL isShowAddGoodsTip = [GetUserDefault(kZFCommunityShowPostViewTip) boolValue];
    if (!isShowAddGoodsTip) {
        [self showAddGoodsTipView];
    }
}
- (void)showAlertMessage:(NSString *)message {
    ShowAlertSingleBtnView(message, nil, ZFLocalizedString(@"Post_VC_Post_Alert_OK",nil));
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.textView) {
        [self.view endEditing:YES];
    }
}

#pragma mark - Setter/Getter

- (ZFCommunityViewModel *)communityViewModel {
    if (!_communityViewModel) {
        _communityViewModel = [[ZFCommunityViewModel alloc] init];
    }
    return _communityViewModel;
}

- (void)setSelectHotTopicModel:(ZFCommunityHotTopicModel *)selectHotTopicModel {
    _selectHotTopicModel = selectHotTopicModel;
    if (!ZFIsEmptyString(selectHotTopicModel.label)) {
        [self.hotTopicButton setTitle:selectHotTopicModel.label forState:UIControlStateNormal];
        [self.hotTopicButton setTitleColor:ZFC0x3D76B9() forState:UIControlStateNormal];
        [self.hotTopicButton setTitleColor:ZFC0x3D76B9() forState:UIControlStateHighlighted];
        [self.hotTopicButton setBackgroundColor:ZFC0x3D76B9_01()];
    } else {
        [self.hotTopicButton setTitle:[NSString stringWithFormat:@"#%@",ZFLocalizedString(@"Community_HotEvents", nil)] forState:UIControlStateNormal];
        [self.hotTopicButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        [self.hotTopicButton setTitleColor:ZFC0x999999() forState:UIControlStateHighlighted];
        [self.hotTopicButton setBackgroundColor:ZFC0xF7F7F7()];
    }
}


- (ZFCommunityDynamicNavBar *)navBarView {
    if (!_navBarView) {
        _navBarView = [[ZFCommunityDynamicNavBar alloc] init];
        _navBarView.isNotNeedSkin = YES;
        _navBarView.isHideBottomLine = YES;
        _navBarView.buttonHeight = 24;
        [_navBarView updateBackImage:[UIImage imageNamed:@"z-me_outfits_post_close"]];
        @weakify(self)
        _navBarView.backItemHandle = ^{
            @strongify(self)
            [self cancleAction];
        };
    }
    return _navBarView;
}

-(UIView *)containView {
    if (!_containView) {
        _containView = [[UIView alloc] init];
        _containView.backgroundColor = ZFC0xFFFFFF();
    }
    return _containView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFC0xEEEEEE();
    }
    return _lineView;
}

- (UIView *)showZZZZZBottomLine {
    if (!_showZZZZZBottomLine) {
        _showZZZZZBottomLine = [[UIView alloc] initWithFrame:CGRectZero];
        _showZZZZZBottomLine.backgroundColor = ZFC0xEEEEEE();
    }
    return _showZZZZZBottomLine;
}

-(YSTextView *)textView {
    if (!_textView) {
        _textView = [[YSTextView alloc] init];
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.textColor = [UIColor blackColor];
        _textView.placeholderFont = [UIFont systemFontOfSize:14];
//        _textView.placeholder = ZFLocalizedString(@"Post_VC_Post_TextView_Placeholder",nil);
        _textView.placeholder = ZFLocalizedString(@"Community_Shareideas",nil);
        _textView.placeholderColor = ZFC0xCCCCCC();
        _textView.placeholderPoint = CGPointMake(10, 8.3);
    
        _textView.textContainerInset = UIEdgeInsetsMake(8.3, 7, 0, 0);
        _textView.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    }
    return _textView;
}

-(UICollectionView *)imageCollectionView {
    if (!_imageCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _imageCollectionView.scrollEnabled = YES;
        _imageCollectionView.backgroundColor = [UIColor whiteColor];
        _imageCollectionView.alwaysBounceHorizontal = YES;
        _imageCollectionView.showsVerticalScrollIndicator = NO;
        _imageCollectionView.showsHorizontalScrollIndicator = NO;
        _imageCollectionView.delegate = self;
        _imageCollectionView.dataSource = self;
        _imageCollectionView.tag = 100;
        [_imageCollectionView registerClass:[ZFCommunityShowPostPhotoCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityShowPostPhotoCell class])];
        if (@available(iOS 11.0, *)) {
            _imageCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _imageCollectionView;
}


-(UIView *)goodsView {
    if (!_goodsView) {
        _goodsView = [[UIView alloc] init];
        _goodsView.backgroundColor = [UIColor whiteColor];
    }
    return _goodsView;
}

- (UIButton *)hotTopicButton {
    if (!_hotTopicButton) {
        _hotTopicButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_hotTopicButton addTarget:self action:@selector(actionHot:) forControlEvents:UIControlEventTouchUpInside];
        [_hotTopicButton setTitle:[NSString stringWithFormat:@"#%@",ZFLocalizedString(@"Community_HotEvents", nil)] forState:UIControlStateNormal];
        [_hotTopicButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        _hotTopicButton.backgroundColor = ZFC0xF7F7F7();
        _hotTopicButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _hotTopicButton.layer.cornerRadius = 14;
        _hotTopicButton.layer.masksToBounds = YES;
        _hotTopicButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
    }
    return _hotTopicButton;
}

- (UIView *)publicView {
    if (!_publicView) {
        _publicView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _publicView;
}
- (UILabel *)publicTipLabel {
    if (!_publicTipLabel) {
        _publicTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _publicTipLabel.text = ZFLocalizedString(@"Community_OnlyZZZZZ", nil);
        _publicTipLabel.textColor = ZFC0xCCCCCC();
        _publicTipLabel.font = [UIFont systemFontOfSize:12];
        _publicTipLabel.numberOfLines = 2;
    }
    return _publicTipLabel;
}

- (UISwitch *)publicSwitch {
    if (!_publicSwitch) {
        _publicSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        _publicSwitch.transform = CGAffineTransformMakeScale(0.6, 0.6);
        [_publicSwitch addTarget:self action:@selector(showZFSwitchAction:) forControlEvents:UIControlEventValueChanged];
        [_publicSwitch setOnTintColor:ZFC0xFE5269()];
    }
    return _publicSwitch;
}

-(UICollectionView *)goodsCollectionView {
    if (!_goodsCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _goodsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _goodsCollectionView.scrollEnabled = YES;
        _goodsCollectionView.backgroundColor = [UIColor whiteColor];
        _goodsCollectionView.alwaysBounceHorizontal = YES;
        _goodsCollectionView.showsVerticalScrollIndicator = NO;
        _goodsCollectionView.showsHorizontalScrollIndicator = NO;
        _goodsCollectionView.delegate = self;
        _goodsCollectionView.dataSource = self;
        _goodsCollectionView.tag = 200;
        [_goodsCollectionView registerClass:[ZFCommunityShowPostGoodsImageCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityShowPostGoodsImageCell class])];
        if (@available(iOS 11.0, *)) {
            _goodsCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _goodsCollectionView;
}

- (ZFTitleArrowTipView *)addGoodsTipView {
    if (!_addGoodsTipView) {
        _addGoodsTipView = [[ZFTitleArrowTipView alloc] init];
    }
    return _addGoodsTipView;
}

- (ZFTitleArrowTipView *)addPhotoTipView {
    if (!_addPhotoTipView) {
        _addPhotoTipView = [[ZFTitleArrowTipView alloc] init];
    }
    return _addPhotoTipView;
}

- (ZFTitleArrowTipView *)longPhotoPressTipView {
    if (!_longPhotoPressTipView) {
        _longPhotoPressTipView = [[ZFTitleArrowTipView alloc] init];
    }
    return _longPhotoPressTipView;
}

-(NSMutableArray *)selectGoods {
    if (!_selectGoods) {
        _selectGoods = [NSMutableArray array];
    }
    return _selectGoods;
}

-(ZFCommunityPostViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityPostViewModel alloc] init];
    }
    return _viewModel;
}


- (ZFCommunityAlbumPhotoView *)albumPhotoView {
    if (!_albumPhotoView) {
        _albumPhotoView = [[ZFCommunityAlbumPhotoView alloc] init];
    }
    return _albumPhotoView;
}


- (ZFOutfitSearchHotWordManager *)searchHotWordManager
{
    if (!_searchHotWordManager) {
        _searchHotWordManager = [ZFOutfitSearchHotWordManager manager];
        _searchHotWordManager.compareKey = @"label";
        _searchHotWordManager.delegate = self;
    }
    return _searchHotWordManager;
}

- (ZFOutfitSearchHotWordView *)searchHotWordView
{
    if (!_searchHotWordView) {
        _searchHotWordView = [[ZFOutfitSearchHotWordView alloc] init];
        _searchHotWordView.delegate = self;
    }
    return _searchHotWordView;
}

- (UIView *)blackMaskView {
    if (!_blackMaskView) {
        _blackMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
        _blackMaskView.backgroundColor = ZFC0x000000_04();
        _blackMaskView.hidden = YES;
    }
    return _blackMaskView;
}

- (UIImageView *)tempMaskImageView {
    if (!_tempMaskImageView) {
        _tempMaskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.itemsWidth, self.itemsWidth)];
        _tempMaskImageView.contentMode = UIViewContentModeScaleAspectFill;
        _tempMaskImageView.layer.masksToBounds = YES;

    }
    return _tempMaskImageView;
}

- (void)updatePostButtonEnableState {
    BOOL enable = NO;
    if (self.selectAssetModelArray.count > 0) {
        enable = YES;
    }
    [self updatePreviewEnable:enable];
    [self updatePostButtonEnable:YES];
}

- (void)updatePreviewEnable:(BOOL)enable {
    UIButton *preivewButton = [self.navBarView currentIndexButton:0];
    if (!preivewButton) {
        return;
    }
    
    preivewButton.enabled = enable;
    if (enable) {
        preivewButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        [preivewButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        
    } else {
        preivewButton.layer.borderColor = ZFC0xCCCCCC().CGColor;
        [preivewButton setTitleColor:ZFC0xCCCCCC() forState:UIControlStateNormal];
    }
}

- (void)updatePostButtonEnable:(BOOL)enable {
    UIButton *posButton = [self.navBarView currentIndexButton:1];
    if (!posButton) {
        return;
    }
    
    [posButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
}

@end
