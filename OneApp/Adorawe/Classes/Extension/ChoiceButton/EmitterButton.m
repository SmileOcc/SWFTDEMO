//
//  EmitterButton.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "EmitterButton.h"

@interface EmitterButton ()

//两种不同的CAEmitterLayer
@property (strong, nonatomic) CAEmitterLayer *chargeLayer;

@property (strong, nonatomic) CAEmitterLayer *explosionLayer;

@end

@implementation EmitterButton

/**
 *  通过fram初始化
 *
 *  @param frame WclEmitterButton的fram
 *
 *  @return 返回WclEmitterButton对象
 */

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

/**
 *  配置WclEmitterButton
 */
- (void)setup {
    CAEmitterCell *explosionCell = [CAEmitterCell emitterCell];
    explosionCell.name           = @"explosion";
    explosionCell.alphaRange     = 0.10;
    explosionCell.alphaSpeed     = -1.0;
    explosionCell.lifetime       = 0.7;
    explosionCell.lifetimeRange  = 0.3;
    explosionCell.birthRate      = 0;
    explosionCell.velocity       = 30.00;
    explosionCell.velocityRange  = 12.00;
    explosionCell.scale          = 0.03;
    explosionCell.scaleRange     = 0.02;
    explosionCell.contents       = (id)[UIImage imageNamed:@"Sparkle"].CGImage;
    
    _explosionLayer               = [CAEmitterLayer layer];
    _explosionLayer.name          = @"emitterLayer";
    _explosionLayer.emitterShape  = kCAEmitterLayerCircle;
    _explosionLayer.emitterMode   = kCAEmitterLayerOutline;
    _explosionLayer.emitterSize   = CGSizeMake(15, 15);
    _explosionLayer.emitterCells  = @[explosionCell];
    _explosionLayer.renderMode    = kCAEmitterLayerOldestFirst;
    _explosionLayer.masksToBounds = NO;
    _explosionLayer.position      = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);

    _explosionLayer.zPosition     = -1;
    [self.layer addSublayer:_explosionLayer];
    
    CAEmitterCell *chargeCell = [CAEmitterCell emitterCell];
    chargeCell.name           = @"charge";
    chargeCell.alphaRange     = 0.10;
    chargeCell.alphaSpeed     = -1.0;
    chargeCell.lifetime       = 0.3;
    chargeCell.lifetimeRange  = 0.1;
    chargeCell.birthRate      = 0;
    chargeCell.velocity       = -10.0;
    chargeCell.velocityRange  = 0.00;
    chargeCell.scale          = 0.03;
    chargeCell.scaleRange     = 0.02;
    chargeCell.contents       = (id)[UIImage imageNamed:@"Sparkle"].CGImage;
    chargeCell.contentsScale = 0.05;
    
    _chargeLayer               = [CAEmitterLayer layer];
    _chargeLayer.name          = @"emitterLayer";
    _chargeLayer.emitterShape  = kCAEmitterLayerCircle;
    _chargeLayer.emitterMode   = kCAEmitterLayerOutline;
    _chargeLayer.emitterSize   = CGSizeMake(15, 15);
    _chargeLayer.emitterCells  = @[chargeCell];
    _chargeLayer.renderMode    = kCAEmitterLayerOldestFirst;
    _chargeLayer.masksToBounds = NO;
    _chargeLayer.position      = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    _chargeLayer.zPosition     = -1;
    [self.layer addSublayer:_chargeLayer];
}

/**
 *  开始动画
 */
- (void)animation {
    _explosionLayer.emitterPosition      = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    _explosionLayer.emitterSize = CGSizeMake(15, 15);
    _chargeLayer.emitterPosition  = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    _chargeLayer.emitterSize = CGSizeMake(15, 15);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    if (!self.selected) {
        animation.values = @[@0.8, @1.2,@1.5,@1.0];//@[@1.5 ,@0.8, @1.0,@1.2,@1.0];
        animation.duration = 0.6;
        [self stop];
        [self explode];
    }else
    {
        animation.values = @[@0.5, @1.0];
        animation.duration = 0.4;
    }
    animation.calculationMode = kCAAnimationCubic;
    [self.layer addAnimation:animation forKey:@"transform.scale"];
}

/**
 *  开始喷射
 */
- (void)startAnimate {
    //chareLayer开始时间
    self.chargeLayer.beginTime = CACurrentMediaTime();
    //chareLayer每秒喷射的80个
    [self.chargeLayer setValue:@1000 forKeyPath:@"emitterCells.charge.birthRate"];
    //进入下一个动作
    [self performSelector:@selector(explode) withObject:nil afterDelay:0.3];
}

/**
 *  大量喷射
 */
- (void)explode {
    //让chareLayer每秒喷射的个数为0个
    [self.chargeLayer setValue:@0 forKeyPath:@"emitterCells.charge.birthRate"];
    //explosionLayer开始时间
    self.explosionLayer.beginTime = CACurrentMediaTime();
    //explosionLayer每秒喷射的2500个
    [self.explosionLayer setValue:@3000 forKeyPath:@"emitterCells.explosion.birthRate"];
    //停止喷射
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.2];
}

/**
 *  停止喷射
 */
- (void)stop {
    //让chareLayer每秒喷射的个数为0个
    [self.chargeLayer setValue:@0 forKeyPath:@"emitterCells.charge.birthRate"];
    //explosionLayer每秒喷射的0个
    [self.explosionLayer setValue:@0 forKeyPath:@"emitterCells.explosion.birthRate"];
}


@end
