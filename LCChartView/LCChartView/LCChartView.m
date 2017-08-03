//
//  LCChartView.m
//  LCProject
//
//  Created by liangrongchang on 2017/1/6.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import "LCChartView.h"
#import "UIView+LCLayout.h"
#import "LCMethod.h"

static NSTimeInterval duration = 0.8;
static CGFloat yAxisMaxY = 0;
static CGFloat yTextCenterMargin = 0;
/** 显示数据的区域高度 */
static CGFloat dataChartHeight = 0;
static CGFloat axisLabelHieght = 0;
static CGFloat xAxisMaxX = 0;
static CGFloat noteViewRowH = 15;

@interface LCChartView ()<UIScrollViewDelegate, CAAnimationDelegate>
// UI
@property (strong, nonatomic) NSMutableArray <UILabel *>*yAxisLabels;
@property (strong, nonatomic) NSMutableArray <UILabel *>*xAxisLabels;
@property (strong, nonatomic) NSMutableArray <UIView *>*allSubView;
@property (strong, nonatomic) UIScrollView *noteView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *yAxisLabel;
@property (strong, nonatomic) UILabel *xAxisLabel;

// 数据
@property (assign, nonatomic) CGFloat yAxisMaxValue;
@property (strong, nonatomic) NSArray<LCChartViewModel *> *dataSource;

/** 捏合时记录原先X轴点距离 */
@property (assign, nonatomic) CGFloat orginXAxisMargin;
/** 捏合时记录原先动画flag */
@property (assign, nonatomic) BOOL orginAnimation;
/** X轴箭头离XAxisLabel距离 */
@property (assign, nonatomic) CGFloat xArrowsToText;
@property (assign, nonatomic) CGPoint originPoint;
/** 第一次动画 */
@property (strong, nonatomic) NSMutableArray <CAShapeLayer *>*firstLayers;
/** 第二次动画 */
@property (strong, nonatomic) NSMutableArray <CAShapeLayer *>*scondLayers;

// response
@property (strong, nonatomic) UITapGestureRecognizer *twoTap;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinch;

@end

@implementation LCChartView

#pragma mark - API
+ (instancetype)chartViewWithType:(LCChartViewType)type {
    LCChartView *axisView = [[LCChartView alloc] init];
    axisView.chartViewType = type;
    return axisView;
}

- (instancetype)initWithFrame:(CGRect)frame chartViewType:(LCChartViewType)type {
    if (self = [super initWithFrame:frame]) {
        [self initData];
        self.chartViewType = type;
    }
    return self;
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

- (void)showChartViewWithYAxisMaxValue:(CGFloat)yAxisMaxValue dataSource:(NSArray<LCChartViewModel *> *)dataSource {
    _yAxisMaxValue = yAxisMaxValue;
    self.dataSource = dataSource;
    [self showChartView];
}

#pragma mark - private method
- (void)initData {
    _axisColor = [UIColor darkGrayColor];
    _backColor = [UIColor whiteColor];
    _axisTitleSizeFont = 10;
    _plotsLabelSelectedColor = _plotsButtonSelectedColor = _plotsLabelColor = [UIColor redColor];
    _yTextColor = _xTextColor = _plotsButtonColor = _lineChartFillViewColor = [UIColor darkGrayColor];
    _barWidth = 20;
    _yAxisMaxValue = 1000;
    _chartViewType = LCChartViewTypeLine;
    _axisFontSize = 12;
    _plotsLabelFontSize = 9;
    _barMargin = 20;
    _yAxisToLeft = _chartViewRightMargin = _topMargin = 35;
    _displayPlotToLabel = 3;
    _axisWidth = _lineChartWidth = 1;
    _xAxisTextMargin = _orginXAxisMargin = _xArrowsToText = 30;
    _yTextToAxis = _yAxisCount = _plotsButtonWH = 5;
    _yAxisTitle = @"y";
    _xAxisTitle = @"x";
    _xAxisTitleArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8" , @"9", @"10", @"11", @"12"];
    _lineChartFillView = _showPlotsLabel = NO;
    _showAnimation = _orginAnimation = _showGridding = _showNote = YES;

}

- (void)showChartView {
    if (self.dataSource.count == 0) {
        NSLog(@"请设置展示的点数据");
        return;
    };
    if (self.chartViewType == LCChartViewTypeBar && _xAxisTextMargin < _barWidth * self.dataSource.count + self.barMargin) {
        _xAxisTextMargin = self.orginXAxisMargin = _barWidth * self.dataSource.count + self.barMargin;
    }
    
    // 截取数据
    for (LCChartViewModel *model in self.dataSource) {
        if (model.plots.count > self.xAxisTitleArray.count) {
            NSLog(@"展示的点数据比X轴默认的点多,请设置xAxisTitleArray");
            model.plots = [model.plots subarrayWithRange:NSMakeRange(0, self.xAxisTitleArray.count)];
        }
    }
    [self resetDataSource];
    [self drawYAxis];
    [self drawXAxis];
    [self drawTilte];
    [self drawYSeparators];
    if (self.chartViewType == LCChartViewTypeLine) {
        [self drawXSeparators];
        [self drawLineChartViewPots];
        [self drawLineChartViewLines];
    } else {
        [self drawBarChartViewBars];
    }
    [self drawDisplayLabels];
    [self addNote];
    [self addAnimation:self.showAnimation];
}

#pragma mark - 重置数据
- (void)resetDataSource {
    for (LCChartViewModel *model in self.dataSource) {
        if (model.plotButtons) {
            [model.plotButtons removeAllObjects];
            [model.plotButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
    }
    // 移除所有的Label,CAShapeLayer
    if (self.allSubView) {
        [self.allSubView makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.allSubView removeAllObjects];
    }
    if (self.firstLayers.count) {
        [self.firstLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.firstLayers removeAllObjects];
    }
    if (self.scondLayers.count) {
        [self.scondLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.scondLayers removeAllObjects];
    }
    if (self.xAxisLabels.count) {
        [self.xAxisLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.xAxisLabels removeAllObjects];
    }
    if (self.yAxisLabels.count) {
        [self.yAxisLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.yAxisLabels removeAllObjects];
    }
}

#pragma mark - 描绘Y轴
- (void)drawYAxis {
    axisLabelHieght = [LCMethod sizeWithText:@"x" fontSize:_axisFontSize].height;
    // 数据展示的高度
    dataChartHeight = self.LC_height - _topMargin - _xTextToAxis - axisLabelHieght;
    
    // ylabel之间的间隙
    yTextCenterMargin = dataChartHeight / _yAxisCount;
    yAxisMaxY = MAX(_topMargin - yTextCenterMargin / 2, 0);
    UIBezierPath *yAxisPath = [UIBezierPath bezierPath];
    _originPoint = CGPointMake(_yAxisToLeft, self.LC_height - axisLabelHieght - _xTextToAxis);
    [yAxisPath moveToPoint:_originPoint];
    [yAxisPath addLineToPoint:CGPointMake(_yAxisToLeft, yAxisMaxY)];
    [yAxisPath addLineToPoint:CGPointMake(_yAxisToLeft - (_axisWidth + 2), yAxisMaxY + (_axisWidth + 2))];
    [yAxisPath moveToPoint:CGPointMake(_yAxisToLeft, yAxisMaxY)];
    [yAxisPath addLineToPoint:CGPointMake(_yAxisToLeft + (_axisWidth + 2), yAxisMaxY + (_axisWidth + 2))];
    
    CAShapeLayer *shapeLayer = [self shapeLayerWithPath:yAxisPath lineWidth:_axisWidth fillColor:[UIColor clearColor] strokeColor:_axisColor];
    [self.layer addSublayer:shapeLayer];
    [self.firstLayers addObject:shapeLayer];
    
    // 添加Y轴Label
    for (int i = 0; i < _yAxisCount + 1; i++) {
        CGFloat avgValue = _yAxisMaxValue / (_yAxisCount);
        NSString *title = [NSString stringWithFormat:@"%.0f", avgValue * i];
        UILabel *label = [self labelWithTextColor:_yTextColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentRight lineNumber:1 tiltle:title fontSize:_axisFontSize];
        if (_yAxisLabelUIBlock) {
            _yAxisLabelUIBlock(label, i);
        }
        label.LC_x = 0;
        label.LC_height = axisLabelHieght;
        label.LC_width = _yAxisToLeft - _yTextToAxis;
        label.LC_centerY = _topMargin + (_yAxisCount - i) * yTextCenterMargin;
        [self addSubview:label];
        [self.yAxisLabels addObject:label];
    }
    [self.allSubView addObjectsFromArray:self.yAxisLabels];
    
    // yTitleLabel
    _yAxisLabel = [self labelWithTextColor:_axisColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft lineNumber:1 tiltle:self.yAxisTitle fontSize:_axisTitleSizeFont];
    if (_yAxisTitleLabelUIBlock) {
        _yAxisTitleLabelUIBlock(_yAxisLabel);
    }
    [_yAxisLabel sizeToFit];
    _yAxisLabel.LC_y = yAxisMaxY - _yAxisLabel.LC_height - 5;
    _yAxisLabel.LC_centerX = _originPoint.x;
    [self addSubview:_yAxisLabel];
    [self.allSubView addObject:_yAxisLabel];
    
    // 添加scrollview
    [self insertSubview:self.scrollView atIndex:0];
    self.scrollView.frame = CGRectMake(_yAxisToLeft, 0, self.LC_width - _yAxisToLeft, self.LC_height);
    
    self.scrollView.backgroundColor = self.backgroundColor = _backColor;
}

#pragma mark - 描绘X轴
- (void)drawXAxis {
    // 添加X轴Label
    for (int i = 0; i < self.xAxisTitleArray.count; i++) {
        NSString *title = self.xAxisTitleArray[i];
        
        UILabel *label = [self labelWithTextColor:_xTextColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:title fontSize:_axisFontSize];
        if (_xAxisLabelUIBlock) {
            _xAxisLabelUIBlock(label, i);
        }
        CGSize labelSize = [LCMethod sizeWithText:title fontSize:_axisFontSize];
        label.LC_x = (i + 1) * _xAxisTextMargin - labelSize.width / 2;
        label.LC_y = self.LC_height - labelSize.height;
        label.LC_size = labelSize;
        [self.scrollView addSubview:label];
        [self.xAxisLabels addObject:label];
    }
    [self.allSubView addObjectsFromArray:self.xAxisLabels];
    // 处理重叠label
    [self handleOverlapViewWithViews:self.xAxisLabels];
    // 画轴
    UIBezierPath *xAxisPath = [UIBezierPath bezierPath];
    [xAxisPath moveToPoint:CGPointMake(0, _originPoint.y)];
    xAxisMaxX = (self.xAxisTitleArray.count + 1) * _xAxisTextMargin;
    
    // scrollView的contentSize
    self.scrollView.contentSize = CGSizeMake(xAxisMaxX + self.chartViewRightMargin, 0);
    
    [xAxisPath addLineToPoint:CGPointMake(xAxisMaxX, _originPoint.y)];
    [xAxisPath addLineToPoint:CGPointMake(xAxisMaxX - (_axisWidth + 2), _originPoint.y - (_axisWidth + 2))];
    [xAxisPath moveToPoint:CGPointMake(xAxisMaxX, _originPoint.y)];
    [xAxisPath addLineToPoint:CGPointMake(xAxisMaxX - (_axisWidth + 2) , _originPoint.y + (_axisWidth + 2))];
    CAShapeLayer *xAxisLayer = [self shapeLayerWithPath:xAxisPath lineWidth:_axisWidth fillColor:[UIColor clearColor] strokeColor:_axisColor];
    [self.scrollView.layer addSublayer:xAxisLayer];
    [self.firstLayers addObject:xAxisLayer];
    
    // xTitleLabel
    _xAxisLabel = [self labelWithTextColor:_axisColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:self.xAxisTitle fontSize:_axisTitleSizeFont];
    if (_xAxisTitleLabelUIBlock) {
        _xAxisTitleLabelUIBlock(_xAxisLabel);
    }
    [_xAxisLabel sizeToFit];
    _xAxisLabel.LC_left = xAxisMaxX + 5;
    _xAxisLabel.LC_centerY = _originPoint.y;
    [self.scrollView addSubview:_xAxisLabel];
    [self.allSubView addObject:_xAxisLabel];
}

#pragma mark - 标题
- (void)drawTilte {
    // titleLabel
    UILabel *titleLabel = [self labelWithTextColor:_axisColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:_title fontSize:_titleFontSize];
    if (_comfigurateTitleLabel) {
        _comfigurateTitleLabel(titleLabel);
    }
    [titleLabel sizeToFit];
    titleLabel.LC_centerX = self.LC_width / 2;
    titleLabel.LC_y = 5;
    [self addSubview:titleLabel];
    [self.allSubView addObject:titleLabel];
}

#pragma mark - Y轴分割线
- (void)drawYSeparators {
    // 添加Y轴分割线
    for (int i = 0; i < self.yAxisLabels.count; i++) {
        CAShapeLayer *yshapeLayer = nil;
        UIBezierPath *ySeparatorPath = [UIBezierPath bezierPath];
        if (_showGridding) {
            [ySeparatorPath moveToPoint:CGPointMake(0, self.yAxisLabels[i].LC_centerY)];
            [ySeparatorPath addLineToPoint:CGPointMake(xAxisMaxX, self.yAxisLabels[i].LC_centerY)];
            yshapeLayer = [self shapeLayerWithPath:ySeparatorPath lineWidth:0.5 fillColor:[UIColor clearColor] strokeColor:_axisColor];
            yshapeLayer.lineDashPattern = @[@(3), @(3)];
            [self.scrollView.layer addSublayer:yshapeLayer];
        } else {
            [ySeparatorPath moveToPoint:CGPointMake(_yAxisToLeft, self.yAxisLabels[i].LC_centerY)];
            [ySeparatorPath addLineToPoint:CGPointMake(_yAxisToLeft + 5, self.yAxisLabels[i].LC_centerY)];
            yshapeLayer = [self shapeLayerWithPath:ySeparatorPath lineWidth:_axisWidth fillColor:[UIColor clearColor] strokeColor:_axisColor];
            [self.layer addSublayer:yshapeLayer];
        }
        [self.firstLayers addObject:yshapeLayer];
    }
}

#pragma mark - X轴分割线
- (void)drawXSeparators {
    // 添加X轴分割线
    for (int i = 0; i < self.xAxisLabels.count; i++) {
        CAShapeLayer *xshapeLayer = nil;
        UIBezierPath *xSeparatorPath = [UIBezierPath bezierPath];
        [xSeparatorPath moveToPoint:CGPointMake(self.xAxisLabels[i].LC_centerX, _originPoint.y)];
        if (_showGridding) {
            [xSeparatorPath addLineToPoint:CGPointMake(self.xAxisLabels[i].LC_centerX, self.yAxisLabels.lastObject.LC_centerY)];
            xshapeLayer = [self shapeLayerWithPath:xSeparatorPath lineWidth:0.5 fillColor:[UIColor clearColor] strokeColor:_axisColor];
            xshapeLayer.lineDashPattern = @[@(3), @(3)];
        } else {
            [xSeparatorPath addLineToPoint:CGPointMake(self.xAxisLabels[i].LC_centerX, _originPoint.y - 5)];
            xshapeLayer = [self shapeLayerWithPath:xSeparatorPath lineWidth:_axisWidth fillColor:[UIColor clearColor] strokeColor:_axisColor];
        }
        [self.scrollView.layer addSublayer:xshapeLayer];
        [self.firstLayers addObject:xshapeLayer];
    }
}

#pragma mark - 显示数据label
- (void)drawDisplayLabels {
    if (!_showPlotsLabel) {
        return;
    }
    // 多组数据显示label太混乱
    if (_chartViewType == LCChartViewTypeLine && self.dataSource.count > 1) {
        return;
    }
    NSInteger centerFlag = self.dataSource.count / 2;
    for (int i = 0 ; i < self.dataSource.count; i++) {
        LCChartViewModel *model = self.dataSource[i];
        NSMutableArray *plotLabels = [NSMutableArray array];
        for (int j = 0; j < model.plots.count; j++) {
            NSString *value = model.plots[j];
            if (value.floatValue < 0) {
                value = @"0";
            }
            UILabel *label = [self labelWithTextColor:self.plotsLabelColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:value fontSize:self.plotsLabelFontSize];
            label.tag = j;
            [label sizeToFit];
            switch (self.chartViewType) {
                case LCChartViewTypeLine:{
                    label.LC_centerX = self.xAxisLabels[j].LC_centerX;
                }
                    break;
                case LCChartViewTypeBar:{
                    if (self.dataSource.count % 2 == 0) { // 双数组
                        label.LC_centerX = self.xAxisLabels[j].LC_centerX + ( 1/2.0 + i - centerFlag) * _barWidth;
                    } else { // 单数组
                        label.LC_centerX = self.xAxisLabels[j].LC_centerX + (i - centerFlag) * _barWidth;
                    }
                }
                    break;
                    
                default:
                    break;
            }
            label.LC_bottom = [self getValueHeightWith:value] - _displayPlotToLabel;
            [self.scrollView addSubview:label];
            [plotLabels addObject:label];
            [self.allSubView addObjectsFromArray:plotLabels];
            // 处理重叠label
            [self handleOverlapViewWithViews:plotLabels];
        }
    }
}

#pragma mark - 描绘折线图点和线
/** 描述折线图数据点 */
- (void)drawLineChartViewPots {
    for (int i = 0; i < self.dataSource.count; i++) {
        LCChartViewModel *model = self.dataSource[i];
        if (model.plotButtons.count) {
            [model.plotButtons removeAllObjects];
            [model.plotButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        // 画点
        for (int j = 0; j < model.plots.count; j++) {
            // 添加数据点button
            UIButton *button = [[UIButton alloc] init];
            [button addTarget:self action:@selector(plotsButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
            if (self.plotsButtonImage.length && self.plotsButtonSelectedImage.length) {
                [button setBackgroundImage:[UIImage imageNamed:self.plotsButtonImage] forState:UIControlStateNormal];
                [button setBackgroundImage:[UIImage imageNamed:self.plotsButtonSelectedImage] forState:UIControlStateSelected];
            } else {
                [button setBackgroundImage:[LCMethod imageFromColor:self.plotsButtonColor rect:CGRectMake(0, 0, 1, 1)] forState:UIControlStateNormal];
                [button setBackgroundImage:[LCMethod imageFromColor:self.plotsButtonSelectedColor rect:CGRectMake(0, 0, 1, 1)] forState:UIControlStateSelected];
            }
            button.tag = j;
            button.LC_size = CGSizeMake(self.plotsButtonWH, self.plotsButtonWH);
            button.center = CGPointMake(self.xAxisLabels[j].LC_centerX, [self getValueHeightWith:model.plots[j]]);
            button.layer.cornerRadius = self.plotsButtonWH / 2;
            button.layer.masksToBounds = YES;

            [self.allSubView addObject:button];
            [model.plotButtons addObject:button];
            [self.scrollView addSubview:button];
            // 处理重叠点
            [self handleOverlapViewWithViews:model.plotButtons];
        }
    }
}

/** 根据数据点画线 */
- (void)drawLineChartViewLines {
    for (LCChartViewModel *model in self.dataSource) {
        UIBezierPath *lineChartPath = [UIBezierPath bezierPath];
        // 填充
        CAShapeLayer *lineShapeLayer = nil;
        if (self.lineChartFillView) {
            [lineChartPath moveToPoint:CGPointMake(model.plotButtons.firstObject.center.x, _originPoint.y)];
            for (int i = 0; i < model.plotButtons.count; i++) {
                [lineChartPath addLineToPoint:model.plotButtons[i].center];
            }
            [lineChartPath addLineToPoint:CGPointMake(model.plotButtons.lastObject.center.x, _originPoint.y)];
            lineShapeLayer = [LCMethod shapeLayerWithPath:lineChartPath lineWidth:self.lineChartWidth fillColor:self.lineChartFillViewColor strokeColor:model.color];
        } else {
            // 不填充
            [lineChartPath moveToPoint:model.plotButtons.firstObject.center];
            for (int i = 1; i < model.plotButtons.count; i++) {
                [lineChartPath addLineToPoint:model.plotButtons[i].center];
            }
            lineShapeLayer = [self shapeLayerWithPath:lineChartPath lineWidth:self.lineChartWidth fillColor:[UIColor clearColor] strokeColor:model.color];
        }
        [self.scondLayers addObject:lineShapeLayer];
        [self.scrollView.layer insertSublayer:lineShapeLayer below:model.plotButtons.firstObject.layer];
    }
    
}

#pragma mark - ChartViewBar柱状图
/** 根据显示点描绘柱状图 */
- (void)drawBarChartViewBars {
    NSInteger centerFlag = self.dataSource.count / 2;
    for (int i = 0; i < self.dataSource.count; i++) {
        LCChartViewModel *model = self.dataSource[i];
        for (int j = 0; j < model.plots.count; j++) {
            UIBezierPath *barPath = [UIBezierPath bezierPath];
            CGFloat startPointX = 0;
            switch (self.dataSource.count % 2) {
                case 0:{ // 双数组
                    startPointX = self.xAxisLabels[j].LC_centerX + ( 1/2.0 + i - centerFlag) * _barWidth;
                }
                    break;
                case 1:{ // 单数组
                    startPointX = self.xAxisLabels[j].LC_centerX + (i - centerFlag) * _barWidth;
                }
                    break;
                default:
                    break;
            }
            [barPath moveToPoint:CGPointMake(startPointX, _originPoint.y)];
            [barPath addLineToPoint:CGPointMake(startPointX, [self getValueHeightWith:model.plots[j]])];
            CAShapeLayer *barShapeLayer = [self shapeLayerWithPath:barPath lineWidth:_barWidth fillColor:model.color strokeColor:model.color];
            [self.scondLayers addObject:barShapeLayer];
            [self.scrollView.layer addSublayer:barShapeLayer];
        }
    }
}

#pragma mark - private method
/** 处理label重叠显示的情况 */
- (void)handleOverlapViewWithViews:(NSArray <UIView *>*)views {
    // 如果Label的文字有重叠，那么隐藏
    UIView *firstView = views.firstObject;
    for (int i = 1; i < views.count; i++) {
        UIView *view = views[i];
        CGFloat maxX = CGRectGetMaxX(firstView.frame);
        if ((maxX + 3) > view.LC_x) {
            view.hidden = YES;
        }else{
            view.hidden = NO;
            firstView = view;
        }
    }
}

- (CAShapeLayer *)shapeLayerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)lineWidth fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.fillColor = fillColor.CGColor;
    shapeLayer.strokeColor = strokeColor.CGColor;
    shapeLayer.lineCap = kCALineCapButt;
    shapeLayer.lineJoin = kCALineJoinBevel;
    shapeLayer.path = path.CGPath;
    return shapeLayer;
}

/** 数据点高度 */
- (CGFloat)getValueHeightWith:(NSString *)value {
    return dataChartHeight - value.floatValue / _yAxisMaxValue * dataChartHeight + _topMargin;
}

/** label */
- (UILabel *)labelWithTextColor:(UIColor *)textColor backColor:(UIColor *)backColor textAlignment:(NSTextAlignment)textAlignment lineNumber:(NSInteger)number tiltle:(NSString *)title fontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = textColor;
    if (backColor) {
        label.backgroundColor = backColor;
    }
    label.textAlignment = textAlignment;
    label.numberOfLines = number;
    if (fontSize != 0) {
        label.font = [UIFont systemFontOfSize:fontSize];
    }
    
    return label;
}

/** 根据颜色生成图片 */
+ (UIImage *)imageFromColor:(UIColor *)color rect:(CGRect)rect{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)addAnimation:(NSArray <CAShapeLayer *>*)shapeLayers delegate:(id<CAAnimationDelegate>)delegate duration:(NSTimeInterval)duration {
    CABasicAnimation *stroke = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    stroke.delegate = delegate;
    stroke.duration = duration;
    stroke.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    stroke.fromValue = [NSNumber numberWithFloat:0.0f];
    stroke.toValue = [NSNumber numberWithFloat:1.0f];
    for (CAShapeLayer *shapeLayer in shapeLayers) {
        [shapeLayer addAnimation:stroke forKey:nil];
    }
}

#pragma mark - response

- (void)plotsButtonDidClick:(UIButton *)button {
    if (self.plotClickBlock) {
        self.plotClickBlock(button.tag);
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    for (CAShapeLayer *layer in self.scondLayers) {
        layer.hidden = NO;
    }
    [self addAnimation:self.scondLayers delegate:nil duration:duration];
    
    [self.allSubView enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [UIView animateWithDuration:duration animations:^{
            obj.alpha = 1.0;
        }];
    }];
}


#pragma mark - scrollview的手势支持
/** 双击 */
- (void)tapGesture:(UITapGestureRecognizer *)tap {
    _xAxisTextMargin *= 1.5;
    self.orginXAxisMargin = _xAxisTextMargin;
    [self showChartView];
}

/** 捏合 */
- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer {

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.orginAnimation = self.showAnimation;
            self.showAnimation = NO;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            _xAxisTextMargin = recognizer.scale * self.orginXAxisMargin;
            if (self.chartViewType == LCChartViewTypeLine) {
                if (_xAxisTextMargin < 10) {
                    _xAxisTextMargin = 10;
                }
            }
            [self showChartView];
        }
            break;
        case UIGestureRecognizerStateEnded:{
            self.orginXAxisMargin = _xAxisTextMargin;
            self.showAnimation = self.orginAnimation;
        }
            break;
            
        default:
            break;
    }
}

/** addAnimation */
- (void)addAnimation:(BOOL)animation {
    if (animation) {
        [self.allSubView enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.alpha = 0.0;
        }];
        for (CAShapeLayer *layer in self.scondLayers) {
            layer.hidden = YES;
        }
        [self addAnimation:self.firstLayers delegate:self duration:0.5];
    }
}

/** 添加注释 */
- (void)addNote {
    if (!_showNote) {
        return;
    }
    if (_noteView) {
        [_noteView removeFromSuperview];
        _noteView = nil;
    }
    [self addSubview:self.noteView];
    for (int i = 0; i < self.dataSource.count; i ++) {
        LCChartViewModel *model = self.dataSource[i];
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        view.frame = CGRectMake(0, noteViewRowH * i, self.noteView.LC_width, noteViewRowH);
        [self.noteView addSubview:view];
        // label
        UILabel *label = [self labelWithTextColor:_yTextColor backColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft lineNumber:1 tiltle:model.project fontSize:_axisFontSize];
        label.adjustsFontSizeToFitWidth = YES;
        label.frame = CGRectMake(view.LC_width / 2 + 10, 0, view.LC_width / 2, view.LC_height);
        [view addSubview:label];
        [self.allSubView addObject:label];
        
        if (self.chartViewType == LCChartViewTypeLine) {
            // 画线
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, view.LC_height / 2)];
            [path addLineToPoint:CGPointMake(self.noteView.LC_width / 2 , view.LC_height / 2)];
            
            CAShapeLayer *shapeLayer = [self shapeLayerWithPath:path lineWidth:2 fillColor:[UIColor clearColor] strokeColor:model.color];
            [view.layer addSublayer:shapeLayer];
            [self.firstLayers addObject:shapeLayer];
        } else {
            // 方块
            UIBezierPath *path = [UIBezierPath bezierPath];
            CGFloat squareH = noteViewRowH - 2 * 2;
            [path moveToPoint:CGPointMake(view.LC_width / 2 - squareH, view.LC_height / 2)];
            [path addLineToPoint:CGPointMake(view.LC_width / 2 , view.LC_height / 2)];
            
            CAShapeLayer *shapeLayer = [self shapeLayerWithPath:path lineWidth:squareH fillColor:[UIColor clearColor] strokeColor:model.color];
            [view.layer addSublayer:shapeLayer];
            [self.firstLayers addObject:shapeLayer];
        }
    }
    self.noteView.contentSize = CGSizeMake(0, noteViewRowH * self.dataSource.count);
}

#pragma mark - setter

- (void)setXAxisTextMargin:(CGFloat)xAxisTextMargin {
    _xAxisTextMargin = xAxisTextMargin;
    _xArrowsToText = xAxisTextMargin;
}

- (void)setChartViewXAxisTextMargin:(CGFloat)xAxisTextMargin {
    _xAxisTextMargin = xAxisTextMargin;
    _orginXAxisMargin = xAxisTextMargin;
}

#pragma mark - getter

- (NSMutableArray<UILabel *> *)yAxisLabels {
    if (!_yAxisLabels) {
        _yAxisLabels = [[NSMutableArray alloc] init];
    }
    return _yAxisLabels;
}

- (NSMutableArray<UILabel *> *)xAxisLabels {
    if (!_xAxisLabels) {
        _xAxisLabels = [[NSMutableArray alloc] init];
    }
    return _xAxisLabels;
}

- (NSMutableArray<CAShapeLayer *> *)firstLayers {
    if (!_firstLayers) {
        _firstLayers = [[NSMutableArray alloc] init];
    }
    return _firstLayers;
}

- (NSMutableArray<CAShapeLayer *> *)scondLayers {
    if (!_scondLayers) {
        _scondLayers = [[NSMutableArray alloc] init];
    }
    return _scondLayers;
}

- (NSMutableArray<UIView *> *)allSubView {
    if (!_allSubView) {
        _allSubView = [[NSMutableArray alloc] init];
    }
    return _allSubView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
        // 双击事件
        [_scrollView addGestureRecognizer:self.twoTap];
        // 捏合手势
        [_scrollView addGestureRecognizer:self.pinch];
    }
    return _scrollView;
}

- (UIScrollView *)noteView {
    if (!_noteView) {
        _noteView = [[UIScrollView alloc] init];
        _noteView.showsVerticalScrollIndicator = NO;
        _noteView.LC_width = 80;
        _noteView.LC_height = _topMargin - 2 * 10;
        _noteView.LC_right = self.LC_width - 10;
        _noteView.LC_y = 10;
    }
    return _noteView;
}

- (UITapGestureRecognizer *)twoTap {
    if (!_twoTap) {
        _twoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        _twoTap.numberOfTapsRequired = 2;
    }
    return _twoTap;
}

- (UIPinchGestureRecognizer *)pinch {
    if (!_pinch) {
        _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    }
    return _pinch   ;
}

- (CGFloat)xArrowsToText {
    if (_xArrowsToText < 8) {
        return 8;
    }
    return _xArrowsToText;
}

@end
