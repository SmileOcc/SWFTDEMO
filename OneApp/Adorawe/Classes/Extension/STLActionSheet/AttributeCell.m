//
//  AttributeCell.m
// XStarlinkProject
//
//  Created by 10010 on 2017/9/18.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import "AttributeCell.h"

@interface AttributeCell ()

@end

@implementation AttributeCell

+ (AttributeCell *)attributeCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[AttributeCell class] forCellWithReuseIdentifier:@"AttributeCell"];
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"AttributeCell" forIndexPath:indexPath];
}

+ (CGSize)sizeAttributeContent:(NSString *)content {
    
    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:14]};
    CGSize itemSize = [STLToString(content) boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    
//    if (itemSize.width <= 60) {
//        if ((60 - itemSize.width) >= 20) { //最小宽 60
//            if (itemSize.width + 24 <= 60) {
//                itemSize = CGSizeMake(60, 32);
//            } else {
//                itemSize = CGSizeMake(itemSize.width + 24, 36);
//            }
//
//        } else { // 在50 - 60之间，加一个间隙
//            itemSize = CGSizeMake(itemSize.width + 24, 36);
//        }
//    } else {
//        itemSize = CGSizeMake(itemSize.width + 24, 36);
//    }
    itemSize = CGSizeMake(MAX(itemSize.width + 28, 36), 36) ;
    
    
    return itemSize;
}

- (void)setKeyword:(NSString *)keyword isSelect:(BOOL)isSelect isDisable:(BOOL)isDisable{
    _titleLabel.text = keyword;
    
    NSArray *subLayers = _bgView.layer.sublayers;
    for (CAShapeLayer *borderLayer in subLayers) {
        [borderLayer removeFromSuperlayer];
    }
//    _bgView.layer.cornerRadius = 16.0;

    if (isDisable) {
        
        if (isSelect) {
            _bgView.layer.borderWidth = 1.0;
            _bgView.layer.borderColor = [OSSVThemesColors col_0D0D0D].CGColor;
            _bgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
            _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        } else {
            
            _bgView.backgroundColor = [OSSVThemesColors col_EEEEEE];
            _bgView.layer.borderColor = [UIColor clearColor].CGColor;
            _titleLabel.textColor = [OSSVThemesColors col_CCCCCC];
            
            CGSize textSize = [AttributeCell sizeAttributeContent:keyword];

            CAShapeLayer *solidShapeLayer = [CAShapeLayer layer];
            CGMutablePathRef solidShapePath =  CGPathCreateMutable();
            [solidShapeLayer setFillColor:[[UIColor clearColor] CGColor]];
            [solidShapeLayer setStrokeColor:[OSSVThemesColors col_CCCCCC].CGColor];
            solidShapeLayer.lineWidth = 1.0f ;
            CGPathMoveToPoint(solidShapePath, NULL, textSize.width, 0);
            CGPathAddLineToPoint(solidShapePath, NULL, 0,textSize.height);
            [solidShapeLayer setPath:solidShapePath];
            CGPathRelease(solidShapePath);
            [self.bgView.layer addSublayer:solidShapeLayer];
  
//            CGSize textSize = [AttributeCell sizeAttributeContent:keyword];
//            CAShapeLayer *borderLayer = [CAShapeLayer layer];
//            borderLayer.bounds = CGRectMake(0, 0, textSize.width, textSize.height); //中心点位置
//            borderLayer.position = CGPointMake(textSize.width *0.5, textSize.height *0.5);
//            borderLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, textSize.width, textSize.height)].CGPath;
//            borderLayer.lineWidth = 1; //边框的宽度
//            borderLayer.lineDashPattern = @[@3,@3]; //边框虚线线段的宽度
//            borderLayer.fillColor = [UIColor clearColor].CGColor;
//            [_titleLabel.layer addSublayer:borderLayer];
        }
        
    } else {
        
        if (isSelect) {
            _bgView.layer.borderWidth = 1.0;
            _bgView.layer.borderColor = [OSSVThemesColors col_0D0D0D].CGColor;
//            _bgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
            _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        } else {
            _bgView.layer.borderWidth = 1.0;
//            _bgView.layer.cornerRadius = 16.0;
            _bgView.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
//            _bgView.backgroundColor = [OSSVThemesColors col_F5F5F5];
            _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        }
    }
    
    _imgV.hidden = YES;
    _titleLabel.hidden = NO;
}

- (void)setBgImgStr:(NSString *)bgImgStr isSelect:(BOOL)isSelect isDisable:(BOOL)isDisable{
    if (isSelect) {
        _imgV.layer.borderWidth = 1.0;
        _imgV.layer.borderColor = [OSSVThemesColors col_0D0D0D].CGColor;
    }else{
        _imgV.layer.borderWidth = 1.0;
        _imgV.layer.borderColor = [OSSVThemesColors stlClearColor].CGColor;
    }
    [_imgV yy_setImageWithURL:[NSURL URLWithString:bgImgStr] placeholder:[UIImage imageNamed:@"detail_colorPlaceholder"]];
    _imgV.hidden = NO;
    _titleLabel.hidden = YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
//        _bgView.layer.cornerRadius = 16.0;
        _bgView.layer.masksToBounds = YES;
        [self.contentView addSubview:_bgView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
        
        _imgV = [YYAnimatedImageView new];
        _imgV.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_imgV];
        
        
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bgView.mas_leading).offset(10);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-10);
        }];
        
        [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _titleLabel.text = nil;
    _bgView.layer.borderColor = [UIColor clearColor].CGColor;
}


@end
