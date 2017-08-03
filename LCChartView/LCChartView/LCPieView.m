//
//  LCPieView.m
//  LCPieView
//
//  Created by liangrongchang on 2017/5/16.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import "LCPieView.h"
#import "UIView+LCLayout.h"

@interface LCPieView ()<CAAnimationDelegate>

@property (nonatomic, strong) NSArray <NSNumber *>*endPercents;
@property (nonatomic, strong) NSMutableArray <CAShapeLayer *>*layers;
@property (nonatomic, strong) CAShapeLayer *touchLayer;
@property (nonatomic, strong) NSMutableArray <UILabel *>*textLabels;
@property (strong, nonatomic) UIScrollView *noteView;
@property (nonatomic, strong) NSArray <LCPieViewModel *>*dataSource;

@end

@implementation LCPieView

+ (instancetype)pieView {
    LCPieView *pieView = [[LCPieView alloc] init];
    return pieView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
    _arcWidth = 50;
    _outerArcRadius = 100;
    _duration = 0.8;
    _showText = _animtion = _showPercent = _isCanClick = YES;
}

- (void)showPieViewWithDataSource:(NSArray<LCPieViewModel *> *)dataSource {
    self.dataSource = dataSource;
    [self showPieView];
}

- (void)showPieView {
    if (!self.dataSource.count) {
        return;
    }
    [self resetData];
    [self handleData];
    CGFloat radius = self.outerArcRadius - self.arcWidth / 2;
    for (int i = 0; i < self.dataSource.count; i ++) {
        LCPieViewModel *model = self.dataSource[i];
        CGFloat startP = i == 0 ? 0 : self.endPercents[i - 1].doubleValue;
        CGFloat endP = self.endPercents[i].doubleValue;
        
        CAShapeLayer *layer = [self layerWithRadius:radius borderWidth:self.arcWidth fillColor:[UIColor clearColor] strokeColor:model.color startPercentage:startP endPercentage:endP];
        
        [self.layer addSublayer:layer];
        [self.layers addObject:layer];
    }
    [self addAnimation:_animtion];
    if (_showText) {
        [self addText];
    }
}

#pragma mark - response method
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isCanClick) {
        return;
    }
    for (UITouch *touch in touches) {
        CGPoint touchP = [touch locationInView:self];CGPoint centerP = CGPointMake(self.LC_width / 2, self.LC_height / 2 );
        CGFloat distanceFromCenter = sqrtf(powf((touchP.y - centerP.y),2) + powf((touchP.x - centerP.x),2));
        if (distanceFromCenter > self.outerArcRadius || distanceFromCenter < self.outerArcRadius - self.arcWidth) {
            return;
        }
        CGFloat angePercent = [self anglePercenWithCenter:centerP fromPoint:touchP];
        __block NSUInteger index = 0;
        [self.endPercents enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.doubleValue > angePercent ) {
                index = idx;
                *stop = YES;
            }
        }];
        if (self.clickPieViewBlock) {
            self.clickPieViewBlock(self.dataSource[index], index);
        }
        
        if (self.touchLayer) {
            [self.touchLayer removeFromSuperlayer];
            self.touchLayer = nil;
        }
        CGFloat startA = index == 0 ? 0 : self.endPercents[index - 1].doubleValue;
        CGFloat endA = self.endPercents[index].doubleValue;
        self.touchLayer = [self layerWithRadius:self.outerArcRadius + 8 borderWidth:16 fillColor:[UIColor clearColor] strokeColor:[self.dataSource[index].color colorWithAlphaComponent:0.5] startPercentage:startA endPercentage:endA];
        [self.layer addSublayer:self.touchLayer];
    }
}

#pragma mark - private method
- (CGFloat)anglePercenWithCenter:(CGPoint)center fromPoint:(CGPoint)reference {
    CGFloat angleOfLine = atanf((reference.y - center.y) / (reference.x - center.x));
    CGFloat percentage = (angleOfLine + M_PI/2)/(2 * M_PI);
    return (reference.x - center.x) > 0 ? percentage : percentage + .5;
}

- (void)resetData {
    if (self.layers.count) {
        [self.layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.layers removeAllObjects];
    }
    
    if (self.touchLayer) {
        [self.touchLayer removeFromSuperlayer];
        self.touchLayer = nil;
    }
    
    if (self.textLabels.count) {
        [self.textLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.textLabels removeAllObjects];
    }
}

- (void)handleData{
    NSMutableArray <NSNumber *>*endPercents = [[NSMutableArray alloc] init];
    CGFloat total = [[self.dataSource valueForKeyPath:@"@sum.value"] floatValue];
    for (int i = 0;  i < self.dataSource.count; i++) {
        LCPieViewModel *model = self.dataSource[i];
        if (i == 0) {
            [endPercents addObject:@(model.value / total)];
        } else {
            [endPercents addObject:@(model.value / total + endPercents.lastObject.doubleValue)];
        }
    }
    self.endPercents = endPercents.copy;
}

- (void)addAnimation:(BOOL)animate {
    if (animate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration  = _duration;
        animation.fromValue = @0;
        animation.toValue   = @1;
        animation.delegate = self;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        for (CAShapeLayer *layer in self.layers) {
            [layer addAnimation:animation forKey:@"circleAnimation"];
        }
    } else {
        [self.textLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.alpha = 1.0;
        }];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.textLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [UIView animateWithDuration:0.3 animations:^{
            obj.alpha = 1.0;
        }];
    }];
}

- (void)addText {
    for (int i = 0; i < self.dataSource.count; i++) {
        LCPieViewModel *model = self.dataSource[i];
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        if (_showPercent) {
            CGFloat total = [[self.dataSource valueForKeyPath:@"@sum.value"] floatValue];
            label.text = [NSString stringWithFormat:@"%.0f%%\n%@", self.dataSource[i].value / total * 100, model.text];
        } else {
            label.text = [NSString stringWithFormat:@"%.0f\n%@", model.value, model.text];
        }
        if (self.noteTextBlock) {
            self.noteTextBlock(label);
        }
        label.alpha = 0.0;
        [label sizeToFit];
        CGFloat distance = self.outerArcRadius - self.arcWidth / 2;
        CGFloat startA = i == 0 ? 0 : self.endPercents[i - 1].doubleValue;
        CGFloat endA = self.endPercents[i].doubleValue;
        CGFloat angle = (startA + endA) / 2 * M_PI * 2;
        CGPoint centerPoint = CGPointMake(self.LC_width / 2 + distance * sin(angle), self.LC_height / 2 - distance * cos(angle));
        label.center = centerPoint;
        [self addSubview:label];
        [self.textLabels addObject:label];
    }
}

- (CAShapeLayer *)layerWithRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor startPercentage:(CGFloat)startP endPercentage:(CGFloat)endP{
    CAShapeLayer *layer = [CAShapeLayer layer];
    CGPoint center = CGPointMake(self.LC_width / 2, self.LC_height / 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:-M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
    layer.fillColor   = fillColor.CGColor;
    layer.strokeColor = strokeColor.CGColor;
    layer.strokeStart = startP;
    layer.strokeEnd   = endP;
    layer.lineWidth   = borderWidth;
    layer.path        = path.CGPath;
    
    return layer;
}

#pragma mark - getter
- (NSMutableArray<CAShapeLayer *> *)layers {
    if (!_layers) {
        _layers = [NSMutableArray array];
    }
    return _layers;
}

- (NSMutableArray <UILabel *>*)textLabels {
    if (!_textLabels) {
        _textLabels = [NSMutableArray array];
    }
    return _textLabels;
}

- (UIScrollView *)noteView {
    if (!_noteView) {
        _noteView = [[UIScrollView alloc] init];
        _noteView.backgroundColor = [UIColor orangeColor];
        _noteView.showsVerticalScrollIndicator = NO;
        _noteView.LC_width = 80;
        _noteView.LC_height = self.LC_height;
        _noteView.LC_right = self.LC_width - 10;
        _noteView.LC_y = 10;
    }
    return _noteView;
}

@end
