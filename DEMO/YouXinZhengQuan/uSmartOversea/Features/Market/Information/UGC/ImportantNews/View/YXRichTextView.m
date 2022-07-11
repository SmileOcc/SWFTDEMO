//
//  YXRichTextView.m
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXRichTextView.h"
#import <DTCoreText/DTCoreText.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <YYCategories/YYCategories.h>
#import "XLPhotoBrowser.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXRichPlayerViewController : AVPlayerViewController

@property (nonatomic, strong) NSURL *contentUrl;

@end

@implementation YXRichPlayerViewController

- (void)setContentUrl:(NSURL *)contentUrl {
    _contentUrl = contentUrl;
    
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:contentUrl];
    AVPlayer *avPlayer = [AVPlayer playerWithPlayerItem:item];
    self.player = avPlayer;
    self.videoGravity = AVLayerVideoGravityResizeAspect;
    self.showsPlaybackControls = YES;
    
}

- (void)dealloc {
    NSLog(@"富文本视频view挂了");
}

@end

@interface YXRichTextView ()<DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate>

@property (nonatomic, strong) DTAttributedTextView *richLabel;

@property (nonatomic, strong) NSMutableArray *mediaPlayers;

@property (nonatomic, strong) NSMutableArray <NSString *> *imageUrls;

@property (nonatomic, strong) NSMutableArray <UIView *> *videoViewArr;


@end

@implementation YXRichTextView

- (void)dealloc {
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    

    for (UIView *videoView in self.videoViewArr) {
        for (UIView *view in videoView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    for (YXRichPlayerViewController *playVC in self.mediaPlayers) {
        [playVC.player pause];
        [playVC removeFromParentViewController];
    }
    
    [self.mediaPlayers removeAllObjects];
    [self.videoViewArr removeAllObjects];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    [self addSubview:self.richLabel];
    [self.richLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(18);
        make.right.equalTo(self).offset(-18);
        make.bottom.equalTo(self).offset(0);
        make.top.equalTo(self);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishReload:) name:DTAttributedTextContentViewDidFinishLayoutNotification object:nil];
}

- (void)setAttText:(NSAttributedString *)attText {
    _attText = attText;
    self.richLabel.attributedString = attText;
}


#pragma mark - DTAttributedTextContentViewDelegate
//根据a标签，自定义响应按钮，处理点击事件
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame{

    DTLinkButton *btn = [[DTLinkButton alloc] initWithFrame:frame];
    btn.URL = url;
    [btn addTarget:self action:@selector(linkBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


- (void)linkBtnDidClick:(DTLinkButton *)sender {
    if (sender.URL) {
        [[YXGoToNativeManager shared] gotoNativeViewControllerWithUrlString:sender.URL.absoluteString];
    }
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame {
    if ([attachment isKindOfClass:[DTImageTextAttachment class]])
    {
        // if the attachment has a hyperlinkURL then this is currently ignored
        DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        imageView.delegate = self;
        
        // sets the image if there is one
        imageView.image = [(DTImageTextAttachment *)attachment image];
        
        // url for deferred loading
        imageView.url = attachment.contentURL;
        
//        attachment.contentURL.
        NSString *imageUrl = attachment.contentURL.absoluteString;
        if (imageUrl.length > 0 && ![self.imageUrls containsObject:imageUrl]) {
            [self.imageUrls addObject:imageUrl];
        }
        
        if (imageUrl.length > 0) {
            imageView.userInteractionEnabled = YES;
            @weakify(self);
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
                @strongify(self);
                NSInteger index = [self.imageUrls indexOfObject:imageUrl];
                [XLPhotoBrowser showPhotoBrowserWithImages:self.imageUrls currentImageIndex:index];
            }];
            [imageView addGestureRecognizer:tap];
        }
        
        return imageView;
    } else if ([attachment isKindOfClass:[DTVideoTextAttachment class]]) {
        NSURL *url = (id)attachment.contentURL;
        // we could customize the view that shows before playback starts
        
        CGRect rect = frame;
        if (CGRectGetWidth(frame) == 0 || CGRectGetHeight(frame) == 0) {
            CGFloat with = self.mj_w - 36;
            CGFloat height = with * 9 / 16;
            rect = CGRectMake(frame.origin.x, frame.origin.y, with, height);
            attachment.originalSize = CGSizeMake(with, height);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.richLabel relayoutText];
            });
        }
        
        UIView *grayView = [[UIView alloc] initWithFrame:rect];
        grayView.backgroundColor = UIColor.blackColor;
        [self.videoViewArr addObject:grayView];
        
        YXRichPlayerViewController *player = [[YXRichPlayerViewController alloc] init];
        player.view.frame = CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect));
        player.contentUrl = url;
        
        [grayView addSubview:player.view];
                
        [player.player pause];
        [self.mediaPlayers addObject:player];
        
        UIViewController *vc = [UIViewController currentViewController];
        [vc addChildViewController:player];

        
        return  grayView;
    } else if ([attachment isKindOfClass:[DTObjectTextAttachment class]]) {
        // somecolorparameter has a HTML color
        NSString *colorName = [attachment.attributes objectForKey:@"somecolorparameter"];
        UIColor *someColor = DTColorCreateWithHTMLName(colorName);
        
        UIView *someView = [[UIView alloc] initWithFrame:frame];
        someView.backgroundColor = someColor;
        someView.layer.borderWidth = 1;
        someView.layer.borderColor = [UIColor blackColor].CGColor;
        
        someView.accessibilityLabel = colorName;
        someView.isAccessibilityElement = YES;
        
        return someView;
    }
    
    return nil;
}

#pragma mark - DTLazyImageViewDelegate
- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
    NSURL *url = lazyImageView.url;
    CGSize imageSize = size;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
    
    BOOL didUpdate = NO;
    
    // update all attachments that match this URL (possibly multiple images with same size)
    for (DTTextAttachment *oneAttachment in [self.richLabel.attributedTextContentView.layoutFrame textAttachmentsWithPredicate:pred])
    {
        // update attachments that have no original size, that also sets the display size
        if (oneAttachment.originalSize.width == 0 || oneAttachment.originalSize.height == 0)
        {
            oneAttachment.originalSize = imageSize;
            
            didUpdate = YES;
        }
    }
    
    if (didUpdate)
    {
        // layout might have changed due to image sizes
        // do it on next run loop because a layout pass might be going on
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.richLabel relayoutText];
        });
    }
}


- (void)finishReload:(NSNotification *)noti {
    
    if (self.richLabel.attributedTextContentView != noti.object) {
        return;
    }
    CGFloat height = 0;
    NSObject *obj = [noti.userInfo objectForKey:@"OptimalFrame"];
    if ([obj isKindOfClass:[NSValue class]]) {
        NSValue *optimalFrame = (NSValue *)obj;
        height = CGRectGetHeight(optimalFrame.CGRectValue);
    }
    if (self.refreshHeight) {
        self.refreshHeight(height);
    }
}

#pragma mark - lazy load
- (DTAttributedTextView *)richLabel {
    if (_richLabel == nil) {
        _richLabel = [[DTAttributedTextView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 0)];
        _richLabel.textDelegate = self;
        _richLabel.backgroundColor = UIColor.clearColor;
//        _richLabel.contentInset = UIEdgeInsetsMake(0, 0, 18, 0);
        _richLabel.scrollEnabled = NO;
    }
    return _richLabel;
}

- (NSMutableArray *)mediaPlayers {
    if (_mediaPlayers == nil) {
        _mediaPlayers = [[NSMutableArray alloc] init];
    }
    return _mediaPlayers;
}

- (NSMutableArray<NSString *> *)imageUrls {
    if (_imageUrls == nil) {
        _imageUrls = [[NSMutableArray alloc] init];
    }
    return _imageUrls;
}


- (NSMutableArray<UIView *> *)videoViewArr {
    if (_videoViewArr == nil) {
        _videoViewArr = [[NSMutableArray alloc] init];
    }
    return _videoViewArr;
}

@end
