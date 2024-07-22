//
//  ZFCMSTextModuleCell.m
//  ZZZZZ
//
//  Created by YW on 2018/12/12.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCMSTextModuleCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFBannerTimeView.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCMSTextModuleCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel   *textLabel;
@end

@implementation ZFCMSTextModuleCell

+ (ZFCMSTextModuleCell *)reusableTextModuleCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    [self.contentView addSubview:self.textLabel];
}

- (void)zfAutoLayoutView {
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - Setter

- (void)setSectionModel:(ZFCMSSectionModel *)sectionModel {
    _sectionModel = sectionModel;
    
    self.textLabel.font = ZFFontSystemSize(sectionModel.attributes.text_size);
    self.textLabel.text = ZFToString(sectionModel.attributes.text);
    self.textLabel.textColor = sectionModel.attributes.textColor;
    self.textLabel.backgroundColor = sectionModel.bgColor;
    self.contentView.backgroundColor = sectionModel.bgColor;
    
    // 配置文案对齐位置
    ZFCMSModulePosition position = [sectionModel.attributes.text_align integerValue];
    if (position == 4) { //居左
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(sectionModel.padding_left + sectionModel.attributes.padding_left);
        }];
        
    } else if (position == 6) { //居右
        self.textLabel.textAlignment = NSTextAlignmentRight;
        [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-(sectionModel.padding_right + sectionModel.attributes.padding_right));
        }];
        
    } else {  //5:默认居中
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.centerX.equalTo(self.contentView.mas_centerX);
        }];
    }
}

#pragma mark - Getter

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = ZFFontSystemSize(14);
        _textLabel.backgroundColor = ZFCOLOR_WHITE;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.preferredMaxLayoutWidth = KScreenWidth - 20;
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

@end
