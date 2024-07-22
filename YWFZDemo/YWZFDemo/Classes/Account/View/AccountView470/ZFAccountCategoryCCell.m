//
//  ZFAccountCategoryCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/6/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountCategoryCCell.h"
#import "ZFAccountCategorySectionModel.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "UIButton+ZFButtonCategorySet.h"
#import <Masonry/Masonry.h>

@interface ZFAccountCategoryCCell ()

@property (nonatomic, strong) UIButton *enterButton;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation ZFAccountCategoryCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = ZFCOLOR_WHITE;
        
        [self addSubview:self.enterButton];
        [self addSubview:self.nameLabel];
        
        [self.enterButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(self.mas_top).mas_offset(16);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.enterButton.mas_bottom).mas_offset(8);
            make.centerX.mas_equalTo(self.enterButton);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-10);
        }];
    }
    return self;
}

///返回一个自定义Cell尺寸
+ (CGSize)itemSize:(NSInteger)sectionRows protocol:(id<ZFCollectionCellDatasourceProtocol>)protocol
{
    CGFloat screenWidth = ([[UIScreen mainScreen] bounds].size.width);
    CGFloat width = floor(screenWidth / sectionRows);
    CGFloat height = 74;
    return CGSizeMake(width, height);
}

#pragma mark - Property Method

- (void)setModel:(id<ZFCollectionCellDatasourceProtocol>)model
{
    _model = model;
    
    if ([_model isKindOfClass:[ZFAccountCategoryModel class]]) {
        ZFAccountCategoryModel *categoryModel = _model;
        [self.enterButton setImage:[UIImage imageNamed:categoryModel.imageName] forState:UIControlStateNormal];
        [self.enterButton showShoppingCarsBageValue:[ZFToString(categoryModel.badgeNum) integerValue]
                                        bageBgColor:ZFCOLOR_WHITE
                                      bageTextColor:ZFC0xFE5269()
                                    bageBorderWidth:.5f
                                    bageBorderColor:ZFC0xFE5269()];
        self.nameLabel.text = categoryModel.title;
    }
}

- (UIButton *)enterButton {
    if (!_enterButton) {
        _enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _enterButton.userInteractionEnabled = NO;
        [_enterButton setTitleColor:ZFCOLOR(153, 153, 153, 1.f) forState:UIControlStateNormal];
        _enterButton.titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _enterButton;
}

-(UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 1;
            label.textColor = ZFC0x999999();
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _nameLabel;
}

@end
