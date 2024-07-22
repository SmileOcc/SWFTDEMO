//
//  ZFUserSexSelectViewController.m
//  ZZZZZ
//
//  Created by 602600 on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFUserSexSelectViewController.h"
#import "ZFColorDefiner.h"
#import "ZFLocalizationString.h"
#import "ZFUserSexImageView.h"
#import "Masonry.h"
#import "ZFUserSexImageView.h"
#import "ZFFrameDefiner.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "ZFPubilcKeyDefiner.h"

@interface ZFUserSexSelectViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) ZFUserSexImageView *womenSelectView;

@property (nonatomic, strong) ZFUserSexImageView *menSelectView;

@property (nonatomic, strong) ZFUserSexImageView *swimwearSelectView;

@property (nonatomic, copy) NSString *sex; //性别{0未知1男2女}

@end

@implementation ZFUserSexSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self zfInitView];
    [self zfAutoLayoutView];
}

- (void)zfInitView {
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.contentLabel];
    [self.view addSubview:self.doneButton];
    
    NSString  *countryCode = ZFToString(GetUserDefault(kLocationInfoPipeline));
    NSArray *imagesArray;
    if ([self isSummerArea:countryCode]) {
        // 夏季
        imagesArray = @[@"sex_women" , @"sex_men", @"sex_swimwear"];
    } else {
        imagesArray = @[@"sex_women_winter" , @"sex_men_winter", @"sex_swimwear_winter"];
    }
    
    NSArray *textArray = @[ZFLocalizedString(@"Car_Empty_Women", nil) , ZFLocalizedString(@"Car_Empty_Men", nil), ZFLocalizedString(@"sex_Swimwear", nil)];
    NSMutableArray *selectImages = [NSMutableArray arrayWithCapacity:imagesArray.count];
    for (int i = 0; i < imagesArray.count; i ++) {
        ZFUserSexImageView *selectImageView = [[ZFUserSexImageView alloc] init];
        [selectImageView setSelectViewImageName:imagesArray[i] text:textArray[i]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectViewAction:)];
        [selectImageView addGestureRecognizer:tap];
        [self.view addSubview:selectImageView];
        [selectImages addObject:selectImageView];
        
        switch (i) {
            case 0:
            {
                self.womenSelectView = selectImageView;
                [selectImageView selectUI];
                self.sex = @"2";
            }
                break;
            case 1:
                self.menSelectView = selectImageView;
                break;
            case 2:
                self.swimwearSelectView = selectImageView;
                break;

            default:
                break;
        }
    }
}

- (void)zfAutoLayoutView {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(94 + STATUSHEIGHT);
        make.size.mas_equalTo(CGSizeMake(141, 32));
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(25);
        make.trailing.mas_equalTo(-25);
        make.top.mas_equalTo(self.imageView.mas_bottom).offset(23);
    }];
    
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(-kiphoneXHomeBarHeight-8);
    }];
    
    CGFloat spac = (KScreenWidth - 25 * 2 - 90 * 3) / 2.0;
    [self.womenSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(112);
        make.leading.mas_equalTo(25);
    }];
    
    [self.menSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(112);
        make.leading.mas_equalTo(self.womenSelectView.mas_trailing).offset(spac);
    }];
    
    [self.swimwearSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(112);
        make.leading.mas_equalTo(self.menSelectView.mas_trailing).offset(spac);
    }];
}

#pragma mark - Action
- (void)doneButtonAction:(UIButton *)sender {
    SaveUserDefault(ZFSexSelect, ZFToString(self.sex));
    if (self.didFinishBlock) {
        self.didFinishBlock();
    }
}

- (void)selectViewAction:(UITapGestureRecognizer *)tap {
    ZFUserSexImageView *selectView = (ZFUserSexImageView *)tap.view;
    [selectView selectUI];
    if (selectView == self.womenSelectView) {
        [self.menSelectView resetUI];
        [self.swimwearSelectView resetUI];
        self.sex = @"2";
    } else if (selectView == self.menSelectView) {
        [self.womenSelectView resetUI];
        [self.swimwearSelectView resetUI];
        self.sex = @"1";
    } else if (selectView == self.swimwearSelectView) {
        [self.menSelectView resetUI];
        [self.womenSelectView resetUI];
        self.sex = @"2";
    }
}

#pragma mark - <get lazy Load>
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"sex_logo"];
    }
    return _imageView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        _contentLabel.numberOfLines = 0;
        _contentLabel.textAlignment = NSTextAlignmentCenter;
//        _contentLabel.text = ZFLocalizedString(@"sex_select_tip", nil);
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineSpacing = 8;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:ZFLocalizedString(@"sex_select_tip", nil) attributes: @{NSFontAttributeName: [UIFont systemFontOfSize:14],NSForegroundColorAttributeName: [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0],NSParagraphStyleAttributeName: paragraphStyle}];

        _contentLabel.attributedText = string;
    }
    return _contentLabel;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton setTitle:ZFLocalizedString(@"Category_Done", nil) forState:UIControlStateNormal];
        _doneButton.backgroundColor = ZFCOLOR(45, 45, 45, 1);
        _doneButton.layer.cornerRadius = 3;
        _doneButton.layer.masksToBounds = YES;
        [_doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

// 夏季
- (BOOL)isSummerArea:(NSString *)countryCode {
    /* 夏季：印尼ZFID、新加坡ZFSG、菲律宾ZFPH、马来西亚ZFMY、印度ZFIN、南非ZFZA、巴西ZFBR、拉美站ZFMX、泰国ZFTH、中国台湾ZFTW、土耳其ZFTR、以色列ZFIL、越南ZFVN、香港ZFHK、墨西哥ZFMX01、中东站ZFAR

    冬季：全球站ZF、法国ZFFR、德国ZFDE、西班牙站ZFES、意大利ZFIT、欧洲站ZFIE、英国ZFGB、日本ZFJP、瑞士ZFCH、比利时ZFBE、新西兰ZFNZ、俄罗斯ZFRU、罗马尼亚ZFRO、奥地利ZFAT、加拿大ZFCA、澳大利亚ZFAU
    */
    NSArray *summerAreas = @[@"ZFID",@"ZFSG",@"ZFPH",@"ZFMY",@"ZFIN",@"ZFZA",@"ZFBR",@"ZFMX",@"ZFTH",@"ZFTW",@"ZFTR",@"ZFIL",@"ZFVN",@"ZFHK",@"ZFMX01",@"ZFAR"];
    return [summerAreas containsObject:ZFToString(countryCode)];
}


@end
