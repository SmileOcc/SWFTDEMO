//
//  ZFCustomerBackgroundCRView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/3.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCustomerBackgroundCRView.h"
#import <Masonry/Masonry.h>

@interface ZFCustomerBackgroundCRView ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation ZFCustomerBackgroundCRView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backgroundImageView];
        
        [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    if ([layoutAttributes isKindOfClass:[CustomerBackgroundAttributes class]]) {
        CustomerBackgroundAttributes *attr = (CustomerBackgroundAttributes *)layoutAttributes;
        self.backgroundColor = attr.backgroundColor;
        self.backgroundImageView.image = attr.backgroundImage;
    }
}

-(UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.contentMode = UIViewContentModeScaleToFill;
            img;
        });
    }
    return _backgroundImageView;
}

@end

@implementation CustomerBackgroundAttributes

- (id)copyWithZone:(NSZone *)zone
{
    CustomerBackgroundAttributes *attri = [super copyWithZone:zone];
    attri.backgroundImage = self.backgroundImage;
    attri.backgroundColor = self.backgroundColor;
    return attri;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if ([object class] == self.class) {
        CustomerBackgroundAttributes *att = (CustomerBackgroundAttributes *)object;
        BOOL isEqual = [super isEqual:object];
        BOOL isEqualColor = [self.backgroundColor isEqual:[att backgroundColor]];
        return isEqualColor && isEqual;
    }
    return NO;
}

@end
