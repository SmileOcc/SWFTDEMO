//
//  ZFCommuntityGestureTableView.m
//  ZZZZZ
//
//  Created by YW on 2018/4/24.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommuntityGestureTableView.h"
#import "ZFThemeManager.h"
#import "UIView+LayoutMethods.h"
#import "NSObject+Swizzling.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "UIView+ZFViewCategorySet.h"

@implementation ZFCommuntityGestureTableView

/**
 * 此方法是支持多手势，当滑动子控制器中的scrollView时，外层 scrollView 也能接收滑动事件
 * 当前类仅供社区个人中心三个列表使用
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end


@implementation ZFCommuntityCollectionView

/**
 * 此方法是支持多手势，当滑动子控制器中的scrollView时，外层 scrollView 也能接收滑动事件
 * 当前类仅供社区个人中心三个列表使用
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end


@interface ZFCountryTableView()
@property (nonatomic, strong) UIView *zfSectionIndexView;
@property (nonatomic, strong) UIView *selectedFloatView;
@property (nonatomic, strong) UIImageView *indexImageView;
@property (nonatomic, strong) UILabel *bigIndexLabel;
@property (nonatomic, strong) UILabel *smallIndexLabel;
@end

@implementation ZFCountryTableView

+(void)load
{
    [[self class] swizzleMethod:NSSelectorFromString(@"_sectionIndexTouchesBegan:") swizzledSelector:@selector(zf_sectionIndexTouchesBegan:)];
    
    [[self class] swizzleMethod:NSSelectorFromString(@"_sectionIndexTouchesEnded:") swizzledSelector:@selector(zf_sectionIndexTouchesEnded:)];
}

/**
 * 获取到TableViewIndex
 */
- (UIView *)zfSectionIndexView {
    if (!_zfSectionIndexView) {
        UIView *sectionIndexView = (UIView*)self.subviews.lastObject;
        if(![NSStringFromClass([sectionIndexView class]) isEqualToString:@"UITableViewIndex"]){
            for(UIView * sview in self.subviews){
                if([NSStringFromClass([sview class]) isEqualToString:@"UITableViewIndex"]){
                    sectionIndexView = sview;
                    break;
                }
            }
        }
        _zfSectionIndexView = sectionIndexView;
    }
    return _zfSectionIndexView;
}

- (UIView *)selectedFloatView {
    if(!_selectedFloatView){
        _selectedFloatView = [[UIView alloc] init];
        _selectedFloatView.frame = CGRectMake(-58, 0, 40, 40);
        _selectedFloatView.backgroundColor = [UIColor clearColor];
        [self.zfSectionIndexView addSubview:_selectedFloatView];
        
        
        UIImage *indexImage = ZFImageWithName(@"account_country_selectedPop");
        UIImageView *indexImageView = [[UIImageView alloc] initWithImage:indexImage];
        indexImageView.backgroundColor = [UIColor clearColor];
        indexImageView.hidden = YES;
        [_selectedFloatView addSubview:indexImageView];
        self.indexImageView = indexImageView;
        
        
        UILabel *bigIndexLabel = [[UILabel alloc] init];
        bigIndexLabel.frame = CGRectMake(-2, 0, 40, 40);
        bigIndexLabel.backgroundColor = [UIColor clearColor];
        bigIndexLabel.layer.cornerRadius = 40/2;
        bigIndexLabel.layer.masksToBounds = YES;
        bigIndexLabel.font = ZFFontBoldSize(16);
        bigIndexLabel.textColor = [UIColor whiteColor];
        bigIndexLabel.textAlignment = NSTextAlignmentCenter;
        [indexImageView addSubview:bigIndexLabel];
        self.bigIndexLabel = bigIndexLabel;
        
        
        CGFloat textHeight = 14;
        UILabel *smallIndexLabel = [[UILabel alloc] init];
        smallIndexLabel.frame = CGRectMake(68-10, (40-14)/2, textHeight, textHeight);
        smallIndexLabel.backgroundColor = ZFC0xFE5269();
        smallIndexLabel.layer.cornerRadius = textHeight/2;
        smallIndexLabel.layer.masksToBounds = YES;
        smallIndexLabel.font = ZFFontSystemSize(10);
        smallIndexLabel.textColor = [UIColor whiteColor];
        smallIndexLabel.textAlignment = NSTextAlignmentCenter;
        [_selectedFloatView addSubview:smallIndexLabel];
        self.smallIndexLabel = smallIndexLabel;
    }
    return _selectedFloatView;
}

/**
 * 刷新浮动SelectedFloatView
 */
- (void)refreshFloatIndexView:(NSString *)indexText index:(NSInteger)index
{
    if (!self.zfSectionIndexView) return;
    
    CGFloat textHeight = 13.5; //_verticalTextHeightEstimate
    NSInteger indexCount = [self.dataSource sectionIndexTitlesForTableView:self].count;
    
    CGFloat padingHeight = (self.zfSectionIndexView.height - textHeight * indexCount) / 2;
    self.selectedFloatView.y = padingHeight + index * textHeight - 12;
    self.bigIndexLabel.text = indexText;
    self.smallIndexLabel.text = indexText;
    self.currentTitle = indexText;
}

- (void)zf_sectionIndexTouchesBegan:(UIView *)tableViewIndexView
{
    [self zf_sectionIndexTouchesBegan:tableViewIndexView];
    if (self.zfSectionIndexView) {
        self.indexImageView.hidden = NO;
    }
    [self.window endEditing:YES];
}

- (void)zf_sectionIndexTouchesEnded:(UIView *)tableViewIndexView
{
    [self zf_sectionIndexTouchesEnded:tableViewIndexView];
    if (self.zfSectionIndexView) {
        self.indexImageView.hidden = YES;
    }
}

@end
