//
//  ZFGeshopSiftListHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2019/11/7.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopSiftListHeaderView.h"
#import "ZFGeshopSectionModel.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "BigClickAreaButton.h"
#import "UIImage+ZFExtended.h"
#import "SystemConfigUtils.h"

@interface ZFGeshopSiftListHeaderView ()
@property (nonatomic, strong) YYLabel               *titleLabel;
@property (nonatomic, strong) BigClickAreaButton    *arrowImgButton;
@end

@implementation ZFGeshopSiftListHeaderView

#pragma mark - Init Method
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureSubViews];
        [self autoLayoutSubViews];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selecteCurrentSiftItem)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - Initialize
- (void)configureSubViews {
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.arrowImgButton];
}

- (void)autoLayoutSubViews {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(16);
        make.centerY.equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-60);
    }];
    
    [self.arrowImgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-20);
    }];
}

#pragma mark - Gesture Handle
- (void)selecteCurrentSiftItem {
    if (self.selecteCurrentSiftBlock) {
        self.selecteCurrentSiftBlock(self.siftItemModel);
    }
}

- (void)touchArrowImgAction {
    if (self.touchArrowImgBlock) {
        self.touchArrowImgBlock(self.siftItemModel);
    }
}

#pragma mark - Setter

- (void)setSiftItemModel:(ZFGeshopSiftItemModel *)siftItemModel {
    _siftItemModel = siftItemModel;
    
    self.titleLabel.text = ZFToString(siftItemModel.item_title);
    
    UIImage *image = nil;
    if (siftItemModel.child_item.count>0) {
        image = siftItemModel.hasOpenChild ? [UIImage imageNamed:@"search_list_minus"] : [UIImage imageNamed:@"search_list_plus"];
    } else {
        image = siftItemModel.isCurrentSelected ? [[UIImage imageNamed:@"refine_select"] imageWithColor:ZFC0xFE5269()] : nil;
    }
    [self.arrowImgButton setImage:image forState:UIControlStateNormal];
    [self setNeedsDisplay];
}

#pragma mark - Rewrite Methods
-(void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = nil;
    [self.arrowImgButton setImage:nil forState:UIControlStateNormal];
}

#pragma mark - Public Methods
+ (NSString *)setIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - Getter
- (YYLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [YYLabel new];
        BOOL isAr = ([SystemConfigUtils isRightToLeftShow]) ? YES : NO;
        _titleLabel.textAlignment = isAr ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _titleLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _titleLabel.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    }
    return _titleLabel;
}

- (BigClickAreaButton *)arrowImgButton {
    if (!_arrowImgButton) {
        _arrowImgButton = [[BigClickAreaButton alloc] init];
        _arrowImgButton.clickAreaRadious = 60;
        [_arrowImgButton addTarget:self action:@selector(touchArrowImgAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _arrowImgButton;
}

@end
