//
//  Created by 汤维炜 on 16/5/10.
//  Copyright © 2016年 Tommy. All rights reserved.
//

#import "PressureSlider.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToAng(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )
#define DefaultAngle 133

@implementation PressureSlider
{
    CGFloat radius;
    CGFloat angle;
    int fixedAngle;
    NSMutableDictionary* labelsWithPercents;
    NSArray* labelsEvenSpacing;
    BOOL p_rotation;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Defaults
        _maximumValue = 100.0f;
        _minimumValue = 0.0f;
        _currentValue = 0.0f;
        _lineWidth = 1;
        _unfilledColor = [UIColor blackColor];
        _filledColor = [UIColor redColor];
        _handleColor = _filledColor;
        _labelFont = [UIFont systemFontOfSize:10.0f];
        _snapToLabels = NO;
        angle = self.endAngle;
        _labelColor = [UIColor redColor];
        _normalPointColor = _handleColor;
        _hightLightPointColor = _unfilledColor;
        
        angle = 0;
        radius = self.frame.size.height/2 - _lineWidth/2 - 40;
        p_rotation = NO;
        _hightLightLabelIndex = 9999;
    }
    return self;
}

#pragma mark - drawing methods

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //Draw the unfilled circle
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(self.startAngle), ToRad(self.endAngle), 0);
    [_unfilledColor setStroke];
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGFloat startRadian = M_PI - ToRad(self.endAngle);
    // 131 ~ 0 ~ -89 , 270 ~ 227
    // 131 + 89 + 42 = 262
    
    CGFloat p = 100 * 5 / 6;
    if ([labelsEvenSpacing count] == 4) {
        
    }
    if (self.progress <= 50) {
        angle = 131 - self.progress / 50 * 131;
    } else if (self.progress <= p) {
        angle = -(self.progress - 50) / 33 * 89;
    } else {
        angle = 270 - (self.progress - p) / (100 - p) * 42;
    }
    
    
    //Draw the filled circle
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius, startRadian, startRadian - ToRad(angle + 228), 0);
    [_filledColor setStroke];
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //Add the labels (if necessary)
    if(labelsEvenSpacing != nil) {
        [self drawLabels:ctx];
    }
    
    //The draggable part
//    [self drawHandle:ctx];
}

-(void) drawHandle:(CGContextRef)ctx{
    CGContextSaveGState(ctx);
    CGPoint handleCenter =  [self pointFromAngle: angle];
    [_handleColor set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x-3, handleCenter.y-3, _lineWidth+5, _lineWidth+5));
    
    CGContextRestoreGState(ctx);
}

-(void) drawLabels:(CGContextRef)ctx {
    if(labelsEvenSpacing == nil || [labelsEvenSpacing count] < 3 || [labelsEvenSpacing count] > 8) {
        return;
    } else {
        
        NSDictionary *attributes;
        
        for (int i=0; i<[labelsEvenSpacing count]; i++) {
            NSString* label = [labelsEvenSpacing objectAtIndex:i];
            
            CGFloat percentageAlongCircle = i/((float)[labelsEvenSpacing count] - 1);
            
            CGFloat degreesForLabel = percentageAlongCircle * (self.endAngle - self.startAngle);
            CGPoint closestPointOnCircleToLabel = [self labelPointFromAngle:degreesForLabel];
            
            CGFloat labelWidth = [self widthOfString:label withFont:_labelFont];
            CGFloat labelHeight = [self heightOfString:label withFont:_labelFont];
            CGRect labelLocation = CGRectMake(closestPointOnCircleToLabel.x, closestPointOnCircleToLabel.y, labelWidth, labelHeight);
            
            if (self.hightLightLabelIndex < [labelsEvenSpacing count] && i == self.hightLightLabelIndex) {
                attributes = @{ NSFontAttributeName: _labelFont?:[UIFont systemFontOfSize:11],
                                NSForegroundColorAttributeName: _hightLightPointColor};
            } else {
                attributes = @{ NSFontAttributeName: _labelFont?:[UIFont systemFontOfSize:11],
                                NSForegroundColorAttributeName: _labelColor};
            }
            
            // 画点
            [self.normalPointColor set];
            if (i < self.hightLightPointCount) {
                [_hightLightPointColor set];
            }
            CGFloat circleRadius = _lineWidth + 5;
            CGFloat smallPointX = labelLocation.origin.x - circleRadius / 2;
            CGFloat smallPointY = labelLocation.origin.y - circleRadius / 2;
            
            switch (i) {
                case 1: {
                    if ([labelsEvenSpacing count] == 4) {
                        smallPointY += 2;
                    } else {
                        smallPointX += 1.f;
                    }
                    
                    break;
                }
                    
                case 2: {
                    if ([labelsEvenSpacing count] != 4) {
                        smallPointY += 1;
                    }
                    
                    if ([labelsEvenSpacing count] == 7) {
                        smallPointY += 1;
                    }
                    
                    break;
                }
                    
                case 3: {
                    if ([labelsEvenSpacing count] == 4) {
                        smallPointX += 1;
                    } else {
                        smallPointY += 1;
                        smallPointX += 1;
                    }
                    
                    break;
                }
                    
                case 4: {
                    smallPointX += 0.5;
                    break;
                }
                    
                case 5: {
                    smallPointX += 1;
                    break;
                }
                case 6: {
                    smallPointX += 1;
                    break;
                }
            }
            
            CGContextFillEllipseInRect(ctx, CGRectMake(smallPointX, smallPointY, circleRadius, circleRadius));
            
            CGFloat a = -(DefaultAngle - (self.endAngle - self.startAngle) / ([labelsEvenSpacing count] - 1));
            if ([labelsEvenSpacing count] == 5) {
                if (i == 1) {
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= self.frame.size.width / 2.38 + labelWidth / 2;
                    labelLocation.origin.y = self.frame.size.width / 4.45;
                    p_rotation = YES;
                } else if (i == 3) {
                    a = -a;
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= self.frame.size.width / 5.5 + labelWidth / 2;
                    labelLocation.origin.y -= self.frame.size.width + 13;
                    p_rotation = YES;
                } else if (i == 2) {
                    labelLocation.origin.x -= labelWidth / 2;
                    labelLocation.origin.y -= 20;
                } else {
                    labelLocation.origin.x += 2 - labelWidth / 2;
                    labelLocation.origin.y += 10;
                }
            } else if ([labelsEvenSpacing count] == 4) {
                if (i == 1) {
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x = labelLocation.origin.x - self.frame.size.width / 3.21 + labelWidth / 2;
                    labelLocation.origin.y += 10;
                    p_rotation = YES;
                } else if (i == 2) {
                    a = -a;
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x = self.frame.size.width / 1.43 - labelWidth / 2;
                    labelLocation.origin.y = labelLocation.origin.y - self.frame.size.width / 1.45 + 8;
                    p_rotation = YES;
                } else {
                    labelLocation.origin.x += 2 - labelWidth / 2;
                    labelLocation.origin.y += 10;
                }
            } else if ([labelsEvenSpacing count] == 6) {
                if (i == 1) {
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= self.frame.size.width / 1.85 + labelWidth / 2;
                    labelLocation.origin.y -= self.frame.size.width / 3.45;
                    p_rotation = YES;
                } else if (i == 2) {
                    a = 0.35 * a;
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= self.frame.size.width / 8.5 + labelWidth / 2;
                    labelLocation.origin.y -= -self.frame.size.width / 15;
                    p_rotation = YES;
                } else if (i == 3) {
                    a = 0.35 * -a;
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= labelWidth / 2;
                    labelLocation.origin.y -= self.frame.size.width / 2.5;
                    p_rotation = YES;
                } else if (i == 4) {
                    a = -a;
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= self.frame.size.width / 3.5 + labelWidth / 2;
                    labelLocation.origin.y -= self.frame.size.width * 1.27;
                    p_rotation = YES;
                } else {
                    labelLocation.origin.x += 2 - labelWidth / 2;
                    labelLocation.origin.y += 10;
                }
            } else if ([labelsEvenSpacing count] == 7) {
                if (i == 1) {
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= self.frame.size.width / 1.61 + labelWidth / 2;
                    labelLocation.origin.y -= self.frame.size.width / 2.4;
                    p_rotation = YES;
                } else if (i == 2) {
                    a = 0.45 * a;
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= self.frame.size.width / 4.8 + labelWidth / 2;
                    labelLocation.origin.y -= -self.frame.size.width / 30;
                    p_rotation = YES;
                } else if (i == 3) {
                    labelLocation.origin.x -= labelWidth / 2;
                    labelLocation.origin.y -= 20;
                } else if (i == 4) {
                    a = 0.45 * -a;
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= self.frame.size.width / 30 + labelWidth / 2;
                    labelLocation.origin.y -= self.frame.size.width / 1.65;
                    p_rotation = YES;
                } else if (i == 5) {
                    a = -a;
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= self.frame.size.width / 2.7 + labelWidth / 2;
                    labelLocation.origin.y -= self.frame.size.width * 1.41;
                    p_rotation = YES;
                } else {
                    labelLocation.origin.x += 2 - labelWidth / 2;
                    labelLocation.origin.y += 10;
                }
            } else if ([labelsEvenSpacing count] == 3) {
                labelLocation.origin.x += 2 - labelWidth / 2;
                labelLocation.origin.y += 10;
                
                if (i == 1) {
                    labelLocation.origin.y -= 30;
                }
            } else if ([labelsEvenSpacing count] == 8) {
                if (i == 1) {
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= self.frame.size.width / 1.50 + labelWidth / 2;
                    labelLocation.origin.y -= self.frame.size.width / 1.95;
                    p_rotation = YES;
                } else if (i == 2) {
                    a = 0.6 * a;
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= self.frame.size.width / 2.97 + labelWidth / 2;
                    labelLocation.origin.y -= self.frame.size.width / 23;
                    p_rotation = YES;
                } else if (i == 3) {
                    a = 0.2 * a;
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= (self.frame.size.width / 15.0 + labelWidth / 2);
                    labelLocation.origin.y += self.frame.size.width / 20;
                    p_rotation = YES;
                } else if (i == 4) {
                    a = 0.2 * -a;
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x += (self.frame.size.width / 50.0 - labelWidth / 2);
                    labelLocation.origin.y -= self.frame.size.width / 3.6;
                    p_rotation = YES;
                } else if (i == 5) {
                    a = 0.6 * -a;
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= (self.frame.size.width / 9 + labelWidth / 2);
                    labelLocation.origin.y -= self.frame.size.width / 1.14;
                    p_rotation = YES;
                } else if (i == 6) {
                    a = 0.95 * -a;
                    CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(a)));
                    labelLocation.origin.x -= (self.frame.size.width / 2.98 + labelWidth / 2);
                    labelLocation.origin.y -= self.frame.size.width / 0.683;
                    p_rotation = YES;
                } else {
                    labelLocation.origin.x += 2 - labelWidth / 2;
                    labelLocation.origin.y += 10;
                }
            }
            
            [label drawInRect:labelLocation withAttributes:attributes];
            
            if (p_rotation) {
                CGContextConcatCTM(ctx, CGAffineTransformMakeRotation(ToRad(-a)));
                p_rotation = NO;
            }
        }
    }
}

#pragma mark - UIControl functions

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    
    return YES;
}

-(BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint lastPoint = [touch locationInView:self];
    [self moveHandle:lastPoint];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    if(_snapToLabels && labelsEvenSpacing != nil) {
        CGPoint bestGuessPoint;
        float minDist = 360;
        for (int i=0; i<[labelsEvenSpacing count]; i++) {
            CGFloat percentageAlongCircle = i/(float)[labelsEvenSpacing count];
            CGFloat degreesForLabel = percentageAlongCircle * 360;
            if(fabs(fixedAngle - degreesForLabel) < minDist) {
                minDist = fabs(fixedAngle - degreesForLabel);
                bestGuessPoint = [self pointFromAngle:degreesForLabel + 90 + 180];
            }
        }
        CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        angle = floor(AngleFromNorth(centerPoint, bestGuessPoint, NO));
        _currentValue = [self valueFromAngle];
        [self setNeedsDisplay];
    }
}

-(void)moveHandle:(CGPoint)point {
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    int currentAngle = floor(AngleFromNorth(centerPoint, point, NO));
    angle = 360 - 90 - currentAngle;
    if (angle > 131 && angle <= 180) {
        angle = 131;
    }
    if (angle > 180 && angle < 227) {
        angle = 227;
    }
    _currentValue = [self valueFromAngle];
    
    [self setNeedsDisplay];
}

#pragma mark - helper functions

-(CGPoint)pointFromAngle:(int)angleInt{
    
    //Define the Circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - _lineWidth/2, self.frame.size.height/2 - _lineWidth/2);
    
    //Define The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(-angleInt-90))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(-angleInt-90)));
    
    return result;
}

- (CGPoint)labelPointFromAngle:(int)angleInt {
    //Define the Circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - _lineWidth/2, self.frame.size.height/2 - _lineWidth/2);
    
    //Define The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(angleInt + self.startAngle))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(angleInt + self.startAngle)));
    
    return result;
}

static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToAng(radians);
    return (result >=0  ? result : result + 360.0);
}

-(float) valueFromAngle {
    if(angle < 0) {
        _currentValue = -angle;
    } else {
        _currentValue = 270 - angle + 90;
    }
    fixedAngle = _currentValue;
    return (_currentValue*(_maximumValue - _minimumValue))/360.0f;
}

- (CGFloat) widthOfString:(NSString *)string withFont:(UIFont*)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

- (CGFloat) heightOfString:(NSString *)string withFont:(UIFont*)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].height;
}

- (void)setHightLightLabelIndex:(CGFloat)hightLightLabelIndex {
    _hightLightLabelIndex = hightLightLabelIndex;
    [self setNeedsDisplay];
}

#pragma mark - public methods
-(void)setInnerMarkingLabels:(NSArray*)labels{
    labelsEvenSpacing = labels;
    [self setNeedsDisplay];
}

- (void)updateSlider {
    [self setNeedsDisplay];
}

@end
