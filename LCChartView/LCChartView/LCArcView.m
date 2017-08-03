//
//  LCArcView.m
//  HeJing
//
//  Created by liangrongchang on 16/10/20.
//  Copyright © 2016年 Rochang. All rights reserved.
//

#import "LCArcView.h"
#import "UIView+LCLayout.h"

static CGFloat startAngle = 0;
static CGFloat endAngle = 0;

@interface LCArcView ()

@property (nonatomic, strong) CAShapeLayer *arcLayer;
@property (nonatomic, strong) CAShapeLayer *bgArcLayer;
@property (nonatomic, strong) UILabel *percentLabel;
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation LCArcView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self  = [super initWithFrame:frame]) {
        [self initData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initData];
    }
    return self;
}

- (void)initData {
    self.outerRadius = MIN(self.LC_width / 2, self.LC_height / 2);
    self.arcWidth = 10;
    self.bgArcColor = [UIColor grayColor];
    self.arcColor = [UIColor blueColor];
    self.duration = 1.0;
    _arcsMargin = 3;
    _showPercentLabel = YES;
    self.centerP = CGPointMake(self.LC_width / 2, self.LC_height / 2);
}

- (void)resetData {
    if (_arcLayer) {
        [_arcLayer removeFromSuperlayer];
        _arcLayer = nil;
    }
    if (_bgArcLayer) {
        [_bgArcLayer removeFromSuperlayer];
        _arcLayer = nil;
    }
    if (_percentLabel) {
        [_percentLabel removeFromSuperview];
        _percentLabel = nil;
    }
}

- (void)showArcViewWithStartAngle:(CGFloat)startA endAngle:(CGFloat)endA animaion:(BOOL)animaion {
    [self resetData];
    startAngle = startA;
    endAngle = endA;
    CGFloat radius = self.outerRadius - self.arcWidth / 2;
    self.arcLayer = [self layerWithRadius:radius borderWidth:self.arcWidth strokeColor:self.arcColor startAngle:startA endAngle:endA];
    [self addAnimationForLay:self.arcLayer animation:animaion];
    [self addPercentLabel:_showPercentLabel];
}

- (void)showArcViewWithBgStartAngle:(CGFloat)bgStartA endBgAngle:(CGFloat)bgEndA bgAnimation:(BOOL)bgAnimation StartAngle:(CGFloat)startA endAngle:(CGFloat)endA animaion:(BOOL)animaion {
    [self resetData];
    startAngle = startA;
    endAngle = endA;
    CGFloat radius = self.outerRadius - self.arcWidth / 2;
    self.bgArcLayer = [self layerWithRadius:radius borderWidth:self.arcWidth strokeColor:self.bgArcColor startAngle:bgStartA endAngle:bgEndA];
    CGFloat interArcWidth = self.arcWidth - self.arcsMargin * 2;
    if (interArcWidth <= 0) {
        NSLog(@"内圆环为0");
    }
    self.arcLayer = [self layerWithRadius:radius borderWidth:interArcWidth strokeColor:self.arcColor startAngle:startA endAngle:endA];
    [self addAnimationForLay:self.bgArcLayer animation:bgAnimation];
    [self addAnimationForLay:self.arcLayer animation:animaion];
    [self addPercentLabel:_showPercentLabel];
}

#pragma mark - private
- (void)addPercentLabel:(BOOL)show {
    if (!show) return;
    [self addSubview:self.percentLabel];
    self.percentLabel.LC_size = CGSizeMake((self.outerRadius - 2 * self.arcWidth) * 2, 20);
    self.percentLabel.center = self.centerP;
    if (self.percentLabelBlock) {
        self.percentLabelBlock(_percentLabel);
    }
    __weak typeof(self) weakSelf = self;
    __block int i = 0;
    CGFloat percent = (endAngle - startAngle) / (M_PI * 2) * 100;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_duration / percent  repeats:YES block:^(NSTimer * _Nonnull timer) {
        weakSelf.percentLabel.text = [NSString stringWithFormat:@"%02d%%", i++];
        if (i > percent) {
            [timer invalidate];
            timer = nil;
        }
    }];
}

- (CAShapeLayer *)layerWithRadius:(CGFloat)radius
                      borderWidth:(CGFloat)borderWidth
                      strokeColor:(UIColor *)strokeColor
                       startAngle:(CGFloat)startA
                         endAngle:(CGFloat)endA {
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.centerP radius:radius startAngle:startA endAngle:endA clockwise:YES];
    path.lineWidth = borderWidth;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = strokeColor.CGColor;
    layer.lineWidth = borderWidth;
    layer.path = path.CGPath;
    layer.lineCap = kCALineCapRound;
    return layer;
}

- (void)addAnimationForLay:(CAShapeLayer *)layer animation:(BOOL)animate {
    [self.layer addSublayer:layer];
    if (animate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration  = _duration;
        animation.fromValue = @0;
        animation.toValue   = @1;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [layer addAnimation:animation forKey:nil];
    }
}

- (UILabel *)percentLabel {
    if (!_percentLabel) {
        _percentLabel = [[UILabel alloc] init];
        _percentLabel.textAlignment = NSTextAlignmentCenter;
        _percentLabel.backgroundColor = [UIColor clearColor];
        _percentLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _percentLabel;
}

@end
