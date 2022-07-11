//
//  OSSVDetaillHtmlArrView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetaillHtmlArrView.h"
#import "SDCycleScrollView.h"

#import "STLCatrActivityModel.h"

#define kGoodsDetailHtmlMaxWidth SCREEN_WIDTH - 12*2 - 12 - 24 - 12 - 4
@interface OSSVDetaillHtmlArrView ()<SDCycleScrollViewDelegate,UIGestureRecognizerDelegate>

//@property (nonatomic, strong) UIButton                 *saleMarkBtn;
@property (nonatomic, strong) SDCycleScrollView        *topCycleView;
@property (nonatomic, strong) YYAnimatedImageView      *rightArrow; // 右边箭头
@property (nonatomic, strong) UIView                   *horizontalLine; // 横线

@property (nonatomic, strong) NSMutableArray           *cycleTitlesArray;
@property (nonatomic, assign) NSInteger                currentIndex;

@end

@implementation OSSVDetaillHtmlArrView

+ (CGFloat)computeContentWidth:(NSArray *)contents {
    
    CGSize titleSize = CGSizeZero;
    for (OSSVBundleActivityModel *model in contents) {
        //标题内容宽度
        UIFont *textFont = [UIFont boldSystemFontOfSize:kGoodsDetailFullReducFontSize];
        NSDictionary *attributes = @{NSFontAttributeName: textFont};
        
        CGSize tempSize = [STLToString(model.discountDesc) boundingRectWithSize:CGSizeMake(1000, 20)
                                                                          options:(NSStringDrawingUsesLineFragmentOrigin)
                                                                       attributes:attributes
                                                                          context:nil].size;

        if (tempSize.width > titleSize.width) {
            titleSize.width = tempSize.width;
        }
        
    }
    return titleSize.width + 5;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = OSSVThemesColors.col_FFFFFF;
        self.currentIndex = 0;
        
//        [self addSubview:self.saleMarkBtn];
        [self addSubview:self.rightArrow];
        [self addSubview:self.horizontalLine];
        [self addSubview:self.topCycleView];
        
//        [self.saleMarkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
//            make.centerY.mas_equalTo(self.mas_centerY);
//            make.height.mas_equalTo(17);
//        }];
//
//        //设置优先完整显示
//        [self.saleMarkBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-14);
        }];
        
        
        //CGFloat width = kGoodsDetailHtmlMaxWidth;
        [self.topCycleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
            make.top.bottom.mas_equalTo(self);
            make.trailing.mas_equalTo(self.rightArrow.mas_leading).offset(-4);
            //make.width.mas_equalTo(width);
        }];
                

        [self.horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom);
            if (APP_TYPE == 3) {
                make.leading.equalTo(14);
                make.trailing.equalTo(-14);
            }else{
                make.leading.trailing.mas_equalTo(self);
            }
            
            make.height.mas_equalTo(0.6);
        }];

    }
    return self;
}

- (void)setHtmlTitle:(NSArray *)htmlTitles specialUrl:(NSString *)url contentWidth:(CGFloat)contentWidth {
    
    if (contentWidth <= 0) {
        contentWidth = 0;
    }
    _rightArrow.hidden =  YES;
    
    self.topCycleView.hidden = YES;;

    if ([htmlTitles isKindOfClass:[NSArray class]]) {

        self.topCycleView.hidden = htmlTitles.count > 0 ? NO : YES;;

        if (htmlTitles.count > 0) {
            
            OSSVBundleActivityModel *firstModel = htmlTitles.firstObject;
            if ([firstModel.activeId integerValue] > 0) {
                _rightArrow.hidden = NO;
            }
            //NSHTMLTextDocumentType 要在主线程刷
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.cycleTitlesArray removeAllObjects];
                for (OSSVBundleActivityModel *mdel in htmlTitles) {
                    
                    if (mdel.discountRangeAttribute) {
                        [self.cycleTitlesArray addObject:mdel.discountRangeAttribute];
                    } else {
                        UIFont *font=[UIFont boldSystemFontOfSize:kGoodsDetailFullReducFontSize];
                        NSMutableAttributedString *componets=[[NSMutableAttributedString alloc] init];
                        NSDictionary *optoins=@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
                                                NSFontAttributeName:font};
                        NSData *data=[STLToString(mdel.discountRange) dataUsingEncoding:NSUnicodeStringEncoding];
                        
                        if (data.length <= 0) {
                            continue;
                        }
                        
                        NSAttributedString *textPart=[[NSAttributedString alloc] initWithData:data
                                                                                      options:optoins
                                                                           documentAttributes:nil
                                                                                        error:nil];
                        
                        [componets appendAttributedString:textPart];
                        mdel.discountRangeAttribute = componets;
                        [self.cycleTitlesArray addObject:componets];
                    }
                }
                
                self.topCycleView.titlesAttrGroup = self.cycleTitlesArray;
                self.topCycleView.autoScroll = self.cycleTitlesArray.count > 1 ? YES : NO;
            });
        }
    }
}


#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"---点击了第%ld张图片", (long)index);
    if (self.activityBlock) {
        self.activityBlock(index);
    }
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index {
    self.currentIndex = index;
}

#pragma mark - action

- (void)actionTip:(UIButton *)sender {
    if (self.activityTipBlock) {
        self.activityTipBlock(0);
    }
}

#pragma mark - LazyLoad

- (NSMutableArray *)cycleTitlesArray {
    if (!_cycleTitlesArray) {
        _cycleTitlesArray = [[NSMutableArray alloc] init];
    }
    return _cycleTitlesArray;
}


- (UIView *)horizontalLine {
    if (!_horizontalLine) {
        _horizontalLine = [[UIView alloc] init];
        _horizontalLine.backgroundColor = APP_TYPE == 3 ? OSSVThemesColors.col_E1E1E1 :
        OSSVThemesColors.col_F6F6F6;
    }
    return _horizontalLine;
}

- (YYAnimatedImageView *)rightArrow {
    if (!_rightArrow) {
        _rightArrow = [[YYAnimatedImageView alloc] init];
        _rightArrow.image = [UIImage imageNamed:@"goods_arrow"];
        [_rightArrow convertUIWithARLanguage];
        _rightArrow.hidden = YES;
    }
    return _rightArrow;
}

- (SDCycleScrollView *)topCycleView {
    if (!_topCycleView) {
        _topCycleView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(12, 0, SCREEN_WIDTH - 12*2-14*2 -16,44) delegate:self placeholderImage:nil];
        _topCycleView.scrollDirection = UICollectionViewScrollDirectionVertical;
        _topCycleView.onlyDisplayText = YES;
        _topCycleView.titleLabelBackgroundColor = [UIColor clearColor];
        _topCycleView.titleLabelTextFont = [UIFont boldSystemFontOfSize:kGoodsDetailFullReducFontSize];
        _topCycleView.titleLabelTextColor = [OSSVThemesColors col_0D0D0D];
        _topCycleView.titleLabelHeight = 40;
        _topCycleView.titleLabelNmberOfLines = 1;
//        [_topCycleView disableScrollGesture];
        _topCycleView.backgroundColor = [UIColor clearColor];
        _topCycleView.hidden = YES;
    }
    return _topCycleView;
}

@end
