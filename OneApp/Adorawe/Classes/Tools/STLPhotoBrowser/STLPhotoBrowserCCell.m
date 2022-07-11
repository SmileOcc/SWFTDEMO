//
//  STLPhotoBrowserCCell.m
// XStarlinkProject
//
//  Created by odd on 2021/6/30.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLPhotoBrowserCCell.h"

@implementation STLPhotoBrowserCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        CGRect rect = self.bounds;
        rect.size.width -= 10;
        rect.origin.x = 5;
        self.photoView = [[STLPhotoView alloc] initWithFrame:rect];
        self.photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.photoView];
    }
    return self;
}

- (void)layoutSubviews {
    _photoView.zoomScale = 1.0;
    _photoView.contentSize = _photoView.bounds.size;
}


@end
