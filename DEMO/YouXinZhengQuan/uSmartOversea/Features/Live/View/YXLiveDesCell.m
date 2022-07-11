//
//  YXLiveDesCell.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveDesCell.h"
#import <DTCoreText/DTCoreText.h>
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXLiveDesCell()<DTAttributedTextContentViewDelegate,DTLazyImageViewDelegate>

@property (nonatomic, strong) DTAttributedLabel *desLabel;

@property (nonatomic, assign) CGRect viewMaxRect;

@end

@implementation YXLiveDesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.desLabel];
}

- (void)setDesStr:(NSString *)desStr {
    _desStr = desStr;
    
    if (desStr.length > 0) {
        _viewMaxRect =  CGRectMake(12, 12, YXConstant.screenWidth - 12*2, CGFLOAT_HEIGHT_UNKNOWN);
        CGSize textSize = [self getAttributedTextHeightHtml:desStr with_viewMaxRect:_viewMaxRect];
        self.desLabel.frame = CGRectMake(_viewMaxRect.origin.x, _viewMaxRect.origin.y, _viewMaxRect.size.width, textSize.height);
        self.desLabel.attributedString = [self getAttributedStringWithHtml:desStr];
    }
}

//使用HtmlString,和最大左右间距，计算视图的高度
- (CGSize)getAttributedTextHeightHtml:(NSString *)htmlString with_viewMaxRect:(CGRect)_viewMaxRect{
    //获取富文本
    NSAttributedString *attributedString =  [self getAttributedStringWithHtml:htmlString];
    //获取布局器
    DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:attributedString];
    NSRange entireString = NSMakeRange(0, [attributedString length]);
    //获取Frame
    DTCoreTextLayoutFrame *layoutFrame = [layouter layoutFrameWithRect:_viewMaxRect range:entireString];
    //得到大小
    CGSize sizeNeeded = [layoutFrame frame].size;
    return sizeNeeded;
}

//Html->富文本NSAttributedString
- (NSAttributedString *)getAttributedStringWithHtml:(NSString *)htmlString{
    //获取富文本
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTMLData:data options:@{DTDefaultTextColor: QMUITheme.textColorLevel1, DTDefaultFontSize: @(14), DTDefaultLinkColor: QMUITheme.themeTintColor, DTDefaultLinkDecoration: @(NO), DTDefaultLineHeightMultiplier : @(1.4) } documentAttributes:NULL];
    return attributedString;
}


#pragma mark  Delegate：DTLazyImageViewDelegate
//懒加载获取图片大小
- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
    NSURL *url = lazyImageView.url;
    CGSize imageSize = size;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
    BOOL didUpdate = NO;
    // update all attachments that match this URL (possibly multiple images with same size)
    for (DTTextAttachment *oneAttachment in [self.desLabel.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            [self configNoSizeImageView:url.absoluteString size:imageSize];
            didUpdate = YES;
        }
    }
}


//字符串中一些图片没有宽高，懒加载图片之后，在此方法中得到图片宽高
//这个把宽高替换原来的html,然后重新设置富文本
- (void)configNoSizeImageView:(NSString *)url size:(CGSize)size
{
    CGFloat imgSizeScale = size.height/size.width;
    CGFloat widthPx = _viewMaxRect.size.width;
    CGFloat heightPx = widthPx * imgSizeScale;
    
    NSString *imageInfo = [NSString stringWithFormat:@"_src=\"%@\"",url];
    NSString *sizeString = [NSString stringWithFormat:@" style=\"width:%.fpx; height:%.fpx;\"",widthPx,heightPx];
    NSString *newImageInfo = [NSString stringWithFormat:@"_src=\"%@\"%@",url,sizeString];
    
    if ([self.desStr containsString:imageInfo]) {
        NSString *newHtml = [self.desStr stringByReplacingOccurrencesOfString:imageInfo withString:newImageInfo];
        // reload newHtml
        
        self.desStr = newHtml;
        CGSize textSize = [self getAttributedTextHeightHtml:self.desStr with_viewMaxRect:_viewMaxRect];
        self.desLabel.frame = CGRectMake(_viewMaxRect.origin.x, _viewMaxRect.origin.y, _viewMaxRect.size.width, textSize.height);
        self.desLabel.attributedString = [self getAttributedStringWithHtml:self.desStr];
        //self.attributedLabel.attributedString = [self getAttributedStringWithHtml:@"<span style=\"color:#333;font-size:15px;\"><strong>砍价师服务介绍</strong></span>"];
        [self.desLabel relayoutText];
    }
}



- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame{
    DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
    button.URL = url;
    return button;
}


- (DTAttributedLabel *)desLabel {
    if (_desLabel == nil) {
        _desLabel = [[DTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 50)];
        _desLabel.delegate = self;
        _desLabel.backgroundColor = UIColor.whiteColor;
    }
    return _desLabel;
}

@end
