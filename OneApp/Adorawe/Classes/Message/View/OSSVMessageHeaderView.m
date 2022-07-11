//
//  OSSVMessageHeaderView.m
// XStarlinkProject
//
//  Created by odd on 2020/8/6.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVMessageHeaderView.h"
#import "OSSVMessageMenuItemView.h"

@interface OSSVMessageListModel()

@property (nonatomic, strong) OSSVMessageListModel           *model;

@end

@implementation OSSVMessageHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self stlInitView];
        [self stlAutoLayoutView];
    }
    return self;
}


- (void)stlInitView {
    
    self.backgroundColor = [OSSVThemesColors stlWhiteColor];
    [self addSubview:self.bottomGrayView];
    [self addSubview:self.headBgView];
    [self addSubview:self.menuBgView];
    [self addSubview:self.messageLabel];
}

+ (CGFloat)mssageHeadercontentH {
    return 84;
}
- (void)stlAutoLayoutView {
    [self.menuBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
        make.height.mas_equalTo(84);
        make.top.mas_equalTo(self.headBgView.mas_top);
    }];
}

- (void)actionItem:(OSSVMessageMenuItemView *)itemView {
    
    NSArray *subViews = self.menuBgView.subviews;
    for (UIView *items in subViews) {
        if ([items isKindOfClass:[OSSVMessageMenuItemView class]]) {
            OSSVMessageMenuItemView *view = (OSSVMessageMenuItemView *)items;
            
            if ([view isEqual:itemView]) {
                [view showLine:YES];
            } else {
                [view showLine:NO];
            }
        }
    }
    if (self.tapItemBlock) {
        self.tapItemBlock(itemView.messageModel,itemView.tag-10000);
    }
}

- (void)updateModel:(OSSVMessageListModel *)model index:(NSInteger)index isFirst:(BOOL)first {
    
    self.menuBgView.hidden = NO;
    [self.menuBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (model.bubbles.count <= 0) {
        return;
    }
    
    OSSVMessageMenuItemView * tempView;
    CGFloat itemW = (SCREEN_WIDTH - 24) / model.bubbles.count;
    for (int i=0; i<model.bubbles.count; i++) {
        
        OSSVMessageMenuItemView * itemView = [[OSSVMessageMenuItemView alloc] initWithFrame:CGRectZero];
        [itemView addTarget:self action:@selector(actionItem:) forControlEvents:UIControlEventTouchUpInside];
        
        OSSVMessageModel *messageModel = model.bubbles[i];
        if (first && i==0) {
            messageModel.count = @"";
        }
        
        if (i == index) {
            [itemView showLine:YES];
        }
        itemView.messageModel = messageModel;
        itemView.tag = 10000 + i;
        [self.menuBgView addSubview:itemView];
        
        if (tempView) {
            
            if (i== 3) {
                [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.mas_equalTo(tempView.mas_trailing);
                    make.trailing.mas_equalTo(self.menuBgView.mas_trailing);
                    make.top.mas_equalTo(self.menuBgView.mas_top).offset(8);
                    make.bottom.mas_equalTo(self.menuBgView.mas_bottom).offset(-8);
                    make.width.mas_equalTo(tempView.mas_width);
                }];
                break;
            }
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(tempView.mas_trailing);
                make.top.mas_equalTo(self.menuBgView.mas_top).offset(8);
                make.bottom.mas_equalTo(self.menuBgView.mas_bottom).offset(-8);
                make.width.mas_equalTo(tempView.mas_width);
            }];
        }
        else {

            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.menuBgView.mas_leading);
                make.top.mas_equalTo(self.menuBgView.mas_top).offset(8);
                make.bottom.mas_equalTo(self.menuBgView.mas_bottom).offset(-8);
                make.width.mas_equalTo(itemW);
            }];
        }
        tempView = itemView;
    }
}


- (UIView *)headBgView {
    if (!_headBgView) {
        _headBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _headBgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _headBgView;
}

- (UIView *)bottomGrayView {
    if (!_bottomGrayView) {
        _bottomGrayView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomGrayView.backgroundColor = [OSSVThemesColors col_F5F5F5];
    }
    return _bottomGrayView;
}

- (UIView *)menuBgView {
    if (!_menuBgView) {
        _menuBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 24, 84)];
        _menuBgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
//        _menuBgView.layer.shadowOpacity = 0.2;//不透明度
//        _menuBgView.layer.shadowRadius = 2.0;//半径
//        _menuBgView.layer.shadowOffset = CGSizeMake(0, 1);//偏移距离
//        _menuBgView.layer.masksToBounds = NO; //裁剪
//        _menuBgView.layer.shouldRasterize = YES;//设置缓存 仅复用时设置此选项
//        _menuBgView.layer.rasterizationScale = [UIScreen mainScreen].bounds.size.width / 375.0;//设置对应比例，防止cell出现模糊和锯齿
        _menuBgView.hidden = YES;
    }
    return _menuBgView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _messageLabel.textColor = [OSSVThemesColors col_262626];
        _messageLabel.font = [UIFont boldSystemFontOfSize:18];
        _messageLabel.text = STLLocalizedString_(@"Message", nil);
    }
    return _messageLabel;
}


@end
