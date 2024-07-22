//
//  ZFBannerContentView.m
//  ZFBannerView
//
//  Created by YW on 22/11/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBannerContentView.h"
#import <YYWebImage/YYWebImage.h>
#import "YWCFunctionTool.h"
#import "Masonry.h"

@interface ZFBannerContentView ()
@property(nonatomic,strong) YYAnimatedImageView  *contentIMG;
@end

@implementation ZFBannerContentView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self addSubview:self.contentIMG];
        [self.contentIMG mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Public method
- (void)setUserInteraction:(BOOL)enable {
    if (enable) {
        self.contentIMG.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(btnFunc:)];
        [self.contentIMG addGestureRecognizer:tap];
    }
}

-(void)setContentIMGWithStr:(NSString *)str {
    if ([str hasPrefix:@"http"]) {
        UIImage *placeHoldImage = self.placeHoldImage ? : ZFImageWithName(@"loading_product");
        
        [self.contentIMG  yy_setImageWithURL:[NSURL URLWithString:str]
                               placeholder:placeHoldImage
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:nil
                                  transform:nil
                                 completion:nil];
    }else{
        [self.contentIMG setImage:[UIImage imageNamed:str]];
    }
}


- (void)setOffsetWithFactor:(float)value {
    CGRect  selfToWindow = [self convertRect:self.bounds toView:YYBannerContentView_getConvertView(self)]; //当前View的frame
    CGFloat selfCenterX = CGRectGetMidX(selfToWindow); //当前View的centerX
    CGPoint windowCenter = YYBannerContentView_getConvertView(self).center;
    CGFloat selfOffsetX = selfCenterX - windowCenter.x; //偏移距离
    
    CGAffineTransform transX = CGAffineTransformMakeTranslation(- selfOffsetX * value, 0);
    self.contentIMG.transform = transX;
}

#pragma mark - Tap action
- (void)btnFunc:(UIGestureRecognizer *)gesture{
    if (self.callBack) {
        self.callBack(self);
    }
}

#pragma mark - Private method
static inline UIView * YYBannerContentView_getConvertView(UIView * view){
    UIView * superView = view.superview.superview;
    if(superView){
        return superView;
    }else{
        return view.window;
    }
}

#pragma mark - Getter
- (YYAnimatedImageView *)contentIMG {
    if (!_contentIMG) {
        _contentIMG = [[YYAnimatedImageView alloc]initWithFrame:self.bounds];
        _contentIMG.frame = self.bounds;
        _contentIMG.backgroundColor = [UIColor clearColor];
        _contentIMG.contentMode = UIViewContentModeScaleAspectFill;
        _contentIMG.clipsToBounds = YES;
    }
    return _contentIMG;
}

@end
