//
//  ZFPictureSearchToolView.m
//  ZZZZZ
//
//  Created by YW on 2018/9/14.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFPictureSearchToolView.h"
#import <Photos/Photos.h>
#import "LBXPermission.h"
#import "LBXPermissionSetting.h"
#import "ZFSearchAlbumCell.h"
#import "ZFSearchTakePhotoCell.h"
#import "ZFCameraButton.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFThemeManager.h"

#define kFirstShow @"kFirstShow"
@interface ZFPictureSearchToolView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/******* 没有权限时显示操作入口 *****/
@property (nonatomic, strong) UIImageView *tipImageView;
@property (nonatomic, strong) UILabel *tipLable;

@property (nonatomic, strong) UIView *containView;
@property (nonatomic, strong) ZFCameraButton *cameraButton;
@property (nonatomic, strong) ZFCameraButton *photoesButton;
@property (nonatomic, assign) BOOL isFirstShow;  /// 是否是第一次展示

/******* 有权限时显示相册列表 *****/
@property (nonatomic, strong) UICollectionView *albumCollectionView;
@property (nonatomic, assign) BOOL isPermission;  /// 是否有访问权限(相册)
@property (nonatomic, strong) NSMutableArray *imageAssets;
@property (nonatomic, assign) NSInteger imageCount;

@end

@implementation ZFPictureSearchToolView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        __block CGFloat height = 157.0;
        NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
        self.isFirstShow = [userdefaults boolForKey:kFirstShow];
        
        if (self.isPermission) {
            height = 80.0;
            self.imageCount = 0;
            self.imageAssets     = [NSMutableArray new];
            [self getImages];
        } else {
            if (!self.isFirstShow) {
                height = 157.0;
            } else {
                height = 80.0;
            }
        }
        
        height += kiphoneXHomeBarHeight;
        [userdefaults setBool:YES forKey:kFirstShow];
        [userdefaults synchronize];
        
        self.frame = CGRectMake(0.0, KScreenHeight - height, KScreenWidth, height);
        [self setupView];
        [self layout];
        [self addNotification];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.cameraButton setCamera];
        });
    }
    return self;
}

- (void)setupView {
    if (self.isPermission) {
        [self addSubview:self.containView];
        [self.containView addSubview:self.albumCollectionView];
    } else {
        if (!self.isFirstShow) {
            [self addSubview:self.tipImageView];
            [self.tipImageView addSubview:self.tipLable];
        }
        
        [self addSubview:self.containView];
        [self.containView addSubview:self.cameraButton];
        [self.containView addSubview:self.photoesButton];
    }
}

- (void)layout {
    if (self.isPermission) {
        [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.bottom.mas_equalTo(self);
        }];
        
        [self.albumCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self.containView);
            make.height.mas_equalTo(80.0);
        }];
    } else {
        if (!self.isFirstShow) {
            [self.tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading).offset(8.0f);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-8.0f);
                make.top.mas_equalTo(self.mas_top);
                make.height.mas_equalTo(77.0f);
            }];
            
            [self.tipLable mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.tipImageView.mas_leading).offset(28.0f);
                make.trailing.mas_equalTo(self.tipImageView.mas_trailing).offset(-28.0f);
                make.top.mas_equalTo(self.tipImageView.mas_top).offset(16.0f);
            }];
            
            [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self);
                make.trailing.mas_equalTo(self);
                make.top.mas_equalTo(self.tipImageView.mas_bottom).offset(0.0);
                make.bottom.mas_equalTo(self);
            }];
        } else {
            [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self);
                make.trailing.mas_equalTo(self);
                make.top.mas_equalTo(self);
                make.bottom.mas_equalTo(self);
            }];
        }
        
        CGFloat itemWidth = (KScreenWidth - 24.0) / 2;
        [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.mas_equalTo(self.containView).offset(8.0);
            make.width.mas_equalTo(itemWidth);
            make.height.mas_offset(64.0);
        }];
        
        [self.photoesButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containView).offset(8.0);
            make.trailing.mas_equalTo(self.containView).offset(-8.0);
            make.width.mas_equalTo(itemWidth);
            make.height.mas_offset(64.0);
        }];
        [self layoutIfNeeded];
        [self setButtonStyle:self.cameraButton];
        [self setButtonStyle:self.photoesButton];
    }
}

#pragma mark - event
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)note {
    //获取键盘的高度
    NSDictionary *userInfo = [note userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    if (!self.isFirstShow
        && !self.isPermission) {
        self.height = 157.0;
    } else {
        self.height = 80.0;
    }
    [UIView animateWithDuration:0.35 animations:^{
        self.y = KScreenHeight - self.height - keyboardRect.size.height;
    }];
}

- (void)keyboardWillhidden:(NSNotification *)note {
    if (!self.isFirstShow
        && !self.isPermission) {
        self.height = 157.0 + kiphoneXHomeBarHeight;
    } else {
        self.height = 80.0 + kiphoneXHomeBarHeight;
    }
    [UIView animateWithDuration:0.35 animations:^{
        self.y = KScreenHeight - self.height;
    }];
}

- (void)cameraAction {
    if (self.takePhotosHandle) {
        self.takePhotosHandle();
        [self hiddenTip];
        [self.albumCollectionView reloadData];
    }
}

- (void)photosAction {
    if (self.getPhotosHandle) {
        self.getPhotosHandle();
        [self hiddenTip];
    }
}

- (void)hiddenTip {
    if (!self.isFirstShow) {
        [self.tipImageView removeFromSuperview];
        self.height      = 80.0 + kiphoneXHomeBarHeight;
        self.isFirstShow = YES;
        self.y = KScreenHeight - self.height;
        [self.containView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self);
            make.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self);
            make.bottom.mas_equalTo(self);
        }];
    }
}

- (void)changeContainView {
    BOOL isListView = NO;
    for (id subView in self.containView.subviews) {
        if (subView == self.containView) {
            isListView = YES;
            break;
        }
    }
    
    if (!isListView && self.imageAssets.count <= 0) {
        [self.tipImageView removeFromSuperview];
        [self.cameraButton removeFromSuperview];
        [self.photoesButton removeFromSuperview];
        [self.containView addSubview:self.albumCollectionView];
        [self.containView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.bottom.mas_equalTo(self);
        }];
        
        [self.albumCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self.containView);
            make.height.mas_equalTo(80.0);
        }];
        
        self.imageCount = 0;
        self.imageAssets  = [NSMutableArray new];
        [self getImages];
    }
}

#pragma mark: ************************************获取相册中的照片************************************
/**
 *  获得所有相簿的原图
 */
- (void)getImages {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc]init];
    //ascending为NO，即为逆序(由现在到过去)， ascending为YES时即为默认排序，由远到近
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    fetchOptions.sortDescriptors = @[sort];
    
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:fetchOptions];
    
    // 遍历所有的自定义相簿
    for (PHAsset *asset in assetsFetchResults) {
        [self.imageAssets addObject:asset];
        if (self.imageAssets.count >= 20) {
            [self.albumCollectionView reloadData];
            break;
        }
    }
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    
    PHCachingImageManager *cachingImageManager = [[PHCachingImageManager alloc] init];
    [cachingImageManager startCachingImagesForAssets:self.imageAssets targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options];
    
    [cachingImageManager startCachingImagesForAssets:self.imageAssets targetSize:CGSizeMake(64.0, 64.0) contentMode:PHImageContentModeAspectFit options:options];
}


#pragma mark - UICollectionViewDataSource/UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = self.imageAssets.count > 20 ? 20 : self.imageAssets.count;
    count += 2;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFSearchAlbumCell *cell = [ZFSearchAlbumCell searchAlbumCell:collectionView indexPath:indexPath];
    ZFPhotoCellType type = ZFPhotoCellTypeImage;
    NSInteger itemCount = self.imageAssets.count > 20 ? 20 : self.imageAssets.count;
    UIImage *image = [[UIImage alloc] init];
    if (indexPath.item == 0) {
        ZFSearchTakePhotoCell *cell = [ZFSearchTakePhotoCell searchAlbumCell:collectionView indexPath:indexPath];
        return cell;
    } else if (indexPath.item == itemCount + 1) {
        type = ZFPhotoCellTypeMore;
        image = [UIImage imageNamed:@"search_tool_photo"];
    } else {
        PHAsset *asset = [self.imageAssets objectAtIndex:indexPath.row - 1];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        // 同步获得图片, 只会返回1张图片
        options.synchronous = NO;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(64.0, 64.0)  contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ZFPhotoCellType type = ZFPhotoCellTypeImage;
                    [cell configWithImage:result type:type];
                });
            }
        }];
    }
    [cell configWithImage:image type:type];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        if (self.takePhotosHandle) {
            self.takePhotosHandle();
        }
    } else if (self.imageAssets.count + 1 == indexPath.item) {
        if (self.getPhotosHandle) {
            self.getPhotosHandle();
        }
    } else {
        PHAsset *asset = [self.imageAssets objectAtIndex:indexPath.row - 1];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        // 同步获得图片, 只会返回1张图片
        options.synchronous = YES;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize  contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.selectedPhotoHandle) {
                        self.selectedPhotoHandle(result);
                    }
                });
            }
        }];
    }
}

#pragma mark - getter/setter
- (UIImageView *)tipImageView {
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] init];
        _tipImageView.layer.cornerRadius = 4;
        _tipImageView.layer.masksToBounds = YES;
        UIImage *image = [UIImage imageNamed:@"search_tool_tipwindows"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 5.0, 15.0, 5.0) resizingMode:UIImageResizingModeStretch];
        _tipImageView.image = image;
    }
    return _tipImageView;
}

- (UILabel *)tipLable {
    if (!_tipLable) {
        _tipLable = [[UILabel alloc] init];
        _tipLable.font          = [UIFont boldSystemFontOfSize:14.0];
        _tipLable.textAlignment = NSTextAlignmentCenter;
        _tipLable.numberOfLines = 0;
        _tipLable.textColor     = [UIColor colorWithHex:0x2d2d2d];
        _tipLable.text = ZFLocalizedString(@"Search_Tool_tip", nil);
    }
    return _tipLable;
}

- (UIView *)containView {
    if (!_containView) {
        _containView = [[UIView alloc] init];
        _containView.backgroundColor = ZFC0xF2F2F2();
    }
    return _containView;
}

- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [self addButton];
        [_cameraButton setImage:[UIImage imageNamed:@"search_tool_camera"] forState:UIControlStateNormal];
        [_cameraButton setTitle:ZFLocalizedString(@"Search_Tool_Camera", nil) forState:UIControlStateNormal];
        [_cameraButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (UIButton *)photoesButton {
    if (!_photoesButton) {
        _photoesButton = [self addButton];
        [_photoesButton setImage:[UIImage imageNamed:@"search_tool_photo"] forState:UIControlStateNormal];
        [_photoesButton setTitle:ZFLocalizedString(@"Search_Tool_Photos", nil) forState:UIControlStateNormal];
        [_photoesButton addTarget:self action:@selector(photosAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoesButton;
}

- (ZFCameraButton *)addButton {
    ZFCameraButton *btn = [ZFCameraButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor colorWithHex:0x2d2d2d];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    btn.layer.cornerRadius = 2;
    btn.layer.masksToBounds = YES;
    
    return btn;
}

- (void)setButtonStyle:(UIButton *)btn {
    CGFloat imgW = btn.imageView.frame.size.width;
    CGFloat imgH = btn.imageView.frame.size.height;
    CGFloat lblW = btn.titleLabel.frame.size.width;
    CGFloat lblH = btn.titleLabel.frame.size.height;
    // 设置图片和文字的间距，这里可自行调整
    CGFloat margin = 2;
    
    btn.imageEdgeInsets = UIEdgeInsetsMake(-lblH-margin/2, 0, 0, -lblW);
    btn.titleEdgeInsets = UIEdgeInsetsMake(imgH+margin/2, -imgW, 0, 0);
}

/*********** 我是分割线 ***********/
- (UICollectionView *)albumCollectionView {
    if (!_albumCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection             = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset                = UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0);
        layout.minimumInteritemSpacing     = 8.0;
        
        CGFloat imgHeight  = 80.0 - 16.0;
        layout.itemSize    = CGSizeMake(imgHeight, imgHeight);
        
        _albumCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _albumCollectionView.showsVerticalScrollIndicator   = NO;
        _albumCollectionView.showsHorizontalScrollIndicator = NO;
        _albumCollectionView.alwaysBounceHorizontal         = YES;
        _albumCollectionView.delegate                       = self;
        _albumCollectionView.dataSource                     = self;
        _albumCollectionView.backgroundColor                = [UIColor clearColor];
    }
    return _albumCollectionView;
}

- (BOOL)isPermission {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        _isPermission = YES;
    } else {
        _isPermission = NO;
    }
    return _isPermission;
}

@end
