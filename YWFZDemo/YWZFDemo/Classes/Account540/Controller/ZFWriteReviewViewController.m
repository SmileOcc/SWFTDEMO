//
//  ZFWriteReviewViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFWriteReviewViewController.h"
#import "ZFCommentSuccessVC.h"
#import "TZImagePickerController.h"
#import "ZFInitViewProtocol.h"
#import "YYPhotoBrowseView.h"
#import "ZFSubmitReviewViewModel.h"
#import "ZFOrderReviewModel.h"
#import "ZFWriteReviewResultModel.h"
#import "ZFOrderReviewSubmitModel.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "AccountManager.h"
#import "Constants.h"
#import "ZFPickerView.h"
#import "ZFOrderReviewListModel.h"
#import "YWCFunctionTool.h"
#import "ZFReviewPropertyView.h"
#import "ZFWriteReviewScrollView.h"
#import "ZFWaitCommentModel.h"
#import "ExchangeManager.h"
#import "ZFLocalizationString.h"
#import "NSStringUtils.h"

@interface ZFWriteReviewViewController () <ZFInitViewProtocol, TZImagePickerControllerDelegate>
@property (nonatomic, strong) ZFWriteReviewScrollView               *reviewScrollView;
@property (nonatomic, strong) ZFSubmitReviewViewModel               *viewModel;
@property (nonatomic, strong) NSMutableArray<ZFOrderReviewModel *>  *dataArray;
@property (nonatomic, strong) NSMutableArray<NSArray *>             *sizeArray;
@property (nonatomic, strong) ZFOrderReviewSubmitModel              *submitModel;
@end

@implementation ZFWriteReviewViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"TopicDetailView_Reviews", nil);
    
    [self zfInitView];
    [self zfAutoLayoutView];
    [self requestOrderReviewInfoOption];
}
 
//判断是否有没有评论的商品，如果有，提示弹框，否则 直接返回上一级页面
- (void)goBackAction {
    NSString *pontsMsg = ZFToString(self.reviewScrollView.reviewModel.goods_info.review_point);
    NSString *youhuilv = ZFToString(self.reviewScrollView.reviewModel.goods_info.review_coupon.youhuilv);
    NSString *fangshi = ZFToString(self.reviewScrollView.reviewModel.goods_info.review_coupon.fangshi);
    
    NSString *content;
    if (!ZFIsEmptyString(youhuilv)) {
        NSString *couponMsg = [ExchangeManager localCouponContent:@"USD" youhuilv:youhuilv fangshi:fangshi];
        content = [NSString stringWithFormat:ZFLocalizedString(@"Order_Comment_Back_Tips_XXPoints_XXCoupon", nil),pontsMsg,couponMsg];

    } else {
        content = [NSString stringWithFormat:ZFLocalizedString(@"Order_Comment_Back_Tips_XXPoints", nil),pontsMsg];
    }
    NSString *message = content;
    NSString *conitnueTitle = ZFLocalizedString(@"Post_VC_Post_Cancel_No",nil);
    NSString *exitTitle = ZFLocalizedString(@"Post_VC_Post_Cancel_Yes",nil);
    
    ShowAlertView(nil, message, @[conitnueTitle], ^(NSInteger buttonIndex, id buttonTitle) {
        [self.navigationController popViewControllerAnimated:YES];
    }, exitTitle, nil);
}

#pragma mark - <NetWork>

///请求尺码信息表
- (void)requestOrderReviewInfoOption {
    ShowLoadingToView(self.view);
    NSString *orderId = self.commentModel.order_id;
    NSString *goodsId = self.commentModel.goods_id;
    NSDictionary *dic = @{@"order_id":ZFToString(orderId),@"goods_id":ZFToString(goodsId)};
    
    @weakify(self);
    [self.viewModel requestOrderReviewListNetwork:dic completion:^(ZFOrderReviewListModel *model) {
        @strongify(self);
        HideLoadingFromView(self.view);
        
        self.dataArray = model.result;
        if (model.size.height) {
            [self.sizeArray addObject:model.size.height];
        }
        if (model.size.waist) {
            [self.sizeArray addObject:model.size.waist];
        }
        if (model.size.hips) {
            [self.sizeArray addObject:model.size.hips];
        }
        if (model.size.bust) {
            [self.sizeArray addObject:model.size.bust];
        }
        ZFOrderReviewModel *firstReviewModel = self.dataArray.firstObject;
        self.reviewScrollView.reviewModel = firstReviewModel;
        [self.reviewScrollView setDefaultSizeModeValue:self.sizeArray];
        self.reviewScrollView.hidden = NO;

        if ([model isKindOfClass:[ZFOrderReviewListModel class]]) {
            [self removeEmptyView];
        } else {
            [self showEmptyView];
        }
    } failure:^(id obj) {
        @strongify(self);
        [self showEmptyView];
        HideLoadingFromView(self.view);
    }];
}

- (void)showEmptyView {
    self.edgeInsetTop = kiphoneXTopOffsetY + 44;
    self.emptyImage = [UIImage imageNamed:@"blankPage_favorites"];
    self.emptyTitle = ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil);
    @weakify(self)
    [self showEmptyViewHandler:^{
        @strongify(self)
        ShowLoadingToView(self.view);
        [self requestOrderReviewInfoOption];
    }];
}

/// 提交评论
- (void)commitOrderReview {
    if (self.submitModel.content.length < 30) {
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"WriteReview_Textfiled_Min_Tip",nil));
        return;
    }
    if (self.submitModel.overallid == -1) {
        self.submitModel.overallid = 0;
//        ShowToastToViewWithText(self.view, ZFLocalizedString(@"OverallFit_Required", nil));
//        return;
    }
    if (self.submitModel.avgRate <= 0.1) {
        self.submitModel.avgRate = 5.0f;
    }
    
    //包装评论数据，图片压缩等
    NSDictionary *size = [self.reviewScrollView selectedBodySize];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:size];
    params[@"title"]            = ZFToString(self.commentModel.goods_title);
    params[@"goods_id"]         = ZFToString(self.commentModel.goods_id);
    params[@"attr_strs"]        = ZFToString(self.commentModel.goods_attr_str);
    params[@"order_id"]         = ZFToString(self.commentModel.order_id);
    params[@"content"]          = ZFToString(self.submitModel.content);
    params[@"images"]           = [self compressPhoto];
    params[@"sync_community"]   = @(self.submitModel.sync_community);
    params[@"rate_overall"]     = @(self.submitModel.avgRate);
    params[@"overall_fit"]      = @(self.submitModel.overallid);
    params[kLoadingView]        = self.view;
    
    @weakify(self)
    [self.viewModel requestWriteReview:params completion:^(ZFWriteReviewResultModel *model) {
        @strongify(self)
        if (![model isKindOfClass:[ZFWriteReviewResultModel class]]) return;
        
        //评论成功
        [self reviewActionWithModel:model];
        
        if (model.is_show_popup) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showAppStoreCommentWithContactUs:model.contact_us];

            });
        }
        
    } failure:nil];
}

- (void)reviewActionWithModel:(ZFWriteReviewResultModel *)resultModel {
    if (self.commentSuccessBlock) {
        self.commentSuccessBlock(self.commentModel);
    }
    
    ZFCommentSuccessVC *successVC = [[ZFCommentSuccessVC alloc] init];
    successVC.resultModel = resultModel;
    [self.navigationController pushViewController:successVC animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kZFReloadOrderListData object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ZFPostNotification(kRefreshWaitCommentListData, nil);
    });
}

#pragma mark - 压缩图片方法
- (NSMutableArray *)compressPhoto
{
    NSMutableArray *imageArray = [NSMutableArray array];
    if (self.submitModel.selectedPhotos.count <= 0) {
        return imageArray;
    }
    [self.submitModel.selectedPhotos enumerateObjectsUsingBlock:^(UIImage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            UIImage *tmp;
            if (obj.size.width != 640) {
                tmp = [self scaleImage:obj toScale:640/obj.size.width];
            }
            NSData *imageData = [self compressImageWithOriginImage:obj];
            tmp = [UIImage imageWithData:imageData];
            [imageArray addObject:tmp];
        }
    }];
    return imageArray;
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
    do {
        imageData = UIImageJPEGRepresentation(originImg, 0.9);
    } while (imageData.length > 2*1024*1024);
    return imageData;
}

#pragma mark - <TZImagePickerController>

- (void)pushImagePickerController
{
    TZImagePickerController *customImagePickerController = [[TZImagePickerController alloc] initWithMaxImagesCount:3 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    customImagePickerController.isSelectOriginalPhoto = YES;
    // 1.设置目前已经选中的图片数组
    customImagePickerController.selectedAssets = self.submitModel.selectedAssets; // 目前已经选中的图片数组
    customImagePickerController.allowTakePicture = YES; // 在内部显示拍照按钮
    // 3. 设置是否可以选择视频/图片/原图
    customImagePickerController.allowPickingVideo = NO;
    customImagePickerController.allowPickingImage = YES;
    customImagePickerController.allowPickingOriginalPhoto = YES;
    // 4. 照片排列按修改时间升序
    customImagePickerController.sortAscendingByModificationDate = NO;
    customImagePickerController.minImagesCount = 1;
    customImagePickerController.maxImagesCount = 3;
    customImagePickerController.naviBgColor = [UIColor whiteColor];
    customImagePickerController.naviTitleColor = [UIColor blackColor];
    
    UIStatusBarStyle style = [self preferredStatusBarStyle];
    customImagePickerController.statusBarStyle = style;
    customImagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    // 换肤时这里的导航按钮色需要自定义
    UIColor *barItemTextColor = [UIColor blackColor];
    if ([AccountManager sharedManager].needChangeAppSkin) {
        barItemTextColor = [AccountManager sharedManager].appNavFontColor;
    }
    customImagePickerController.barItemTextColor = barItemTextColor;
    [self presentViewController:customImagePickerController animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController  *)picker
       didFinishPickingPhotos:(NSArray *)photos
                 sourceAssets:(NSArray *)assets
        isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    self.submitModel.selectedPhotos = [NSMutableArray arrayWithArray:photos];
    self.submitModel.selectedAssets = [NSMutableArray arrayWithArray:assets];
    //刷新选择的图片
    self.reviewScrollView.photosArray = self.submitModel.selectedPhotos;
}

- (void)deleteSeletedImageHandle:(NSInteger)index {
    if (self.submitModel.selectedAssets.count > index
        && self.submitModel.selectedPhotos.count > index) {
        [self.submitModel.selectedAssets removeObjectAtIndex:index];
        [self.submitModel.selectedPhotos removeObjectAtIndex:index];
        self.reviewScrollView.photosArray = self.submitModel.selectedPhotos;
    }
}

- (void)openPhotosBrowseViewWithIndex:(NSInteger)index
                            rectArray:(NSArray *)rectArray
{
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *imageViews = [NSMutableArray array];
    
    [self.submitModel.selectedPhotos enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            YYAnimatedImageView *imageV = [[YYAnimatedImageView alloc]init];
            imageV.contentMode = UIViewContentModeScaleAspectFill;
            imageV.image = image;
            if (rectArray.count > idx) {
                NSValue *value = rectArray[idx];
                if ([value isKindOfClass:[NSValue class]]) {
                    imageV.frame = value.CGRectValue;
                }
            }
            [imageViews addObject:imageV];
            
            YYPhotoGroupItem *item = [YYPhotoGroupItem new];
            item.thumbView = imageV;
            [items addObject:item];
        }
    }];
    if (items.count>0 && imageViews.count > index) {
        YYPhotoBrowseView *browseView = [[YYPhotoBrowseView alloc] initWithGroupItems:items];
        browseView.blurEffectBackground = NO;
        [browseView presentFromImageView:imageViews[index] toContainer:self.navigationController.view animated:YES completion:nil];
    }
}

- (void)didSelectedProperty:(ZFReviewPropertyView *)propertyView
               selectedType:(ZFReviewPropertyType)type
{
    NSArray <ZFOrderSizeModel *>*sizeModelList = self.sizeArray[type];
    NSMutableArray *contentList = [[NSMutableArray alloc] init];
    [sizeModelList enumerateObjectsUsingBlock:^(ZFOrderSizeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZFOrderSizeModel *model = obj;
        [contentList addObject:model.name];
    }];
    if (contentList.count ==0 )return;
    
    [propertyView reloadSelectItemStatus:type];
    
    NSString *title = [propertyView gainTitleWithType:type];
    [ZFPickerView showPickerViewWithTitle:title pickDataArr:@[[contentList copy]] sureBlock:^(NSArray<ZFPickerViewSelectModel *> *selectContents) {
        
        ZFPickerViewSelectModel *selectModel = [selectContents firstObject];
        NSString *content = sizeModelList[selectModel.row].name;
        NSString *sizeId = sizeModelList[selectModel.row].sizeId;
        [propertyView setContent:content sizeId:sizeId withType:type];
    } cancelBlock:^{
        [propertyView reloadSelectItemStatus:type];
    }];
}

- (void)reviewBtnActionHandle:(ZFWriteReviewActionType)actionType parmater:(id)object {
    YWLog(@"reviewBtnActionHandle= %ld", actionType);
    
    if (actionType == ZFWriteReviewAction_AddImageType) {
        [self pushImagePickerController];
        
    } else if (actionType == ZFWriteReviewAction_SubmitType) {
        [self commitOrderReview];
        
    } else if (actionType == ZFWriteReviewAction_TrueSizeType
               || actionType == ZFWriteReviewAction_SmallType
               || actionType == ZFWriteReviewAction_LargeType) {
        self.submitModel.overallid = ZFToString(object).integerValue;
        
    } else if (actionType == ZFWriteReviewAction_InputReviewType) {
        self.submitModel.content = ZFToString(object);
        
    } else if (actionType == ZFWriteReviewAction_ChooseRatingType) {
        self.submitModel.avgRate = ZFToString(object).floatValue;
        
    } else if (actionType == ZFWriteReviewAction_UploadZmeType) {
        self.submitModel.sync_community = ZFToString(object).boolValue;
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.reviewScrollView];
}

- (void)zfAutoLayoutView {
    [self.reviewScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth, KScreenHeight));
    }];
}

#pragma mark - getter
- (ZFSubmitReviewViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFSubmitReviewViewModel alloc] init];
    }
    return _viewModel;
}

- (ZFOrderReviewSubmitModel *)submitModel {
    if (!_submitModel) {
        _submitModel = [[ZFOrderReviewSubmitModel alloc] init];
        _submitModel.overallid = -1;
    }
    return _submitModel;
}

-(NSMutableArray<NSArray *> *)sizeArray {
    if (!_sizeArray) {
        _sizeArray = [[NSMutableArray alloc] init];
    }
    return _sizeArray;
}

- (ZFWriteReviewScrollView *)reviewScrollView {
    if (!_reviewScrollView) {
        _reviewScrollView = [[ZFWriteReviewScrollView alloc] initWithFrame:self.view.bounds];
        _reviewScrollView.contentInset = UIEdgeInsetsMake(0, 0, kiphoneXHomeBarHeight, 0);
        _reviewScrollView.showsVerticalScrollIndicator = NO;
        _reviewScrollView.commentModel = self.commentModel;
        _reviewScrollView.hidden = YES;
        
        @weakify(self)
        _reviewScrollView.blankPageViewActionBlcok = ^(ZFBlankPageViewStatus status) {
            @strongify(self)
            [self requestOrderReviewInfoOption];
        };
        _reviewScrollView.selectedPropertyHandler = ^(ZFReviewPropertyView *view, ZFReviewPropertyType type) {
            @strongify(self)
            [self didSelectedProperty:view selectedType:type];
        };
        _reviewScrollView.reviewBtnActionBlock = ^(ZFWriteReviewActionType actionType, id object) {
            @strongify(self)
            [self reviewBtnActionHandle:actionType parmater:object];
        };
        _reviewScrollView.deleteImageActionBlock = ^(NSInteger index) {
            @strongify(self)
            [self deleteSeletedImageHandle:index];
        };
        _reviewScrollView.showAddImageActionBlock = ^(NSInteger index, NSArray *rectArray) {
            @strongify(self)
            [self openPhotosBrowseViewWithIndex:index rectArray:rectArray];
        };
    }
    return _reviewScrollView;
}

@end
