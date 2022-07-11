//
//  OSSVWritesReviewsVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVWritesReviewsVC.h"
#import "ZZStarView.h"
#import "PhotoBroswerVC.h"
#import "PlacehoderTextView.h"
//#import <AssetsLibrary/AssetsLibrary.h>
#import "QBImagePickerController.h"
#import "OSSVWriteeRevieweViewModel.h"
//#import "MF_Base64Additions.h"
//#import <ImageIO/ImageIO.h>
#import "UIImage+STLCategory.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Adorawe-Swift.h"

@interface OSSVWritesReviewsVC ()
<
UITextViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
QBImagePickerControllerDelegate
>

@property (nonatomic, strong) UIScrollView              *scrollerView;
// upView
@property (nonatomic, strong) UIView                    *upBackView;
@property (nonatomic, strong) YYAnimatedImageView       *picImageView;
@property (nonatomic, strong) UILabel                   *ratingNameLabel;
@property (nonatomic, strong) ZZStarView         *starControl;
// textView
@property (nonatomic, strong) PlacehoderTextView        *reviewTextView;
@property (nonatomic, strong) UILabel                   *textCountLab;
@property (nonatomic, strong) UIView                    *pictureView;
@property (nonatomic, strong) UIButton                  *uploadPic;//上传图片
@property (nonatomic, strong) NSMutableArray            *imagesArray;
// submit
@property (nonatomic, strong) UIButton                  *submitButton;
@property (nonatomic, assign) CGFloat                   rateCount;
@property (nonatomic, assign) BOOL                      isLimit;  // 限制文字输入

@property (nonatomic, strong) OSSVWriteeRevieweViewModel      *viewModel;

@property (nonatomic,strong) UILabel *colorSizeLbl;

@end

@implementation OSSVWritesReviewsVC

typedef NS_ENUM(NSUInteger, ChoiceUploadType){
    ChoiceUploadTypePhoto= 0,
    ChoiceUploadTypeVideo
};


#pragma mark - Life Cycle
- (instancetype)init {
    if (self = [super init]) {
        ///1.4.6 默认0 分
        _rateCount = 5;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.firstEnter) {
        self.firstEnter = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = STLLocalizedString_(@"writeReview",nil);
    [self initSubViews];
}

- (void)setGoodsModel:(OSSVAccounteOrdersDetaileGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    
    self.ratingNameLabel.text = goodsModel.goodsName;
    self.colorSizeLbl.text = goodsModel.goodsAttr;
    [self.picImageView yy_setImageWithURL:[NSURL URLWithString:goodsModel.goodsThumb]
                              placeholder:[UIImage imageNamed:@"user_photo_new"]
                                  options:kNilOptions
                                 progress:nil
                                transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                    //image = [image yy_imageByResizeToSize:CGSizeMake(64,64) contentMode:UIViewContentModeScaleAspectFit];
                                    return image;
                                }
                               completion:nil];
}


#pragma mark - MakeUI
- (void)initSubViews {
    
    [self.view addSubview:self.scrollerView];
    self.view.backgroundColor = OSSVThemesColors.col_F5F5F5;
    [self.scrollerView addSubview:self.upBackView];
    
    [self.upBackView addSubview:self.picImageView];
    [self.upBackView addSubview:self.ratingNameLabel];
    [self.upBackView addSubview:self.colorSizeLbl];
    
   
    UIView *devider1 = [[UIView alloc] init];
    devider1.backgroundColor = OSSVThemesColors.col_EEEEEE;
    [self.upBackView addSubview:devider1];
    [self.upBackView addSubview:self.starControl];
    
    [self.upBackView addSubview:self.reviewTextView];
    
    UIView *underLine = [[UIView alloc] init];
    underLine.backgroundColor = OSSVThemesColors.col_CCCCCC;
    [self.upBackView addSubview:underLine];
    [self.upBackView addSubview:self.textCountLab];
    
    [self.upBackView addSubview:self.pictureView];
    [self.upBackView addSubview:self.uploadPic];
    
    [self.upBackView addSubview:self.submitButton];
    
    [self.scrollerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(UIEdgeInsetsMake(0, 0, kIPHONEX_BOTTOM, 0));
    }];
//    self.scrollerView.contentSize = CGSizeMake(0, 414);
        
    ////
    [self.upBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(@12);
        make.trailing.equalTo(-12);
        make.width.equalTo(SCREEN_WIDTH - 24);
        //由子视图撑开
//        make.height.mas_equalTo(@414);
    }];
    
    [self.picImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(@14);
        make.size.mas_equalTo(CGSizeMake(60, 80));
    }];
    
    [self.ratingNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@14);
        make.leading.equalTo(self.picImageView.mas_trailing).offset(8);
        make.trailing.mas_equalTo(@(-14));
        make.height.mas_equalTo(@14);
    }];
    
    [self.colorSizeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.ratingNameLabel.mas_leading);
        make.top.equalTo(self.ratingNameLabel.mas_bottom).offset(4);
    }];
    
    [devider1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(14);
        make.trailing.equalTo(-14);
        make.height.equalTo(0.5);
        make.top.equalTo(self.picImageView.mas_bottom).offset(12);
    }];
    
    [self.starControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(devider1.mas_bottom).offset(12);
        make.height.mas_equalTo(@24);
        make.width.mas_equalTo(@152);
        make.centerX.equalTo(devider1.centerX);
    }];
    
    ////
    [self.reviewTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.starControl.mas_bottom).offset(20.5);
        make.leading.mas_equalTo(14);
        make.trailing.mas_equalTo(-14);
        make.height.mas_equalTo(85);
    }];
    
    
    [underLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(14);
        make.trailing.equalTo(-14);
        make.height.equalTo(0.5);
        make.top.equalTo(self.reviewTextView.mas_bottom).offset(10);
    }];
    
    
    [self.textCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-14);
        make.top.mas_equalTo(underLine.mas_bottom).offset(4);
        make.height.equalTo(12);
    }];


    [self.pictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(14);
        make.top.mas_equalTo(self.textCountLab.mas_bottom).offset(12);
        make.height.equalTo(60);
    }];

    [self.uploadPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.pictureView.mas_trailing);
        make.top.mas_equalTo(self.textCountLab.mas_bottom).offset(12);
        make.width.height.mas_equalTo(@60);
        make.top.mas_equalTo(self.textCountLab.mas_bottom).offset(12);

    }];


    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.pictureView.mas_bottom).offset(12);
        make.leading.mas_equalTo(14);
        make.trailing.mas_equalTo(@(-14));
        make.height.mas_equalTo(@44);

        //最后一个约束用来撑开高度
        make.bottom.equalTo(self.upBackView.mas_bottom).offset(-12);
    }];

}



#pragma mark - Method
#pragma mark 提交
- (void)submitAction {
    
    [GATools
     logReviewsWithAction:[NSString stringWithFormat:@"Submit_ItemRating_%d",(int)self.rateCount]
     content:[NSString stringWithFormat:@"Product_%@",STLToString(_goodsModel.goodsName)]
    ];
    
    if ([OSSVNSStringTool isEmptyString:_reviewTextView.text]) {
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"shipExperience", nil)];
        return;
    }else if (_reviewTextView.text.length > 3000) {
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"limitCharacters", nil)];
        return;
    }
    
    NSString *imgStr1 = @"";
    NSString *imgStr2 = @"";
    NSString *imgStr3 = @"";
    NSArray *imgArr = [self uploadImages];
    for (int i = 0; i < imgArr.count; i ++)
    {
        switch (i) {
            case 0:
                imgStr1 = imgArr[0];
                break;
            case 1:
                imgStr2 = imgArr[1];
                break;
            case 2:
                imgStr3 = imgArr[2];
                break;
            default: break;
        }
    }
    NSDictionary *dict = @{@"goods_id"    : STLToString(_goodsModel.goodsId),
                           @"title"       : @"",
                           @"order_id"    : STLToString(self.orderId),
                           @"content"     : STLToString(_reviewTextView.text),
                           @"rate_overall": @(_rateCount),
                           @"review_pic1"  : imgStr1,
                           @"review_pic2"  : imgStr2,
                           @"review_pic3"  : imgStr3,
                           };
    @weakify(self)
    [self.viewModel requestNetwork:dict completion:^(id obj) {
        @strongify(self)
        if ([obj boolValue]) {
            [self.navigationController popViewControllerAnimated:YES];
            // 刷新订单详情页面
            if (_block) {
                _block();
            }
        }
    } failure:^(id obj) {
    }];
}

#pragma mark  上传图片数据处理
- (NSArray *)uploadImages {
    NSMutableArray *imgArr = [NSMutableArray array];
    
    if ([_imagesArray count]>0) {
        for (NSInteger i = 0; i<[_imagesArray count]; i++) {
            NSString *imgName = @"";
            YYAnimatedImageView *imageView = [_imagesArray objectAtIndex:i];
            UIImage *image = imageView.image;
            
            if (image.size.width != 640) {
                image = [self scaleImage:image toScale:640/image.size.width];
            }
            //图片压缩
            NSData* imageData = [self compressImageWithOriginImage:image];
            imgName = [imageData base64String];
            [imgArr addObject:imgName];
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

-(NSData *)compressImageWithOriginImage:(UIImage *)originImg {
    NSData* imageData;
    float i = 1.0;
    do {
        imageData = UIImageJPEGRepresentation(originImg, i);
        i -= 0.1;
    } while (imageData.length > 2*1024*1024);
    
    return imageData;
}




#pragma mark - 选择照片
- (void)selectPicture:(UIButton *)sender {
    
    STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:STLLocalizedString_(@"imageSize", nil)
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        [alertController addAction:[UIAlertAction actionWithTitle:STLLocalizedString_(@"takePhoto", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self selectFromCamera:ChoiceUploadTypePhoto];
                                                          }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:STLLocalizedString_(@"chooseExisting", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
            
                                    
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == AVAuthorizationStatusNotDetermined) {
                
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    // 用户点击了好 : status == PHAuthorizationStatusAuthorized
                    if (status == PHAuthorizationStatusAuthorized) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self selectFromLibrary:ChoiceUploadTypePhoto];

                        });
                    }
                }];
            } else {
                [self selectFromLibrary:ChoiceUploadTypePhoto];

            }
                                                          }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"cancel", nil) : STLLocalizedString_(@"cancel", nil).uppercaseString
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action){
                                                              
                                                          }]];
        
    } else {
        [alertController addAction:[UIAlertAction actionWithTitle:STLLocalizedString_(@"chooseExisting", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
                                                              if (status == AVAuthorizationStatusNotDetermined) {
                                                                  
                                                                  [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                                                                      // 用户点击了好 : status == PHAuthorizationStatusAuthorized
                                                                      if (status == PHAuthorizationStatusAuthorized) {
                                                                          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                              [self selectFromLibrary:ChoiceUploadTypePhoto];

                                                                          });
                                                                      }
                                                                  }];
                                                              } else {
                                                                  [self selectFromLibrary:ChoiceUploadTypePhoto];

                                                              }
                                                          }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"cancel", nil) : STLLocalizedString_(@"cancel", nil).uppercaseString
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action){
                                                          }]];
        
    }
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

#pragma mark  相册模式
- (void)selectFromLibrary:(NSInteger)choiceType {
    
    // 相册
    if (![self judgeIsHavePhotoAblumAuthority]) {
        //无相册访问权限
        [self showOpenTheUsePermission:STLLocalizedString_(@"photoNotPermission", nil)];
        return;
    }
    
    UIViewController *controller = nil;
    switch (self.imagesArray.count) {
        case 0: {
            switch (choiceType) {
                case ChoiceUploadTypePhoto: {
                    QBImagePickerController *thirdImagePicker = [QBImagePickerController new];
                    thirdImagePicker.delegate = self;
                    thirdImagePicker.mediaType = QBImagePickerMediaTypeImage;
                    thirdImagePicker.allowsMultipleSelection = YES;
                    thirdImagePicker.showsNumberOfSelectedAssets = YES;
                    thirdImagePicker.minimumNumberOfSelection = 1;
                    thirdImagePicker.maximumNumberOfSelection = 3;
                    controller = thirdImagePicker;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1: {
            switch (choiceType) {
                case ChoiceUploadTypePhoto: {
                    QBImagePickerController *thirdImagePicker = [QBImagePickerController new];
                    thirdImagePicker.delegate = self;
                    thirdImagePicker.mediaType = QBImagePickerMediaTypeImage;
                    thirdImagePicker.allowsMultipleSelection = YES;
                    thirdImagePicker.showsNumberOfSelectedAssets = YES;
                    thirdImagePicker.minimumNumberOfSelection = 1;
                    thirdImagePicker.maximumNumberOfSelection = 2;
                    controller = thirdImagePicker;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2: {
            switch (choiceType) {
                case ChoiceUploadTypePhoto: {
                    QBImagePickerController *thirdImagePicker = [QBImagePickerController new];
                    thirdImagePicker.delegate = self;
                    thirdImagePicker.mediaType = QBImagePickerMediaTypeImage;
                    thirdImagePicker.allowsMultipleSelection = YES;
                    thirdImagePicker.showsNumberOfSelectedAssets = YES;
                    thirdImagePicker.minimumNumberOfSelection = 1;
                    thirdImagePicker.maximumNumberOfSelection = 1;
                    controller = thirdImagePicker;
                }
                    break;
                default:
                    break;
            }
            
        }
            break;
        case 3: {
            switch (choiceType) {
                case ChoiceUploadTypePhoto: {
                    QBImagePickerController *thirdImagePicker = [QBImagePickerController new];
                    thirdImagePicker.delegate = self;
                    thirdImagePicker.mediaType = QBImagePickerMediaTypeImage;
                    thirdImagePicker.allowsMultipleSelection = YES;
                    thirdImagePicker.showsNumberOfSelectedAssets = YES;
                    thirdImagePicker.minimumNumberOfSelection = 0;
                    thirdImagePicker.maximumNumberOfSelection = 0;
                    controller = thirdImagePicker;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    if (controller) {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

#pragma mark  相机模式
- (void)selectFromCamera:(NSInteger)choiceType {
    
    // 相机
    if (![self judgeIsHaveCameraAuthority]) {
        //无拍照权限
        [self showOpenTheUsePermission:STLLocalizedString_(@"cameraNotPermission", nil)];
        return;
    }
    
    UIImagePickerController *systemImagePicker = [[UIImagePickerController alloc] init];
    systemImagePicker.delegate = self;
    //是否允许用户进行编辑
    systemImagePicker.allowsEditing = NO;
    //设置图像选取控制器的来源模式为相机模式
    systemImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //检查相机模式是否可用
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //获得相机模式下支持的媒体类型
        //        NSArray* availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        switch (choiceType) {
            case ChoiceUploadTypePhoto:
            {
                //                systemImagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:systemImagePicker.sourceType];
                //设置图像选取控制器的类型为静态图像
                systemImagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
            }
                break;
            default:
                break;
        }
    } else {
        STLLog(@"sorry, no camera or camera is unavailable.");
        return;
    }
    systemImagePicker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:systemImagePicker animated:YES completion:nil];
}


#pragma mark  相册、相机访问权限
- (BOOL)judgeIsHavePhotoAblumAuthority {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

- (BOOL)judgeIsHaveCameraAuthority {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

- (void)showOpenTheUsePermission:(NSString *)showInformation {
    
    STLAlertViewController *alertController =  [STLAlertViewController
                                           alertControllerWithTitle: showInformation
                                           message:nil
                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:STLLocalizedString_(@"done", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            [self dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 拍照的图片大于2M时，对图片进行压缩，给定参数为设置图片的宽度
- (UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth {
//    CGSize imageSize = sourceImage.size;
    //    CGFloat width = imageSize.width;
    //    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = defineWidth;//(targetWidth / width) * height;
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0,0,targetWidth,  targetHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark  删除图片或者视频 右上角删除
- (YYAnimatedImageView *)buildCustomImageView:(UIImage *)image show:(BOOL)show {
    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
    imageView.layer.masksToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.userInteractionEnabled = YES;
    ///1.4.6 去掉查看大图
//    if (show) {
//        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchImage:)]];
//    }
    UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [delBtn setImage:[UIImage imageNamed:@"detele_review"] forState:UIControlStateNormal];
    delBtn.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.8];
    delBtn.layer.cornerRadius = 12;
    [imageView addSubview:delBtn];
    [delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(24);
        make.centerY.equalTo(imageView.mas_centerY);
        make.centerX.equalTo(imageView.mas_centerX);
    }];
    if (show) {
        [delBtn addTarget:self action:@selector(deleteImageView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return imageView;
}

#pragma mark  点击图片放大
-(void)touchImage:(UITapGestureRecognizer *)tap{
    __weak typeof(self) weakSelf=self;
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeZoom index:tap.view.tag photoModelBlock:^NSArray *{
        NSArray *localImages = [weakSelf.imagesArray subarrayWithRange:NSMakeRange(0, weakSelf.imagesArray.count)];
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:localImages.count];
        for (NSUInteger i = 0; i< localImages.count; i++) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = i + 1;
            pbModel.image = [localImages[i] valueForKey:@"image"];
            //源frame
            YYAnimatedImageView *imageV =(YYAnimatedImageView *) localImages[i];
            pbModel.sourceImageView = imageV;
            [modelsM addObject:pbModel];
        }
        return modelsM;
    }];
}

#pragma mark  删除图片
- (void)deleteImageView:(UIButton *)sender {
    YYAnimatedImageView *imageView = (YYAnimatedImageView *)[sender superview];
    [self.imagesArray removeObject:imageView];
    [imageView removeFromSuperview];
    [self layoutPhotos];
}


#pragma mark - 取消选择图片
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - 多选照片的代理方法。在这里进行选择，上传等一系列操作
#pragma mark  QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    if (imagePickerController.mediaType == QBImagePickerMediaTypeImage) {
        
        @autoreleasepool {
            
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
            //把PHAsset转换成为UIImage对象
                    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                        
                        STLLog(@"-------%@",info);
                        if (result) {
                            YYAnimatedImageView *imageView = [self buildCustomImageView:result show:YES];
                            [self.imagesArray addObject:imageView];
                            [self.pictureView addSubview:imageView];
                            [self layoutPhotos];
                        }
                        
                        // Download image from iCloud / 从iCloud下载图片
                        if ([info objectForKey:PHImageResultIsInCloudKey] && !result ) {
                            
                            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                                STLLog(@"图片云下载-------%f", progress); //follow progress + update progress bar
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    if (progressHandler) {
//                                        progressHandler(progress, error, stop, info);
//                                    }
//                                });
                            };
                            options.networkAccessAllowed = YES;
                            options.resizeMode = PHImageRequestOptionsResizeModeFast;
                            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                                
                                STLLog(@"图片云result-------");
                                if (resultImage) {
                                    STLLog(@"图片云result-------1");

                                    YYAnimatedImageView *imageView = [self buildCustomImageView:resultImage show:YES];
                                    [self.imagesArray addObject:imageView];
                                    [self.pictureView addSubview:imageView];
                                    [self layoutPhotos];
                                }

                            }];
                        }
                    }];
        }];
        }
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(PHAsset *)asset {
//    [self.imagesArray addObject:asset];
//}
//
//- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didDeselectAsset:(PHAsset *)asset {
//    [self.imagesArray removeObject:asset];
//}

#pragma mark - 相机模式后对图片进行处理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 判断获取类型：图片
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        if (self.imagesArray.count < 6) {
            UIImage *image = nil;
            // 判断，图片是否允许修改
            if ([picker allowsEditing]){
                //获取用户编辑之后的图像
                image = [info objectForKey:UIImagePickerControllerEditedImage];
            } else {
                // 照片的元数据参数
                image = [info objectForKey:UIImagePickerControllerOriginalImage];
            }
//            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            YYAnimatedImageView *imageView = [self buildCustomImageView:image show:YES];
            [self.imagesArray addObject:imageView];
            [self.pictureView addSubview:imageView];
            [self layoutPhotos];
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 选择的照片重新布局
- (void)layoutPhotos {
    if (self.imagesArray.count == 3) {
        self.uploadPic.hidden = YES;
    }else {
        self.uploadPic.hidden = NO;
    }
    if (self.imagesArray.count > 1) {
        [self.imagesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //这里是重新设置每一个imageView的tag值，为了方便删除数据
            if ([obj isKindOfClass:[YYAnimatedImageView class]]) {
                [obj setValue:@(idx) forKey:@"tag"];
            }
            [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
            }];
        }];
        [self.imagesArray mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:8 leadSpacing:0 tailSpacing:8];
        [self.imagesArray mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.pictureView.mas_centerY);
            make.top.mas_equalTo(self.pictureView.mas_top);
            make.bottom.mas_equalTo(self.pictureView.mas_bottom);
            make.width.mas_equalTo(@60);
        }];
        [self.pictureView layoutIfNeeded];
    } else if (self.imagesArray.count == 1) {
        [[self.imagesArray firstObject] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.pictureView.mas_top);
            make.bottom.mas_equalTo(self.pictureView.mas_bottom);
            make.leading.mas_equalTo(self.pictureView.mas_leading);
            make.trailing.mas_equalTo(self.pictureView.mas_trailing).offset(-8);
            make.width.mas_equalTo(@60);
        }];
    }
}

#pragma mark - textViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if (textView.text.length>2999) {
        if ([text isEqualToString:@""]){
            return YES;
        }
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.textCountLab.text = [NSString stringWithFormat:@"%ld/3000", (unsigned long)self.reviewTextView.text.length];
    
    if (!STLIsEmptyString(textView.text)) {
        self.submitButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
        self.submitButton.enabled = YES;
    } else {
        self.submitButton.backgroundColor = [OSSVThemesColors col_CCCCCC];
        self.submitButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 是否支持屏幕旋转
- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - LazyLoad

- (NSMutableArray*)imagesArray {
    if (!_imagesArray) {
        _imagesArray = [[NSMutableArray alloc] init];
    }
    return _imagesArray;
}

- (OSSVWriteeRevieweViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVWriteeRevieweViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (UIScrollView *)scrollerView {
    if (!_scrollerView) {
        _scrollerView = [[UIScrollView alloc] init];
        _scrollerView.showsHorizontalScrollIndicator = NO;
        _scrollerView.showsVerticalScrollIndicator = NO;
        _scrollerView.backgroundColor = [UIColor clearColor];
    }
    return _scrollerView;
}

- (UIView *)upBackView {
    if (!_upBackView) {
        _upBackView = [[UIView alloc] init];
        _upBackView.backgroundColor = [UIColor whiteColor];
        _upBackView.layer.cornerRadius = 6;
    }
    return _upBackView;
}

- (YYAnimatedImageView *)picImageView {
    if (!_picImageView) {
        _picImageView = [[YYAnimatedImageView alloc] init];
        _picImageView.layer.borderWidth = 0.5;
        _picImageView.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.clipsToBounds = true;
    }
    return _picImageView;
}

- (UILabel *)ratingNameLabel {
    if (!_ratingNameLabel) {
        _ratingNameLabel = [[UILabel alloc] init];
        _ratingNameLabel.textColor = OSSVThemesColors.col_6C6C6C;
        _ratingNameLabel.font = [UIFont systemFontOfSize:12];
        _ratingNameLabel.numberOfLines = 1;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _ratingNameLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        }
    }
    return _ratingNameLabel;
}

- (ZZStarView *)starControl {
    if (!_starControl) {
        @weakify(self)
        _starControl = [[ZZStarView alloc] initWithImage:[UIImage imageNamed:@"review_new_star"] selectImage:[UIImage imageNamed:@"review_new_star_h"] starWidth:24 starHeight:24 starMargin:8 starCount:5 callBack:^(CGFloat userGrade, CGFloat finalGrade) {
            @strongify(self)
            self.rateCount = finalGrade;
            
            [GATools
             logReviewsWithAction:[NSString stringWithFormat:@"ItemRating_Rate_%d",(int)finalGrade]
             content:[NSString stringWithFormat:@"Product_%@",STLToString(_goodsModel.goodsName)]
            ];
        }];
//        _starControl.enabled = YES;
        
        _starControl.grade = _rateCount;
//        _starControl.delegate = self;
        //默认0.5
        _starControl.sublevel = 1;
//        _starControl.
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _starControl.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
        _starControl.backgroundColor = [UIColor whiteColor];
        _starControl.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _starControl;
}

- (PlacehoderTextView *)reviewTextView {
    if (!_reviewTextView) {
        _reviewTextView = [[PlacehoderTextView alloc] init];
//        _reviewTextView.placeholder = STLLocalizedString_(@"Comments_have_chance_receiv_10_points",nil);
        _reviewTextView.placeholder = STLLocalizedString_(@"goodsWritePlaceholderTextView",nil);
        _reviewTextView.editable = YES;
        _reviewTextView.font = [UIFont boldSystemFontOfSize:14];
        _reviewTextView.delegate = self;
        _reviewTextView.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
//        _reviewTextView.textContainerInset =  UIEdgeInsetsMake(10, 15, 0, 10);  // 改变文字编辑的位置
    }
    return _reviewTextView;
}

- (UILabel *)textCountLab {
    if (!_textCountLab) {
        _textCountLab = [[UILabel alloc] init];
        _textCountLab.text = STLLocalizedString_(@"defaultCount",nil);
        _textCountLab.font = [UIFont systemFontOfSize:12];
        _textCountLab.textColor = OSSVThemesColors.col_6C6C6C;
    }
    return _textCountLab;
}

- (UIView *)pictureView {
    if (!_pictureView) {
        _pictureView = [[UIView alloc] init];
    }
    return _pictureView;
}

- (UIButton *)uploadPic {
    if (!_uploadPic) {
        _uploadPic = [UIButton buttonWithType:UIButtonTypeCustom];
        [_uploadPic addTarget:self action:@selector(selectPicture:) forControlEvents:UIControlEventTouchUpInside];
        [_uploadPic setBackgroundImage:[UIImage imageNamed:@"review_add_img"] forState:UIControlStateNormal];
    }
    return _uploadPic;
}

- (UIButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_submitButton setTitle:STLLocalizedString_(@"submit",nil).uppercaseString forState:UIControlStateNormal];
        _submitButton.titleLabel.font = [UIFont stl_buttonFont:14];
        _submitButton.backgroundColor = [OSSVThemesColors col_CCCCCC];
        [_submitButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        _submitButton.layer.cornerRadius = 0.0;
        _submitButton.layer.masksToBounds = YES;
        _submitButton.enabled = NO;
        [_submitButton addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

-(UILabel *)colorSizeLbl{
    if (!_colorSizeLbl) {
        _colorSizeLbl = [[UILabel alloc] init];
        _colorSizeLbl.textColor = OSSVThemesColors.col_6C6C6C;
        _colorSizeLbl.font = [UIFont boldSystemFontOfSize:12];
    }
    return _colorSizeLbl;
}
@end
