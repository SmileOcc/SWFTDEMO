//
//  ZFCommunityPostDetailDescriptCollectionReusableView.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostDetailDescriptCollectionReusableView.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

#define kTagBeginTag   9999
@interface ZFCommunityPostDetailDescriptCollectionReusableView ()

@property (nonatomic, strong) UILabel          *contentLabel;
@property (nonatomic, strong) UIImageView      *linkMarkImageView;
@property (nonatomic, strong) UILabel          *deeplinkLabel;
@property (nonatomic, strong) UIButton         *deeplinkButton;


@property (nonatomic, strong) UILabel          *readLabel;
@property (nonatomic, strong) UILabel          *publishLabel;
@property (nonatomic, strong) UIView           *separetorView;

@property (nonatomic, strong) NSMutableArray   *tagControlArray;
@property (nonatomic, copy) NSString           *deeplinkUrlString;


@end

@implementation ZFCommunityPostDetailDescriptCollectionReusableView

+ (ZFCommunityPostDetailDescriptCollectionReusableView *)descriptWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    NSString *Identify = NSStringFromClass([self class]);
    [collectionView registerClass:[self class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:Identify];
    ZFCommunityPostDetailDescriptCollectionReusableView *descriptHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:Identify forIndexPath:indexPath];
    return descriptHeaderView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        [self layout];
        self.tagControlArray = [NSMutableArray new];
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.contentLabel];
    [self addSubview:self.linkMarkImageView];
    [self addSubview:self.deeplinkLabel];
    [self addSubview:self.deeplinkButton];
    [self addSubview:self.readLabel];
    [self addSubview:self.publishLabel];
    [self addSubview:self.separetorView];
}

- (void)layout {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).offset(12.0);
        make.top.mas_equalTo(self).offset(12.0);
        make.trailing.mas_equalTo(self).offset(-12.0);
        make.height.mas_equalTo(0.0);
    }];
    
    [self.linkMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).offset(12.0);
        make.top.mas_equalTo(self.contentLabel.mas_bottom);
        make.height.mas_equalTo(0.0);
        make.width.mas_equalTo(16);
    }];
    
    [self.deeplinkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.linkMarkImageView.mas_trailing).offset(5.0);
        make.centerY.mas_equalTo(self.linkMarkImageView.mas_centerY);
        make.trailing.mas_equalTo(self).offset(-12.0);
    }];
    
    [self.deeplinkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.linkMarkImageView);
        make.trailing.mas_equalTo(self.deeplinkLabel.mas_trailing);
        make.centerY.mas_equalTo(self.linkMarkImageView.mas_centerY);
        make.height.mas_equalTo(35);
    }];
    
    [self.readLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).offset(12.0);
        make.height.mas_equalTo(14.0);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-12.0);
    }];
    
    [self.publishLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self).offset(-12.0);
        make.height.mas_equalTo(14.0);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-12.0);
    }];
    
    [self.separetorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).offset(12.0);
        make.trailing.mas_equalTo(self).offset(-12.0);
        make.height.mas_equalTo(MIN_PIXEL);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-MIN_PIXEL);
    }];
}

#pragma mark - event
- (void)keywordTapAction:(UITapGestureRecognizer *)tapGesture {
    id touchView = tapGesture.view;
    if ([touchView isKindOfClass:[UILabel class]]) {
        UILabel *label = touchView;
        if ([label.text length] > 0) {
            if (self.tagActionHandle) {
                self.tagActionHandle(label.text);
            }
        }
    }
}

- (void)actionDeeplink:(UIButton *)sender {
    if (self.deeplinkHandle) {
        self.deeplinkHandle(self.deeplinkUrlString);
    }
}

#pragma mark - getter/setter
- (void)setContentString:(NSString *)contentString {
    if ([contentString length] > 0) {
        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        CGSize size = [contentString boundingRectWithSize:CGSizeMake(KScreenWidth - 24.0, MAXFLOAT)
                                                  options:options attributes:@{NSFontAttributeName: self.contentLabel.font}
                                                  context:nil].size;
        CGFloat height         = round(size.height) + 1;
        self.contentLabel.text = contentString;
        [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
    }
}

- (void)setDeepLinkTitle:(NSString *)deeplinkTitle url:(NSString *)deeplinkUrl {
    self.deeplinkUrlString = deeplinkUrl;
    
    if ([deeplinkUrl length] > 0) {
        self.deeplinkButton.hidden = NO;
        self.linkMarkImageView.hidden = NO;
        if (ZFIsEmptyString(deeplinkTitle)) {
            deeplinkTitle = ZFLocalizedString(@"Community_post_detail_link", nil);
        }
        
        self.deeplinkLabel.text = deeplinkTitle;
        
        CGFloat space = 6.0;
        if (ZFIsEmptyString(self.contentLabel.text)) {
            space = 0;
        }
        
        [self.linkMarkImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(space);
            make.height.mas_equalTo(16);
        }];
        
        
    } else {
        self.deeplinkButton.hidden = YES;
        self.linkMarkImageView.hidden = YES;
        self.deeplinkLabel.text = nil;
        
        CGFloat space = 0.0;
        if (ZFIsEmptyString(self.contentLabel.text)) {
            space = -12.0;
        }
        
        [self.linkMarkImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(space);
            make.height.mas_equalTo(0);
        }];
        
    }
    
}



- (void)setTagArray:(NSArray *)tagArray {
    // 因为只有一行，防止重新载入
    if (self.tagControlArray.count > 0) {
        return;
    }
    
    //isNormal 防止包是阿语环境、英语环境，第一个preLabel.x 是从左 或从右开始
    BOOL isNormal = YES;
    for (NSInteger i = 0; i < tagArray.count; i++) {
        UILabel *preLabel = self.tagControlArray.count > 0  ? self.tagControlArray[i - 1] : nil;
        if (i == 1) {
            YWLog(@"-----first-----preX: %f",preLabel.x);
            if (preLabel.x > 13) {
                isNormal = NO;
            }
        }
        NSString *keyString = tagArray[i];
        UILabel *keyLabel  = [[UILabel alloc] init];
        keyLabel.font      = [UIFont systemFontOfSize:12.0];
        keyLabel.textColor = ZFC0x3D76B9();
        keyLabel.text      = tagArray[i];
        keyLabel.tag       = kTagBeginTag + i;
        keyLabel.userInteractionEnabled = YES;
        [self addSubview:keyLabel];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(keywordTapAction:)];
        [keyLabel addGestureRecognizer:tapGesture];
        
        CGSize size = [keyString sizeWithAttributes:@{NSFontAttributeName: keyLabel.font}];
        if (size.width > (KScreenWidth - 24.0)) {
            size.width = KScreenWidth - 24.0;
        }
        if (preLabel == nil) {
//            if (self.contentLabel.text.length > 0) {
                [keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.linkMarkImageView.mas_bottom).offset(12.0);
                    make.leading.mas_equalTo(self).offset(12.0);
                    make.height.mas_equalTo(14.0);
                    make.width.mas_equalTo(size.width + 1);
                }];
//            } else {
//                [keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.top.mas_equalTo(self.linkMarkImageView.mas_bottom).offset(12.0);
//                    make.leading.mas_equalTo(self).offset(12.0);
//                    make.height.mas_equalTo(14.0);
//                    make.width.mas_equalTo(size.width + 1);
//                }];
//            }
        } else {
            
            CGFloat ar = 0;
            BOOL isRow = NO;
            YWLog(@"---preX: %f  width: %f",preLabel.x,size.width);

            //occ阿语适配
            //isNormal 防止包是阿语环境、英语环境，第一个preLabel.x 是从左 或从右开始
            if ([SystemConfigUtils isRightToLeftShow]) {
                if (isNormal) {
                    ar = preLabel.x + preLabel.width + 12 + size.width + 12;
                    isRow = ar >= KScreenWidth ? YES : NO;
                } else {
                    ar = preLabel.x - size.width - 12 - 12;
                    isRow = ar >= 0 ? NO : YES;
                }
                
            } else {
                if (isNormal) {
                    ar = preLabel.x + preLabel.width + 12 + size.width + 12;
                    isRow = ar >= KScreenWidth ? YES : NO;
                } else {
                    ar = preLabel.x - size.width - 12 - 12;
                    isRow = ar >= 0 ? NO : YES;
                }
                
            }
            
            if (isRow) {
                [keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(preLabel.mas_bottom).offset(6.0f);
                    make.leading.mas_equalTo(self).offset(12.0);
                    make.height.mas_equalTo(14.0);
                    make.width.mas_equalTo(size.width + 1);
                }];
            } else {
                [keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(preLabel.mas_top);
                    make.leading.mas_equalTo(preLabel.mas_trailing).offset(12.0);
                    make.height.mas_equalTo(14.0);
                    make.width.mas_equalTo(size.width + 1);
                }];
            }
        }
        [self layoutIfNeeded];
        [self.tagControlArray addObject:keyLabel];
    }
}

- (void)setReadNumber:(NSString *)readNumber {
    self.readLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"community_topicdetail_views", nil), readNumber];
}

- (void)setPublishTime:(NSString *)time {
    self.publishLabel.text = [NSStringUtils timeLapse:[time integerValue]];
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel           = [[UILabel alloc] init];
        _contentLabel.textColor = [UIColor colorWithHex:0x2D2D2D];
        _contentLabel.font      = [UIFont systemFontOfSize:14.0];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UIImageView *)linkMarkImageView {
    if (!_linkMarkImageView) {
        _linkMarkImageView = [[UIImageView alloc] init];
        _linkMarkImageView.image = [UIImage imageNamed:@"community_link"];
    }
    return _linkMarkImageView;
}

- (UILabel *)deeplinkLabel {
    if (!_deeplinkLabel) {
        _deeplinkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _deeplinkLabel.textColor = ZFC0xFE5269();
        _deeplinkLabel.font      = [UIFont systemFontOfSize:14.0];
    }
    return _deeplinkLabel;
}

- (UIButton *)deeplinkButton {
    if (!_deeplinkButton) {
        _deeplinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deeplinkButton.hidden = YES;
        [_deeplinkButton addTarget:self action:@selector(actionDeeplink:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deeplinkButton;
}

- (UILabel *)readLabel {
    if (!_readLabel) {
        _readLabel           = [[UILabel alloc] init];
        _readLabel.textColor = [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1.0];
        _readLabel.font      = [UIFont systemFontOfSize:12.0];
    }
    return _readLabel;
}

- (UILabel *)publishLabel {
    if (!_publishLabel) {
        _publishLabel           = [[UILabel alloc] init];
        _publishLabel.textColor = [UIColor colorWithRed:204.0 / 255.0 green:204.0 / 255.0 blue:204.0 / 255.0 alpha:1.0];
        _publishLabel.font      = [UIFont systemFontOfSize:12.0];
    }
    return _publishLabel;
}

- (UIView *)separetorView {
    if (!_separetorView) {
        _separetorView = [[UIView alloc] init];
        _separetorView.backgroundColor = [UIColor colorWithHex:0xDDDDDD];
        _separetorView.hidden = YES;
    }
    return _separetorView;
}

@end
