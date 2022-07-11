//
//  STLActionCollectionFooterView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/10.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLActionCollectionFooterView.h"

@implementation STLActionCollectionFooterView

+ (STLActionCollectionFooterView *)actionCollectionFooterView:(UICollectionView *)collectionView kind:(NSString*)kind indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[STLActionCollectionFooterView class] forSupplementaryViewOfKind:kind withReuseIdentifier:@"STLActionCollectionFooterView"];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"STLActionCollectionFooterView" forIndexPath:indexPath];
}

+ (CGSize)sizeDescContent:(NSMutableAttributedString *)content {
    
    if (![content isKindOfClass:[NSAttributedString class]]) {
        return CGSizeZero;
    }
    if (![OSSVNSStringTool isEmptyString:content.string]) {
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//        [paragraphStyle setLineSpacing:6];
//        CGSize contentSize = [content.string textSizeWithFont:[UIFont systemFontOfSize:11]
//                                                 constrainedToSize:CGSizeMake(SCREEN_WIDTH - 36, MAXFLOAT)
//                                                     lineBreakMode:NSLineBreakByWordWrapping paragraphStyle:paragraphStyle];
//        contentSize.height += 10;
//        
        NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
//
        CGRect rect = [content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 36, CGFLOAT_MAX) options:options context:nil];
        CGSize size = CGSizeMake(SCREEN_WIDTH, rect.size.height + 10);
//        
//        STLLog(@" 777777 %@",NSStringFromCGSize(size));
        return size;
        
        
//        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:content];
//
//        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//
//        style.lineSpacing = 6;
//
//        UIFont *font = [UIFont systemFontOfSize:12];
//        UIFont *boldFont = [UIFont boldSystemFontOfSize:14];
//
//        [attributeString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, content.length)];
//
//        [attributeString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, content.length)];
//        [attributeString addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, 7)];
//        [attributeString addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(10, 4)];
//        [attributeString addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(19, 7)];
//        [attributeString addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(29, 4)];
//
//        NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
//
//        CGRect rect = [attributeString boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 32, CGFLOAT_MAX) options:options context:nil];
//        CGSize size = CGSizeMake(rect.size.width, rect.size.height + 10);
//        return size;
        
    }
    
    return CGSizeZero;
}

- (CGRect)boundsWithFontSize:(CGFloat)fontSize text:(NSString *)text needWidth:(CGFloat)needWidth lineSpacing:(CGFloat )lineSpacing
{
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    
    style.lineSpacing = lineSpacing;
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    
    [attributeString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    
    [attributeString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, text.length)];
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    
    CGRect rect = [attributeString boundingRectWithSize:CGSizeMake(needWidth, CGFLOAT_MAX) options:options context:nil];
    
    
    
    return rect;
    
}


- (void)updateDescContent:(NSMutableAttributedString *)content {
    
//    NSMutableParagraphStyle *paragraphStyle  =[[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.lineSpacing = 6;//连字符
//    NSDictionary *attrDict =@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12],
//                              NSParagraphStyleAttributeName:paragraphStyle};
//
//    NSAttributedString *attrStr =[[NSAttributedString alloc] initWithString:STLToString(content) attributes:attrDict];
//    self.contentLabel.attributedText = attrStr;
    

//    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:content];
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    style.lineSpacing = 6;
//
//    UIColor *fontColor = [OSSVThemesColors col_0D0D0D];
//
//    [attributeString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, content.length)];
//
//    [attributeString addAttribute:NSForegroundColorAttributeName value:[OSSVThemesColors col_999999] range:NSMakeRange(0, content.length)];
//    [attributeString addAttribute:NSForegroundColorAttributeName value:fontColor range:NSMakeRange(0, 7)];
//    [attributeString addAttribute:NSForegroundColorAttributeName value:fontColor range:NSMakeRange(10, 4)];
//    [attributeString addAttribute:NSForegroundColorAttributeName value:fontColor range:NSMakeRange(19, 7)];
//    [attributeString addAttribute:NSForegroundColorAttributeName value:fontColor range:NSMakeRange(29, 4)];
    
    if ([content isKindOfClass:[NSAttributedString class]] || [content isKindOfClass:[NSMutableAttributedString class]]) {
        self.contentLabel.attributedText = content;
    } else {
        self.contentLabel.text = STLToString(content);
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.bgView];
        [self addSubview:self.contentLabel];
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).mas_offset(18);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-18);
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
    }
    
    return self;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [OSSVThemesColors col_F8F8F8];
        _bgView.layer.cornerRadius = 2.0;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = [OSSVThemesColors col_999999];
        _contentLabel.font = [UIFont systemFontOfSize:11];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}
@end
