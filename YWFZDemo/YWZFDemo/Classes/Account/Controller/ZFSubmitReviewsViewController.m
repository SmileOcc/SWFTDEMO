

//
//  ZFSubmitReviewsViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSubmitReviewsViewController.h"
#import "TZImagePickerController.h"
#import "ZFWebViewViewController.h"

#import "ZFInitViewProtocol.h"
#import "ZFSubmitReviewCheckHeaderView.h"
#import "ZFSubmitReviewCheckTableViewCell.h"
#import "ZFSubmitReviewCheckFooterView.h"
#import "ZFSubmitReviewWriteHeaderView.h"
#import "ZFSubmitReviewWriteTableViewCell.h"
#import "ZFSubmitReviewWriteFooterView.h"
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
#import "ZFSubmitReviewTableHeadView.h"
#import "ZFPickerView.h"
#import "ZFOrderReviewListModel.h"
#import "YWCFunctionTool.h"

static NSString *const kZFSubmitReviewCheckHeaderViewIdentifier = @"kZFSubmitReviewCheckHeaderViewIdentifier";
static NSString *const kZFSubmitReviewCheckTableViewCellIdentifier = @"kZFSubmitReviewCheckTableViewCellIdentifier";
static NSString *const kZFSubmitReviewCheckFooterViewIdentifier = @"kZFSubmitReviewCheckFooterViewIdentifier";
static NSString *const kZFSubmitReviewWriteHeaderViewIdentifier = @"kZFSubmitReviewWriteHeaderViewIdentifier";
static NSString *const kZFSubmitReviewWriteTableViewCellIdentifier = @"kZFSubmitReviewWriteTableViewCellIdentifier";
static NSString *const kZFSubmitReviewWriteFooterViewIdentifier = @"kZFSubmitReviewWriteFooterViewIdentifier";


@interface ZFSubmitReviewsViewController () <ZFInitViewProtocol, UITableViewDelegate, UITableViewDataSource, TZImagePickerControllerDelegate> {
    NSInteger           _currentSelectPhotoIndex;
}

@property (nonatomic, strong) YYPhotoBrowseView                             *browseView;
@property (nonatomic, strong) UITableView                                   *tableView;
@property (nonatomic, strong) ZFSubmitReviewTableHeadView                   *tableHeaderView;
@property (nonatomic, strong) NSMutableArray                                *imageViews;
@property (nonatomic, strong) NSMutableArray                                *addImagesArray;
@property (nonatomic, strong) NSMutableArray<YYPhotoGroupItem *>            *items;
@property (nonatomic, strong) ZFSubmitReviewViewModel                       *viewModel;
@property (nonatomic, strong) NSMutableArray<ZFOrderReviewModel *>          *dataArray;
@property (nonatomic, strong) NSMutableArray<ZFOrderReviewSubmitModel *>    *submitManager;
@property (nonatomic, strong) NSMutableArray<NSArray *>                     *sizeArray;
@property (nonatomic, strong) NSMutableDictionary                           *sizeidParams;
@end

@implementation ZFSubmitReviewsViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self zfInitView];
    [self zfAutoLayoutView];
}

#pragma mark - action methods
- (void)openPhotosBrowseViewWithSection:(NSInteger)section andIndex:(NSInteger)index{
    [self.items removeAllObjects];
    [self.imageViews removeAllObjects];
    [self.dataArray[section].reviewList.firstObject.reviewPic enumerateObjectsUsingBlock:^(ZFOrderReviewImageInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            YYAnimatedImageView *imageV = [[YYAnimatedImageView alloc]init];
            imageV.contentMode = UIViewContentModeScaleAspectFill;
            imageV.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
            NSString *imageurl = [NSString stringWithFormat:@"%@%@", self.dataArray[section].review_img_domain, obj.origin_pic];
            [imageV yy_setImageWithURL:[NSURL URLWithString:imageurl]
                          placeholder:[UIImage imageNamed:@"loading_product"]
                               options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                              progress:nil
                             transform:nil
                            completion:nil];
            [self.imageViews addObject:imageV];
            YYPhotoGroupItem *item = [YYPhotoGroupItem new];
            item.thumbView = imageV;
            NSURL *url = [NSURL URLWithString:imageurl];
            item.largeImageURL = url;
            [self.items addObject:item];
        }
    }];
    
    self.browseView = [[YYPhotoBrowseView alloc]initWithGroupItems:self.items];
    self.browseView.blurEffectBackground = NO;
    [self.browseView presentFromImageView:self.imageViews[index] toContainer:self.navigationController.view animated:YES completion:nil];
}

- (void)pushImagePickerController {
    TZImagePickerController *customImagePickerController = [[TZImagePickerController alloc] initWithMaxImagesCount:3 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    customImagePickerController.isSelectOriginalPhoto = YES;
    // 1.设置目前已经选中的图片数组
    customImagePickerController.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
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

- (void)goBackAction
{
    //判断是否有没有评论的商品，如果有，提示弹框，否则 直接返回上一级页面
    BOOL needToReview = NO;
    
    for (int i = 0; i < self.dataArray.count; ++i) {
        ZFOrderReviewModel *model = self.dataArray[i];
        if ([model.is_write integerValue]) {
            needToReview = YES;
            break;
        }
    }
    
    if (!needToReview) {
        [self.navigationController popViewControllerAnimated:YES];
        return ;
    }

    NSString *message = ZFLocalizedString(@"ZFOrderReview_Tips",nil);
    NSString *conitnueTitle = ZFLocalizedString(@"Post_VC_Post_Cancel_No",nil);
    NSString *exitTitle = ZFLocalizedString(@"Post_VC_Post_Cancel_Yes",nil);
    
    ShowAlertView(nil, message, @[conitnueTitle], ^(NSInteger buttonIndex, id buttonTitle) {
        [self.navigationController popViewControllerAnimated:YES];
    }, exitTitle, nil);
}

#pragma mark - private methods
- (void)requestOrderReviewInfoOption {
    
    NSDictionary *dic = @{@"order_id":ZFToString(self.orderId),@"goods_id":ZFToString(self.goodsId)};
    @weakify(self);
    [self.viewModel requestOrderReviewListNetwork:dic completion:^(id obj) {
        @strongify(self);
        ZFOrderReviewListModel *model = obj;
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
        BOOL showTableHeaderView = NO;
        for (int i = 0; i < self.dataArray.count; ++i) {
            ZFOrderReviewModel *model = self.dataArray[i];
            if ([model.is_write integerValue]) {
                showTableHeaderView = YES;
                break;
            }
        }

        [self.tableView reloadData];
        
        //init photo manager
        [self.submitManager removeAllObjects];
        for (int i = 0; i < self.dataArray.count; ++i) {
            ZFOrderReviewSubmitModel *model = [[ZFOrderReviewSubmitModel alloc] init];
            [self.submitManager addObject:model];
        }
        self.tableView.mj_header.hidden = YES;
        [self.tableView showRequestTip:@{}];
        if (showTableHeaderView) {
            self.tableView.tableHeaderView = self.tableHeaderView;
        }
    } failure:^(id obj) {
        @strongify(self);
        [self.tableView reloadData];
        [self.tableView showRequestTip:nil];
    }];
}

- (void)submitOrderReviewWithSection:(NSInteger)section {
    
    if (self.submitManager[section].content.length < 30) {
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"WriteReview_Textfiled_Min_Tip",nil));
        return;
    }
    if (self.dataArray[section].overallid == -1) {
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"OverallFit_Required", nil));
        return;
    }
    
    if (self.submitManager[section].avgRate <= 0.1) {
        self.submitManager[section].avgRate = 5.0f;
    }
    //包装评论数据，图片压缩等
    NSDictionary *dict = @{
                           @"title" : self.dataArray[section].goods_info.goods_title ?: @"",
                           @"goods_id" : self.dataArray[section].goods_info.goods_id,
                           @"content" : self.submitManager[section].content,
                           @"rate_overall" : @(self.submitManager[section].avgRate),
                           @"order_id": self.orderId,
                           @"images" :[self compressPhotoWithSection:section],
                           @"sync_community" : @(!self.submitManager[section].sync_community),
                           @"attr_strs" : ZFToString(self.dataArray[section].goods_info.attr_strs),
                           kLoadingView : self.view
                           };
    
    NSMutableDictionary *params = [dict mutableCopy];
    [params addEntriesFromDictionary:[self.tableHeaderView selectBodySize]];
    [params setObject:@(self.dataArray[section].overallid) forKey:@"overall_fit"];
    @weakify(self)
    [self.viewModel requestWriteReview:params completion:^(id obj) {
        @strongify(self)
        ZFWriteReviewResultModel *model = obj;
        if (![model isKindOfClass:[ZFWriteReviewResultModel class]]) return ;
        
        self.dataArray[section].reviewList = @[model.review];
        self.dataArray[section].is_write = @"0";
        BOOL hiddenTableHeader = YES;
        for (int i = 0; i < [self.dataArray count]; i++) {
            if (self.dataArray[i].is_write.boolValue) {
                hiddenTableHeader = NO;
            }
        }
        if (hiddenTableHeader) {
            UIView *temView = [[UIView alloc] init];
            temView.frame = CGRectMake(0, 0, 0, 1);
            self.tableView.tableHeaderView = temView;
        }
        self.submitManager[section].selectedPhotos = [NSMutableArray array];
        self.submitManager[section].selectedAssets = [NSMutableArray array];
        NSIndexSet *indexSec = [[NSIndexSet alloc] initWithIndex:section];
        [self.tableView reloadSections:indexSec withRowAnimation:UITableViewRowAnimationFade];
        if (model.is_show_popup) {
            [self showAppStoreCommentWithContactUs:model.contact_us];
        }
    } failure:^(id obj) {
        //提示评论失败
    }];
}

#pragma mark - 压缩图片方法
- (NSMutableArray *)compressPhotoWithSection:(NSInteger)section {
    
    NSMutableArray *imageArray = [NSMutableArray array];
    if (self.submitManager[section].selectedPhotos.count <= 0) {
        return imageArray;
    }
    
    [self.submitManager[section].selectedPhotos enumerateObjectsUsingBlock:^(UIImage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController  *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    if (self.submitManager[self->_currentSelectPhotoIndex].selectedPhotos.count == 0 && photos.count > 0) {
        self.submitManager[self->_currentSelectPhotoIndex].sync_community = 0;
    }
    self.submitManager[self->_currentSelectPhotoIndex].selectedAssets = _selectedAssets;
    self.submitManager[self->_currentSelectPhotoIndex].selectedPhotos = _selectedPhotos;
    
    //页面刷新
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFOrderReviewModel *model = self.dataArray[indexPath.section];
    if (![model.is_write boolValue]) {  //查看评论
        ZFSubmitReviewCheckTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFSubmitReviewCheckTableViewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = model;
        return cell;
    } else {    //提交评论
        ZFSubmitReviewWriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFSubmitReviewWriteTableViewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = model;
        if (self.submitManager[indexPath.section].content.length > 0) {
            cell.editInfo = self.submitManager[indexPath.section];
        }
        @weakify(self);
        cell.submitReviewWriteContentCompletionHandler = ^(NSString *content) {
            @strongify(self);
            self.submitManager[indexPath.section].content = content;
        };
        cell.submitReviewSelectOverallFitHandler = ^(NSInteger index) {
            @strongify(self)
            self.dataArray[indexPath.section].overallid = index;
        };
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 144;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    ZFOrderReviewModel *model = self.dataArray[section];
    if (![model.is_write boolValue]) {
        if (model.reviewList.firstObject.reviewPic.count <= 0) {
            return CGFLOAT_MIN;
        } else {
            return 92;
        }
    }
    return 185 + (self.selectedPhotos.count > 0 ? 48 : 0);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ZFOrderReviewModel *model = self.dataArray[section];
    if (![model.is_write boolValue]) {  //查看评论
        ZFSubmitReviewCheckHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kZFSubmitReviewCheckHeaderViewIdentifier];
        headerView.model = model;
        return headerView;
    } else {    //提交评论
        ZFSubmitReviewWriteHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kZFSubmitReviewWriteHeaderViewIdentifier];
        headerView.model = model;
        @weakify(self);
        headerView.submitReviewWriteRatingCompletionHandler = ^(CGFloat rate) {
            @strongify(self);
            self.submitManager[section].avgRate = rate;
            model.userSelectStartCount = rate;
        };
        return headerView;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ZFOrderReviewModel *model = self.dataArray[section];
    if (![model.is_write boolValue]) {  //查看评论
        ZFSubmitReviewCheckFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kZFSubmitReviewCheckFooterViewIdentifier];
        footerView.model = model;
        @weakify(self);
        footerView.submitReviewCheckImageCompletionHandler  = ^(NSInteger index) {
            @strongify(self);
            [self openPhotosBrowseViewWithSection:section andIndex:index];
        };
        return footerView;
    } else {    //提交评论
        ZFSubmitReviewWriteFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kZFSubmitReviewWriteFooterViewIdentifier];
        footerView.syncCommunity = self.submitManager[section].sync_community;
        footerView.photosArray = self.submitManager[section].selectedPhotos;
        @weakify(self);
        footerView.submitReviewSubmitCompletionHandler = ^{
            @strongify(self);
            [self.view endEditing:YES];
            [self submitOrderReviewWithSection:section];
        };
        footerView.submitReviewChoosePhotosCompletionHandler = ^{
            @strongify(self);
            self->_currentSelectPhotoIndex = section;
            [self pushImagePickerController];
        };

        footerView.submitReviewSyncCommunityCompletionHandler = ^(BOOL isSync) {
            @strongify(self);
            self.submitManager[section].sync_community = !isSync;
        };
        
        footerView.submitReviewDeletePhotoCompletionHandler = ^(NSInteger index) {
            @strongify(self);
            [self.selectedPhotos removeObjectAtIndex:index];
            [self.selectedAssets removeObjectAtIndex:index];
            [self.tableView reloadData];
        };
        return footerView;
    }
    return nil;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self.view endEditing:YES];
//}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    [self configNavigationBar];
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, kiphoneXHomeBarHeight, 0));
    }];
}

- (void)configNavigationBar {
    self.title = ZFLocalizedString(@"TopicDetailView_Reviews", nil);
}

#pragma mark - setter
- (void)setOrderId:(NSString *)orderId {
    _orderId = orderId;
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - getter
- (ZFSubmitReviewViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFSubmitReviewViewModel alloc] init];
    }
    return _viewModel;
}

- (NSMutableArray<YYPhotoGroupItem *> *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

- (NSMutableArray<ZFOrderReviewSubmitModel *> *)submitManager {
    if (!_submitManager) {
        _submitManager = [NSMutableArray array];
    }
    return _submitManager;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = ZFCOLOR_WHITE;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 200;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[ZFSubmitReviewCheckHeaderView class] forHeaderFooterViewReuseIdentifier:kZFSubmitReviewCheckHeaderViewIdentifier];
        [_tableView registerClass:[ZFSubmitReviewCheckTableViewCell class] forCellReuseIdentifier:kZFSubmitReviewCheckTableViewCellIdentifier];
        [_tableView registerClass:[ZFSubmitReviewCheckFooterView class] forHeaderFooterViewReuseIdentifier:kZFSubmitReviewCheckFooterViewIdentifier];
        [_tableView registerClass:[ZFSubmitReviewWriteHeaderView class] forHeaderFooterViewReuseIdentifier:kZFSubmitReviewWriteHeaderViewIdentifier];
        [_tableView registerClass:[ZFSubmitReviewWriteTableViewCell class] forCellReuseIdentifier:kZFSubmitReviewWriteTableViewCellIdentifier];
        [_tableView registerClass:[ZFSubmitReviewWriteFooterView class] forHeaderFooterViewReuseIdentifier:kZFSubmitReviewWriteFooterViewIdentifier];
        
        @weakify(self);
        ZFRefreshHeader *header = [ZFRefreshHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self requestOrderReviewInfoOption];
        }];
        [_tableView setMj_header:header];
    }
    return _tableView;
}

-(ZFSubmitReviewTableHeadView *)tableHeaderView
{
    if (!_tableHeaderView) {
        _tableHeaderView = ({
            ZFSubmitReviewTableHeadView *headerView = [[ZFSubmitReviewTableHeadView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 198)];
            [headerView setDefaultValue:self.sizeArray];
            @weakify(self)
            headerView.didClickPropertyHandler = ^(ZFSubmitReviewTableHeadView *view, UserPropertyType type) {
                @strongify(self)
                NSArray <ZFOrderSizeModel *>*sizeModelList = self.sizeArray[type];
                NSMutableArray *contentList = [[NSMutableArray alloc] init];
                [sizeModelList enumerateObjectsUsingBlock:^(ZFOrderSizeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    ZFOrderSizeModel *model = obj;
                    [contentList addObject:model.name];
                }];
                if (![contentList count]) {
                    return;
                }
                [view reloadSelectItemStatus:type];
                NSString *title = [view gainTitleWithType:type];
                [ZFPickerView showPickerViewWithTitle:title pickDataArr:@[[contentList copy]] sureBlock:^(NSArray<ZFPickerViewSelectModel *> *selectContents) {
                    ZFPickerViewSelectModel *selectModel = [selectContents firstObject];
                    NSString *content = sizeModelList[selectModel.row].name;
                    NSString *sizeId = sizeModelList[selectModel.row].sizeId;
                    [view setContent:content sizeId:sizeId withType:type];
                } cancelBlock:^{
                    [view reloadSelectItemStatus:type];
                }];
            };
            headerView;
        });
    }
    return _tableHeaderView;
}

-(NSMutableArray<NSArray *> *)sizeArray
{
    if (!_sizeArray) {
        _sizeArray = [[NSMutableArray alloc] init];
    }
    return _sizeArray;
}

@end
