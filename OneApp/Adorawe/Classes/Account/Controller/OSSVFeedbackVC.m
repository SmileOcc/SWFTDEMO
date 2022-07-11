
//
//  OSSVFeedbackVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVFeedbackVC.h"
#import "OSSVFeedBaksViewModel.h"
#import "PlacehoderTextView.h"
#import "STLTextField.h"
#import "OSSVAccountsManager.h"
#import "AccountModel.h"
#import "OSSVMyPhotosCell.h"
#import "QBImagePickerController.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "UICollectionViewRightAlignedLayout.h"
#import "UITextField+STLCategory.h"
#import <MobileCoreServices/MobileCoreServices.h>

static const NSInteger kMaxInputCharacters = 200;

@interface OSSVFeedbackVC ()
<
UITextViewDelegate,
UITextFieldDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
QBImagePickerControllerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>

@property (nonatomic, strong) OSSVFeedBaksViewModel  *viewModel;
@property (nonatomic, strong) UIView             *upBackView;
@property (nonatomic, strong) STLTextField        *issueField;
@property (nonatomic, strong) UIButton           *selectBtn;
@property (nonatomic, strong) UIPickerView       *pickerView;
@property (nonatomic, strong) PlacehoderTextView *feedbackView;
@property (nonatomic, strong) STLTextField        *emailField;
@property (nonatomic, strong) UIButton           *submitBtn;
@property (nonatomic, strong) NSString           *selectIndexType;
@property (nonatomic, strong) UICollectionView   *photoCollectView;
@property (nonatomic,strong ) NSMutableArray     *selectedPhotos;

@end

@implementation OSSVFeedbackVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = STLLocalizedString_(@"FeedBack", nil);
    self.view.backgroundColor = OSSVThemesColors.col_F1F1F1;
    [self.viewModel requestFeedBackReason];
    [self initView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewCheckInputLength:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.firstEnter) {
    }
    self.firstEnter = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Method
#pragma mark 确定Action
- (void)actionOnSubmitButton:(UIButton *)sender {
    //先判断是否数据合法
    if (![self checkInputInfo]) return ;
    
    NSDictionary *dic = @{
    FeedBackKeyOfType     : self.selectIndexType  ? self.selectIndexType : @"1",
    FeedBackKeyOfEmail    : self.emailField.text,
    FeedBackKeyOfContent  : self.feedbackView.text,
    FeedBackKeyOfimages   : self.selectedPhotos
    };
    
    if (![OSSVAccountsManager sharedManager].isSignIn) {
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        signVC.signBlock = ^{
            @strongify(self)
            [self submmitContent:dic];
        };
        [self presentViewController:signVC animated:YES completion:nil];
    } else {
        [self submmitContent:dic];
    }

     [OSSVAnalyticsTool analyticsGAEventWithName:@"FAQ_action" parameters:@{
            @"screen_group":@"Feedback",
            @"action":[NSString stringWithFormat:@"Submit_%@",STLToString(self.issueField.text)]}];
    
}

- (void)submmitContent:(NSDictionary *)dic {
    
    @weakify(self)
    [self.viewModel requestNetwork:dic completion:^(id obj){
         @strongify(self)
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(id obj){
        
    }];
}

// 点击issueTextField 右边arrow 事件
- (void)issueTextFieldArrowAction {
    [self.issueField becomeFirstResponder];
}

- (void)textViewCheckInputLength:(UITextView *)textView {

    // 这个地方还需要测试下
    if (self.feedbackView.text.length > kMaxInputCharacters)  {
        self.feedbackView.text = [self.feedbackView.text substringToIndex:kMaxInputCharacters];
    }
}

- (void)deleteBtnClik:(UIButton *)sender {
    [_selectedPhotos removeObjectAtIndex:sender.tag];
    [_photoCollectView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [_photoCollectView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [_photoCollectView reloadData];
    }];
}

#pragma mark - Private Check HUD
- (BOOL)checkInputInfo {
    /**
     *  注意此处的提示语已经是国际化啦
     */
    BOOL isCheck = YES;
    NSString *tips = @"";
    if([OSSVNSStringTool isEmptyString:self.selectIndexType]) {
        tips = isCheck ? STLLocalizedString_(@"FeedbackEmptyMsg", nil) : tips;
        [self showErrorBorderColorWithTextField:self.issueField];
        isCheck = NO;
    }
    if ([OSSVNSStringTool isEmptyString:self.feedbackView.text]) {
        tips = isCheck ? STLLocalizedString_(@"FeedbackEmptyMsg", nil) : tips;
        isCheck = NO;
        self.feedbackView.layer.borderColor = [UIColor redColor].CGColor;
    }
    if ([OSSVNSStringTool isEmptyString:self.emailField.text]
        || ![OSSVNSStringTool isValidEmailString:self.emailField.text]) {
        tips = isCheck ? STLLocalizedString_(@"FeedbackEmptyMsg", nil) : tips;
        isCheck = NO;
        [self showErrorBorderColorWithTextField:self.emailField];
    }
    if (!isCheck) {
        [self showHUDWithErrorText:tips];
    }
    return isCheck;
}

- (void)showHUDWithErrorText:(NSString *)text {
//    [HUDManager showHUDWithMessage:STLToString(text) customView:[[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"prompt"]]];
    [HUDManager showHUDWithMessage:text];
}

- (void)showErrorBorderColorWithTextField:(STLTextField *)textField {
    textField.layer.borderColor = [UIColor redColor].CGColor;
}
#pragma mark - Delegate
#pragma mark UITextFieldDelegate
// 设置textField不能输入文字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.issueField) {
        return NO;
    }
    return YES;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.issueField) {
        [self.viewModel pickerViewDidSelected:self.pickerView];
        if (!CGColorEqualToColor(textField.layer.borderColor,OSSVThemesColors.col_DDDDDD.CGColor)) {
            textField.layer.borderColor = OSSVThemesColors.col_DDDDDD.CGColor;
        }
    }
}

#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.layer.borderColor != OSSVThemesColors.col_DDDDDD.CGColor) {
        textView.layer.borderColor = OSSVThemesColors.col_DDDDDD.CGColor;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (textView.text.length + text.length > kMaxInputCharacters) {
        [self showHUDWithErrorText:STLLocalizedString_(@"FeedbackMaxMsg", nil)];
        return NO;
    }
    return YES;
}

#pragma mark - MakeUI;
- (void)initView {
    
    _upBackView = [[UIView alloc] init];
    _upBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_upBackView];
    [_upBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.leading.equalTo(@0);
    }];
   
    UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect rect =  arrowButton.frame;
    rect.size = CGSizeMake(30, 30);
    arrowButton.frame = rect;
    [arrowButton setImage:[UIImage imageNamed:@"xl_button"] forState:UIControlStateNormal];
    [arrowButton addTarget:self action:@selector(issueTextFieldArrowAction) forControlEvents:UIControlEventTouchUpInside];
    
    _issueField = [[STLTextField alloc]init];
    _issueField.rightView = arrowButton;
    _issueField.rightViewMode = UITextFieldViewModeAlways;
    _issueField.layer.borderColor = OSSVThemesColors.col_DDDDDD.CGColor;
    _issueField.layer.borderWidth = 1.f;
    _issueField.layer.cornerRadius = 4.f;
    _issueField.placeholder = STLLocalizedString_(@"feedBackPlaceholderIssue", nil);
    _issueField.delegate = self;
    _issueField.font = [UIFont systemFontOfSize:12];
    [_issueField stlPlaceholderColor:OSSVThemesColors.col_D1D1D1];
    [_upBackView addSubview:_issueField];

    
    [_issueField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@15);
        make.leading.equalTo(@(10));
        make.trailing.equalTo(@(-10));
        make.height.mas_equalTo(40);
    }];
    
    #pragma mark issueField 添加 UIPickerView
    _issueField.inputView = self.pickerView;

    // 下面FeedBackView
    _feedbackView = [[PlacehoderTextView alloc]init];
    _feedbackView.placeholder = STLLocalizedString_(@"feedBackPlaceholderTextView", nil);
    _feedbackView.layer.borderWidth = 1.0f;
    _feedbackView.layer.borderColor = OSSVThemesColors.col_DDDDDD.CGColor;
    _feedbackView.font = [UIFont systemFontOfSize:12];
    _feedbackView.layer.cornerRadius = 4.f;
    _feedbackView.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    _feedbackView.delegate = self;
    _feedbackView.textContainerInset =  UIEdgeInsetsMake(12, 5, 0, 2);
    _feedbackView.placeholderColor = OSSVThemesColors.col_D1D1D1;
    
    [_upBackView addSubview:_feedbackView];
    
    [_feedbackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_issueField.mas_bottom).with.offset(15);
        make.leading.equalTo(@10);
        make.trailing.equalTo(@(-10));
        make.height.mas_equalTo(155);
    }];
    
    UICollectionViewLayout *layout;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        UICollectionViewRightAlignedLayout *rightLayout = [[UICollectionViewRightAlignedLayout alloc] init];
        CGFloat margin = 5;
        rightLayout.minimumInteritemSpacing = margin;
        rightLayout.minimumLineSpacing = margin;
        rightLayout.itemSize = CGSizeMake(65, 65);
        rightLayout.sectionInset = UIEdgeInsetsMake(15, 10, 0, 0);
        layout = rightLayout;
    } else {
        UICollectionViewLeftAlignedLayout *leftLayout = [[UICollectionViewLeftAlignedLayout alloc] init];
        CGFloat margin = 5;
        leftLayout.minimumInteritemSpacing = margin;
        leftLayout.minimumLineSpacing = margin;
        leftLayout.itemSize = CGSizeMake(65, 65);
        leftLayout.sectionInset = UIEdgeInsetsMake(15, 10, 0, 0);
        layout = leftLayout;
    }
    
    self.photoCollectView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.photoCollectView.dataSource = self;
    self.photoCollectView.delegate = self;
    self.photoCollectView.backgroundColor = [UIColor whiteColor];
    
    [self.photoCollectView registerClass:[OSSVMyPhotosCell class] forCellWithReuseIdentifier:@"OSSVMyPhotosCell"];
    
    [_upBackView addSubview:self.photoCollectView];
    [self.photoCollectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_feedbackView.mas_bottom);
        make.leading.trailing.equalTo(_upBackView);
        make.height.mas_equalTo(80);
    }];
    self.selectedPhotos = [NSMutableArray array];

    _emailField = [[STLTextField alloc]init];
    _emailField.layer.borderColor = OSSVThemesColors.col_DDDDDD.CGColor;
    _emailField.layer.borderWidth = 1.f;
    _emailField.layer.cornerRadius = 4.f;
    _emailField.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    _emailField.delegate = self;
    if ([OSSVAccountsManager sharedManager]) {
        AccountModel *model = [OSSVAccountsManager sharedManager].account;
        _emailField.text = model.email;
    }
    _emailField.placeholder = STLLocalizedString_(@"feedBackPlaceholderEmail", nil);
    _emailField.font = [UIFont systemFontOfSize:12];
    [_emailField stlPlaceholderColor:OSSVThemesColors.col_D1D1D1];
    [_upBackView addSubview:_emailField];
    
    [_emailField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.photoCollectView.mas_bottom).with.offset(15);
        make.leading.equalTo(@10);
        make.trailing.equalTo(@(-10));
        make.height.mas_equalTo(40);
    }];
    
    
    [_upBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_emailField.mas_bottom).offset(20);
    }];
    
    _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitBtn.layer.cornerRadius = 4.f;
    [_submitBtn setTitle:STLLocalizedString_(@"submit", nil) forState:UIControlStateNormal];
    _submitBtn.backgroundColor = [OSSVThemesColors col_262626];
    [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _submitBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_submitBtn addTarget:self action:@selector(actionOnSubmitButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitBtn];
    
    [_submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_upBackView.mas_bottom).offset(30);
        make.leading.equalTo(@30);
        make.trailing.equalTo(@(-30));
        make.height.mas_equalTo(40);
    }];
    
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectedPhotos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
     OSSVMyPhotosCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OSSVMyPhotosCell" forIndexPath:indexPath];
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.row == _selectedPhotos.count) {
        cell.photoView.image = [UIImage imageNamed:@"add_photo"];
        cell.deleteBtn.hidden = YES;
        cell.photoView.contentMode = UIViewContentModeScaleAspectFill;
        
    } else {
        cell.deleteBtn.hidden = NO;
        cell.photoView.image = _selectedPhotos[indexPath.row];
        cell.photoView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedPhotos.count) {
        
        [_feedbackView resignFirstResponder];
        
        if (_selectedPhotos.count == 3) {
            return;
        }
        
        [self showPhotoActionsheet];
        
    }
}

#pragma mark - PhotoMethod
- (void)showPhotoActionsheet {
    STLAlertViewController *alertController =  [STLAlertViewController
                                           alertControllerWithTitle: nil
                                           message:nil
                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * takePhotoAction = [UIAlertAction actionWithTitle:STLLocalizedString_(@"takePhoto",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        if (![self judgeIsHaveCameraAuthority]) {
            [self showOpenTheUsePermission:STLLocalizedString_(@"cameraNotPermission", nil)];
            return;
        }
        [self selectFromCamera];
        
    }];
    
    UIAlertAction * albumsAction = [UIAlertAction actionWithTitle:STLLocalizedString_(@"chooseAlbums",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        if (![self judgeIsHavePhotoAblumAuthority]) {
            [self showOpenTheUsePermission:STLLocalizedString_(@"photoNotPermission", nil)];
            return;
        } else {
            
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == AVAuthorizationStatusNotDetermined) {
                
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    // 用户点击了好 : status == PHAuthorizationStatusAuthorized
                    if (status == PHAuthorizationStatusAuthorized) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self selectFromLibrary];
                            
                        });
                    }
                }];
                return;
            }
            
        }
        [self selectFromLibrary];
        
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"cancel",nil) : STLLocalizedString_(@"cancel",nil).uppercaseString style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
    [alertController addAction:takePhotoAction];
    [alertController addAction:albumsAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

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
    
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:STLLocalizedString_(@"done", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
    }];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)selectFromCamera {
    UIImagePickerController *systemImagePicker = [[UIImagePickerController alloc] init];
    systemImagePicker.delegate = self;
    //是否允许用户进行编辑
    systemImagePicker.allowsEditing = NO;
    //设置图像选取控制器的来源模式为相机模式
    systemImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //检查相机模式是否可用
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        //设置图像选取控制器的类型为静态图像
        systemImagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        
    } else {
        STLLog(@"sorry, no camera or camera is unavailable.");
        return;
    }
    systemImagePicker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:systemImagePicker animated:YES completion:nil];
}

- (void)selectFromLibrary {
    QBImagePickerController *thirdImagePicker = [QBImagePickerController new];
    thirdImagePicker.delegate = self;
    thirdImagePicker.mediaType = QBImagePickerMediaTypeImage;
    thirdImagePicker.allowsMultipleSelection = YES;
    thirdImagePicker.showsNumberOfSelectedAssets = YES;
    thirdImagePicker.minimumNumberOfSelection = 1;
    thirdImagePicker.maximumNumberOfSelection = _selectedPhotos.count == 0 ? 3 : (3 - _selectedPhotos.count);
    [self presentViewController:thirdImagePicker animated:YES completion:NULL];
}

#pragma mark - QBImagePickerControllerDelegate
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    if (imagePickerController.mediaType == QBImagePickerMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
            //把PHAsset转换成为UIImage对象
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                
                if (result) {
                    [_selectedPhotos addObject:result];
                    [self.photoCollectView reloadData];
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
                            
                            [_selectedPhotos addObject:resultImage];
                            [self.photoCollectView reloadData];
                        }
                        
                    }];
                }
            }];
        }];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)qb_imagePickerController:(QBImagePickerController *)imagePickerController shouldSelectAsset:(PHAsset *)asset {
    
    if (imagePickerController.selectedAssets.count > 2 - self.selectedPhotos.count) {
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"selectImageThree", nil)];
        return NO;
    }
    
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 判断获取类型：图片
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        if (self.selectedPhotos.count < 3) {
            UIImage *image = nil;
            // 判断，图片是否允许修改
            if ([picker allowsEditing]){
                //获取用户编辑之后的图像
                image = [info objectForKey:UIImagePickerControllerEditedImage];
            } else {
                // 照片的元数据参数
                image = [info objectForKey:UIImagePickerControllerOriginalImage];
            }
            [self.selectedPhotos addObject:image];
            [self.photoCollectView reloadData];
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LazyLoad
- (OSSVFeedBaksViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVFeedBaksViewModel alloc]init];
        _viewModel.controller = self;
        @weakify(self)
        _viewModel.showPickerBlock = ^(NSString *info,NSInteger index){
            @strongify(self)
            self.issueField.text = info;
//            self.selectIndexType = [NSString stringWithFormat:@"%ld",(long)(index + 1)];
            self.selectIndexType = [NSString stringWithFormat:@"%ld",(long)(index)];

        };
    }
    return _viewModel;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.dataSource = self.viewModel;
        _pickerView.delegate = self.viewModel;
    }
    return _pickerView;
}


@end
