//
//  Created by 汤维炜 on 16/5/10.
//  Copyright © 2016年 Tommy. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface PressureSlider : UIControl

@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;
@property (nonatomic) float currentValue;

@property (nonatomic) int lineWidth;
@property (nonatomic, strong) UIColor* filledColor;
@property (nonatomic, strong) UIColor* unfilledColor;

@property (nonatomic, strong) UIColor* handleColor;

@property (nonatomic, strong) UIFont* labelFont;
@property (nonatomic, strong) UIColor* labelColor;
@property (nonatomic) BOOL snapToLabels;

// Radian
@property (nonatomic, assign) CGFloat startAngle;   // 起始角度
@property (nonatomic, assign) CGFloat endAngle;     // 结束角度
@property (nonatomic, assign) CGFloat offsetAngle;   // 从起始角度偏移多少度
@property (nonatomic, strong) UIColor *normalPointColor;    // 默认工作颜色
@property (nonatomic, strong) UIColor *hightLightPointColor;    // 高亮节点颜色
@property (nonatomic, assign) CGFloat hightLightPointCount;     // 高亮节点数
@property (nonatomic, assign) CGFloat hightLightLabelIndex;     // 高亮文字下标
@property (nonatomic, assign) CGFloat progress;     // 进度 0 ~ 100



-(void)setInnerMarkingLabels:(NSArray*)labels;
- (void)updateSlider;

@end
