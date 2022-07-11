//
//  OSSVMessageMenuItemView.m
// XStarlinkProject
//
//  Created by odd on 2020/8/6.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVMessageMenuItemView.h"

@implementation OSSVMessageMenuItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self stlInitView];
        [self stlAutoLayoutView];
    }
    return self;
}

- (void)stlInitView {
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.badgeViewNew];
    [self addSubview:self.bottomLineView];
}

- (void)stlAutoLayoutView {
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(6);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-6);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-4);
        make.height.mas_equalTo(18);
    }];
    
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerX.mas_equalTo(self.mas_centerX);
        make.bottom.mas_equalTo(self.titleLabel.mas_top).offset(-2);
    }];
    
    [self.badgeViewNew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.imageView.mas_trailing);
        make.top.mas_equalTo(self.imageView.mas_top);
    }];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.height.mas_equalTo(2);
    }];
    
}

- (void)showLine:(BOOL)show {
    self.bottomLineView.hidden = !show;
}

- (void)setMessageModel:(OSSVMessageModel *)messageModel {
    _messageModel = messageModel;
    
    self.badgeViewNew.badge = STLToString(_messageModel.count);
    NSString *placeImgName = @"onlineCustomService";
    if ([messageModel.type isEqualToString:@"1"]) {
        placeImgName = @"notifications";
    } else if ([messageModel.type isEqualToString:@"2"]) {
        placeImgName = @"logistics";
    } else if ([messageModel.type isEqualToString:@"3"]) {
        placeImgName = @"promotional";
    } else if ([messageModel.type isEqualToString:@"4"]) {
        placeImgName = @"System";
    }
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:messageModel.img_url] placeholder:[UIImage imageNamed:placeImgName]];
    
    self.titleLabel.text = STLToString(_messageModel.title);
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.font = FontWithSize(12);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = [OSSVThemesColors col_0D0D0D];
        _bottomLineView.hidden = YES;
    }
    return _bottomLineView;
}

//- (JSBadgeView *)badgeView {
//    if (!_badgeView) {
//        _badgeView = [[JSBadgeView alloc] initWithParentView:self.imageView alignment:JSBadgeViewAlignmentTopRight];
////        _badgeView.badgeTextFont = [UIFont systemFontOfSize:8];
//        _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(10), -5);
//        _badgeView.badgeBackgroundColor = OSSVThemesColors.col_B62B21;
//    }
//    return _badgeView;
//}

//- (UIImageView *)redDotImgview {
//    if (!_redDotImgview){
//        _redDotImgview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"unreadmessage"]];
//        _redDotImgview.hidden = YES;
//    }
//    return _redDotImgview;
//}

- (STLBadgeViewNew *)badgeViewNew {
    if (!_badgeViewNew) {
        _badgeViewNew = [[STLBadgeViewNew alloc] initWithFrame:CGRectZero];
    }
    return _badgeViewNew;
}

@end
