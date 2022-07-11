//
//  DiscoveryTopicView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDiscoveyTopicsView.h"

static const NSInteger kDiscoverTopicViewButtonTag = 2040; // 中部View Item 的tag

@implementation OSSVDiscoveyTopicsView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)makeTopicViewsWithTitleArray:(NSArray *)titleArray imageArray:(NSArray *)imageArray {
    
    if(titleArray.count > 0) {
        
        // 先将其子视图删除
        self.hidden = NO;
        for (UIView *subView in self.subviews) {
            [subView removeFromSuperview];
        }
        // 再布局
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:titleArray.count];
        for (int i = 0; i < titleArray.count; i++) {
            if (i < 4) {
                // 如果是5个的情况下，是不添加的
                UIButton *buttonView = [self makeCustomButtonWithTitle:titleArray[i] image:imageArray[i]];
                buttonView.backgroundColor = [UIColor clearColor];
                buttonView.tag = kDiscoverTopicViewButtonTag + i;
                [buttonView addTarget:self action:@selector(didTapTopicItemAction:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:buttonView];
                if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                    [tempArray insertObject:buttonView atIndex:0];
                } else {
                    [tempArray addObject:buttonView];
                }
            }
            
        }
        
        // 如果是一个的titleArray 的情况, 数组的那个方法必须大于1的
        if (titleArray.count == 1) {
            
            [tempArray.firstObject mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mas_centerX);
                make.centerY.equalTo(self.mas_centerY);
                make.top.bottom.equalTo(@(0));
            }];
            return;
        }
        
        /**
         根据titleArray.count 适当调整 space, 主要是针对 2个 - 4个的情况,此处最多4个Item
         */
        CGFloat space = 12 * DSCREEN_WIDTH_SCALE; // 根据设计尺寸换算出来的
        [tempArray mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:0 leadSpacing:space tailSpacing:space];
        [tempArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
         make.top.bottom.equalTo(@(0));
        }];
    }
    else {
        self.hidden = YES;
    }
    
    
}

- (void)didTapTopicItemAction:(UIButton *)button {
    
    NSInteger index = button.tag - kDiscoverTopicViewButtonTag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapTopicViewItemActionAtIndex:)]) {
        [self.delegate tapTopicViewItemActionAtIndex:index];
    }
}

- (UIButton *)makeCustomButtonWithTitle:(NSString *)title image:(NSString *)imageString {
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectZero;
    button.clipsToBounds = YES;
    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleToFill;
    // 为了测试临时判断是网络还是本地  /** CGSizeMake(41, 41) 是产品给的大小 */
    if ([imageString hasPrefix:@"http"]){
        [imageView yy_setImageWithURL:[NSURL URLWithString:imageString]
                          placeholder:[UIImage imageNamed:@"small_placeholder"]
                              options:kNilOptions
                             progress:nil
                            transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                            image = [image yy_imageByResizeToSize:CGSizeMake(41* DSCREEN_WIDTH_SCALE, 41* DSCREEN_WIDTH_SCALE ) contentMode:UIViewContentModeScaleAspectFill];
                                            return image;
                                        }
                           completion:nil];
    }
    else {
        imageView.image = [UIImage imageNamed:imageString];
    }
    imageView.userInteractionEnabled = NO;
    [button addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@(10* DSCREEN_WIDTH_SCALE ));
        make.centerX.mas_equalTo(button.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(41* DSCREEN_WIDTH_SCALE, 41* DSCREEN_WIDTH_SCALE ));
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:11];
    label.textColor = OSSVThemesColors.col_333333;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [button addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(@(-5* DSCREEN_WIDTH_SCALE));
        make.leading.mas_equalTo(@5);
        make.trailing.mas_equalTo(@(-5));
        make.top.equalTo(imageView.mas_bottom).mas_equalTo(3* DSCREEN_WIDTH_SCALE);
    }];
    
    return button;
}


@end
