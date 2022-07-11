//
//  YXReturnbackPictureView.m
//  uSmartOversea
//
//  Created by Kelvin on 2018/8/15.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXReturnbackPictureView.h"
#import "TZImagePickerController.h"
#import "UIImage+Compress.h"
#import "uSmartOversea-Swift.h"
#import <QMUIKit/QMUIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "XLPhotoBrowser.h"
#import <QMUIKit/QMUIKit.h>
#import <Masonry/Masonry.h>
#import <QCloudCore/QCloudCore.h>
#import "UIViewController+Current.h"

#import <AVFoundation/AVFoundation.h>

#define kYXMaxImageCount 5

@interface YXReturnbackPictureView () <TZImagePickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *imageViewArr; //存储图片image
@property (nonatomic, strong) NSMutableArray *deleteButtonArr; //删除
@property (nonatomic, strong) NSMutableArray *imageArr; //图片数组
@property (nonatomic, strong) NSMutableArray *imgLocationUrlArr; //图片本地临时缓存图片
@property (nonatomic, strong) UIImageView *currentImageView;//当前的图片


@end

@implementation YXReturnbackPictureView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    
    self.backgroundColor = QMUITheme.foregroundColor;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width-74)/4;
    
    for (int x = 0; x < 5; x ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feedback_add_pic"]];
        if (x == 0) {
            self.currentImageView = imageView;
        }
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (x == 4) {
                make.left.equalTo(self.mas_left).offset(15);
                make.top.equalTo(self.mas_top).offset(width + 15);
                make.width.height.mas_equalTo(width);
            }else{
                make.left.mas_equalTo(15 + (15 + width) * x);
                make.top.mas_equalTo(self.mas_top);
                make.width.height.mas_equalTo(width);
            }
        }];
        [self.imageViewArr addObject:imageView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapGest:)];
        [imageView addGestureRecognizer:tapGesture];
        if (x >= 1) {
            imageView.hidden = YES;
        }

        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setImage:[UIImage imageNamed:@"user_delPic"] forState: UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteButton];
        [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(imageView.mas_right).offset(-3);
            make.centerY.equalTo(imageView.mas_top).offset(3);
            make.width.height.mas_equalTo(20);
        }];
        [self.deleteButtonArr addObject:deleteButton];
        deleteButton.hidden = YES;
    }
}

#pragma mark - event
- (void)deleteButtonEvent:(UIButton *)button{
    
    NSInteger index = [self.deleteButtonArr indexOfObject:button];
    if (index == 4) { //最后一张图片(此时5张都有图片内容)
        UIImageView *lastImageView = self.imageViewArr.lastObject;
        lastImageView.image = [UIImage imageNamed:@"feedback_add_pic"];
        UIButton *lastDeleteButton = self.deleteButtonArr.lastObject;
        lastDeleteButton.hidden = YES;
    } else {  //不是最后一张的图片
        for (NSInteger x = index; x <= 3; x++) {
            
            UIImageView *imageView = self.imageViewArr[x];
            UIImageView *nextImageView = self.imageViewArr[x + 1];
            imageView.image = nextImageView.image;
            imageView.hidden = nextImageView.hidden;
            UIButton *button = self.deleteButtonArr[x];
            UIButton *nextButton = self.deleteButtonArr[x + 1];
            button.hidden = nextButton.hidden;
        }
        UIImageView *lastImageView = self.imageViewArr.lastObject;
        
        UIButton *lastDeleteButton = self.deleteButtonArr.lastObject;
        if (lastDeleteButton.hidden) {
            lastImageView.hidden = YES;
            if (self.isExpandBlock) {
                self.isExpandBlock(0);
            }
        }else{
            lastImageView.hidden = NO;
            lastImageView.image = [UIImage imageNamed:@"feedback_add_pic"];
            lastDeleteButton.hidden = YES;
            if (self.isExpandBlock) {
                self.isExpandBlock(1);
            }
        }
    }
    
    [self.imageArr removeObjectAtIndex:index];
    [self.imgLocationUrlArr removeObjectAtIndex:index];
    self.currentImageView = self.imageViewArr[self.imageArr.count];
}

- (void)imageTapGest:(UITapGestureRecognizer *)tap{
    
    UIImageView *imageView = (UIImageView *)tap.view;
    NSInteger index = [self.imageViewArr indexOfObject:imageView];
    if (self.imageArr.count == index) {
        //弹框
        QMUIAlertController *alertController = [[QMUIAlertController alloc] initWithTitle:nil message:nil preferredStyle:QMUIAlertControllerStyleActionSheet];
        
        @weakify(self, alertController)
        UIButton *albumButton = [self creatButtonWithTitle:[YXLanguageUtility kLangWithKey:@"mine_userDataAlbum"]];
        albumButton.frame = CGRectMake(0, 0, YXConstant.screenWidth, 54);
        albumButton.layer.maskedCorners = QMUILayerMinXMinYCorner | QMUILayerMaxXMinYCorner;
        albumButton.layer.cornerRadius = 16;
        albumButton.layer.masksToBounds = YES;
        [[[albumButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:alertController.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self, alertController)
            [alertController hideWithAnimated:NO];
            [self showImageLibrary];

        }];

        UIButton *cameraButton = [self creatButtonWithTitle:[YXLanguageUtility kLangWithKey:@"mine_camera"]];
        cameraButton.frame = CGRectMake(0, 54, YXConstant.screenWidth, 54);
        [[[cameraButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:alertController.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self, alertController)
            [alertController hideWithAnimated:NO];
            [YXToolUtility checkCameraPermissionsWith:nil closure:^{
                [self showCamera];
            }];
        }];

        UIButton *cancelButton = [self creatButtonWithTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"]];
        cancelButton.frame = CGRectMake(0, 116, YXConstant.screenWidth, 54);
        [[[cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:alertController.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(alertController)
            [alertController hideWithAnimated:YES];
        }];
        
        
        UIView *line = [UIView lineView];
        line.backgroundColor = QMUITheme.popSeparatorLineColor;
        line.frame = CGRectMake(0, 54, YXConstant.screenWidth, 0.5);

        UIView *greyView = [[UIView alloc] init];
        greyView.backgroundColor = QMUITheme.blockColor;
        greyView.frame = CGRectMake(0, 108, YXConstant.screenWidth, 8);

        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 170)];

        [containerView addSubview:albumButton];
        [containerView addSubview:cameraButton];
        [containerView addSubview:cancelButton];
        [containerView addSubview:line];
        [containerView addSubview:greyView];

        [alertController addCustomView:containerView];
        alertController.sheetCancelButtonMarginTop = 0;
        alertController.sheetButtonBackgroundColor = [QMUITheme popupLayerColor];
        alertController.sheetHeaderBackgroundColor = [UIColor clearColor];
        alertController.isExtendBottomLayout = YES;
        [alertController showWithAnimated:YES];

    }else{
        //预览照片
        [self PreviewImageWithIndex:index];
    }
}

- (UIButton *)creatButtonWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [QMUITheme popupLayerColor];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:QMUITheme.textColorLevel1 forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

- (void)showCamera {
    // 创建UIImagePickerController实例
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    // 设置代理
    imagePickerController.delegate = self;
    // 设置照片来源为相机
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    // 设置进入相机时使用前置或后置摄像头
    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    UIViewController *vc = [UIViewController currentViewController];
    [vc presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
// 完成图片的选取后调用的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 选取完图片后跳转回原控制器
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //临时保存路径
        UIImage *compressImage = [image compressImageQualityWithMaxLength:3072 * 1000];
        NSString* tempPath = QCloudTempFilePathWithExtension(@"png");
        [UIImagePNGRepresentation(compressImage) writeToFile:tempPath atomically:YES];
        [self.imgLocationUrlArr addObject:tempPath];
    });
    [self didSelectedImage:image];
    [self.imageArr addObject:image];
    [picker dismissViewControllerAnimated:YES completion:nil];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//预览图片
- (void)PreviewImageWithIndex:(NSInteger)index{
    
    [XLPhotoBrowser showPhotoBrowserWithImages:self.imageArr currentImageIndex:index];
    
}

//展示照片选择
- (void)showImageLibrary{    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:kYXMaxImageCount - self.imageArr.count delegate:nil];
    imagePickerVc.preferredLanguage = YXLanguageUtility.identifier;
    imagePickerVc.naviTitleColor = QMUITheme.textColorLevel1;
    imagePickerVc.barItemTextColor = QMUITheme.textColorLevel1;
    imagePickerVc.iconThemeColor = QMUITheme.themeTextColor;
    imagePickerVc.naviBgColor = QMUITheme.foregroundColor;
    imagePickerVc.navLeftBarButtonSettingBlock = ^(UIButton *leftButton) {
        
        [leftButton setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -32, 0, 0)];
    };
    imagePickerVc.sortAscendingByModificationDate = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.showSelectedIndex = YES;
    
    imagePickerVc.oKButtonTitleColorNormal = QMUITheme.themeTextColor;
    imagePickerVc.oKButtonTitleColorDisabled = [[QMUITheme themeTextColor] colorWithAlphaComponent:0.5];
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {

        for (UIImage *image in photos) {
            
            UIImage *compressImage = [image compressImageQualityWithMaxLength:3072 * 1000];
            //临时保存路径
            NSString* tempPath = QCloudTempFilePathWithExtension(@"png");
            [UIImagePNGRepresentation(compressImage) writeToFile:tempPath atomically:YES];
           
            [self.imgLocationUrlArr addObject:tempPath];
            [self didSelectedImage:image];
            [self.imageArr addObject:image];
        }
    }];
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    UIViewController *vc = [UIViewController currentViewController];
    [vc presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - lazy load

- (NSMutableArray *)imageArr{
    
    if (!_imageArr) {
        _imageArr = [NSMutableArray array];
    }
    return _imageArr;
}

- (NSMutableArray *)deleteButtonArr{
    
    if (!_deleteButtonArr) {
        _deleteButtonArr = [NSMutableArray array];
    }
    return _deleteButtonArr;
    
}

- (NSMutableArray *)imageViewArr{
    
    if (!_imageViewArr) {
        _imageViewArr = [NSMutableArray array];
    }
    return _imageViewArr;
    
}

- (NSMutableArray *)imgLocationUrlArr{
    
    if (!_imgLocationUrlArr) {
        _imgLocationUrlArr = [[NSMutableArray alloc] init];
    }
    return _imgLocationUrlArr;
}

#pragma mark- other
//选择了图片
- (void)didSelectedImage:(UIImage *)image {
    
    //幅值
    self.currentImageView.image = image;
    NSInteger index = [self.imageViewArr indexOfObject:self.currentImageView];
    //展示下一页
    if (index <= 3) {
        UIImageView *imageView = self.imageViewArr[index + 1];
        imageView.hidden = NO;
    }

    //显示删除按钮
    UIButton *clearButton = self.deleteButtonArr[index];
    clearButton.hidden = NO;

    //展示两行
    if (index == 3) {
        if (self.isExpandBlock) {
            self.isExpandBlock(1);
        }
    }
    
    if (index<4) {
        self.currentImageView = self.imageViewArr[index + 1];
    }
}

@end
