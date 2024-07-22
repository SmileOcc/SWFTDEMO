//
//  ZFCommunityHomeLookBookCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeLookBookCCell.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFInitViewProtocol.h"
#import "NSString+Extended.h"
#import "UICollectionViewCell+ZFExtension.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"

@interface ZFCommunityHomeLookBookCCell ()<ZFInitViewProtocol>

@end

@implementation ZFCommunityHomeLookBookCCell
@synthesize favesItemModel = _favesItemModel;

+ (NSString *)queryReuseIdentifier{
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol Delegate

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    
    [self.contentView addSubview:self.bgContentView];
    [self.bgContentView addSubview:self.picImageView];
    [self.bgContentView addSubview:self.maskView];
    [self.maskView addSubview:self.contentLab];
    [self.maskView addSubview:self.numLab];
    [self.maskView addSubview:self.viewsLab];
    [self.contentView addSubview:self.lookMarkButton];
    
    //设置cell投影圆角效果
    [self setShadowAndCornerCell];
}

- (void)zfAutoLayoutView {
    
    [self.bgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    //图片高度
    CGFloat imageShowHeight = self.favesItemModel.twoColumnImageHeight;
    if (imageShowHeight == 0.0) {
        imageShowHeight = kCommunityHomeWaterfallWidth;
    }
    [self.picImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.bgContentView);
        make.height.mas_equalTo(@(imageShowHeight));
    }];
    
    [self.lookMarkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(6);
        make.trailing.offset(0);
    }];
    
    //图片底下所有子控件的高度
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.picImageView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.bgContentView);
        make.bottom.mas_equalTo(self.bgContentView);
    }];
    
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.maskView.mas_top).offset(6);
        make.leading.mas_equalTo(self.maskView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.maskView.mas_trailing).offset(-12);
    }];
    
    //浏览数Views
    [self.numLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLab.mas_bottom).offset(7);
        make.leading.mas_equalTo(self.maskView.mas_leading).offset(12);
        make.bottom.mas_equalTo(self.maskView.mas_bottom).offset(-12);
    }];
    
    [self.viewsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLab.mas_bottom).offset(7);
        make.leading.mas_equalTo(self.numLab.mas_trailing).offset(2);
        make.bottom.mas_equalTo(self.maskView.mas_bottom).offset(-12);
        make.trailing.mas_equalTo(self.bgContentView.mas_trailing).offset(-2);
    }];
    
    [self.viewsLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.numLab setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.numLab setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - Property Method

- (ZFCommunityFavesItemModel *)favesItemModel {
    return _favesItemModel;
}

- (void)setFavesItemModel:(ZFCommunityFavesItemModel *)favesItemModel {
    _favesItemModel = favesItemModel;
    
    //图片高度
    CGFloat imageShowHeight = self.favesItemModel.twoColumnImageHeight;
    if (imageShowHeight == 0.0) {
        imageShowHeight = kCommunityHomeWaterfallWidth;
    }
    [self.picImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(imageShowHeight));
    }];
    
    //图片
    if (!self.favesItemModel.randomColor) {
        self.favesItemModel.randomColor = [UIColor colorWithHexString:[ZFThemeManager randomColorString:nil]] ;
    }
    self.picImageView.backgroundColor = self.favesItemModel.randomColor;

    //图片
    [self.picImageView yy_setImageWithURL:[NSURL URLWithString:_favesItemModel.ios_pic_url]
                                   placeholder:nil];
        
    //lookbook标题
    NSString *contentText = self.favesItemModel.title;
    self.contentLab.text = [contentText replaceBrAndEnterChar];
    
    //浏览数views
    self.numLab.text = ZFToString(self.favesItemModel.formatView_num);
}

- (UIView *)bgContentView {
    if(!_bgContentView){
        _bgContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgContentView.backgroundColor = [UIColor whiteColor];
    }
    return _bgContentView;
}

- (UIImageView *)picImageView {
    if (!_picImageView) {
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _picImageView.backgroundColor = [UIColor whiteColor];
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.userInteractionEnabled = YES;
    }
    return _picImageView;
}

- (UIView *)maskView {
    if(!_maskView){
        _maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
    }
    return _maskView;
}

- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLab.backgroundColor = [UIColor whiteColor];
        _contentLab.numberOfLines = 2;
        _contentLab.font = ZFFontSystemSize(12);
        _contentLab.textColor = ZFC0x2D2D2D();
        CGFloat width = kCommunityHomeWaterfallWidth - 12 * 2;
        _contentLab.preferredMaxLayoutWidth = width;
    }
    return _contentLab;
}

- (UIButton *)lookMarkButton {
    if (!_lookMarkButton) {
        _lookMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIEdgeInsets edge = UIEdgeInsetsMake(0, 10, 0, 0);
        _lookMarkButton.backgroundColor = ZFC0xFE5269();
//        [_lookMarkButton setBackgroundImage:[[UIImage imageNamed:@"topbg"] resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        [_lookMarkButton setTitle:ZFLocalizedString(@"Community_shows_lookbook", nil) forState:UIControlStateNormal];
        _lookMarkButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_lookMarkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _lookMarkButton.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
        _lookMarkButton.hidden = YES;
    }
    return _lookMarkButton;
}

- (UILabel *)numLab {
    if (!_numLab) {
        _numLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _numLab.font = ZFFontSystemSize(12);
        _numLab.textColor = ZFC0xFE5269();
    }
    return _numLab;
}

- (UILabel *)viewsLab {
    if (!_viewsLab) {
        _viewsLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _viewsLab.backgroundColor = [UIColor whiteColor];
        _viewsLab.font = ZFFontSystemSize(12);
        _viewsLab.textColor = ZFCOLOR(51, 51, 51, 1.0);
        _viewsLab.text = ZFLocalizedString(@"Community_Big_Views",nil);
    }
    return _viewsLab;
}
@end
