//
//  ZFCollectionPostsView.m
//  Zaful
//
//  Created by occ on 2019/6/11.
//  Copyright © 2019 Zaful. All rights reserved.
//

#import "ZFCollectionPostsContainerView.h"
#import "ZFCollectionPostsMenuView.h"

#import "ZFInitViewProtocol.h"

@interface ZFCollectionPostsContainerView()<ZFInitViewProtocol>

@property (nonatomic, strong) ZFCollectionPostsMenuView *menuView;

@end

@implementation ZFCollectionPostsContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
@end
