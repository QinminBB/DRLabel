//
//  DRLabel.m
//  DRLabel
//
//  Created by fanren on 16/6/23.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#import "DRLabel.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>


@interface DRLabel ()
{
    CTFrameRef  _frameRef;
}
@end

@implementation DRLabel

static dispatch_queue_t queue;

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.dr.label",  DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(dispatch_get_global_queue(0, 0), queue);
    });
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dealloc
{
    CFRelease(_frameRef);
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [self display];
}

- (void)display
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue, ^{
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        [weakSelf drawTextWithContext:contextRef];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.layer.contents = (__bridge id)(image.CGImage);
        });
    });
}

- (void)drawTextWithContext:(CGContextRef)context
{
    CTFramesetterRef setterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_text);
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    _frameRef = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, 0), pathRef, NULL);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0, self.frame.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    CTFrameDraw(_frameRef, context);
    
    CGContextRestoreGState(context);
    
    CFRelease(pathRef);
    CFRelease(setterRef);
}

- (void)urlForPoint:(CGPoint)point
{
    CFArrayRef arrRef = CTFrameGetLines(_frameRef);
    CFIndex count = CFArrayGetCount(arrRef);
    CGPoint origins[count];
    CTFrameGetLineOrigins(_frameRef, CFRangeMake(0, 0), origins);
    for (CFIndex i = 0; i < CFArrayGetCount(arrRef); i++) {
        CTLineRef lineRef = CFArrayGetValueAtIndex(arrRef, i);
        CGPoint linePoint = origins[i];
        CGRect flippedRect = [self getLineBounds:lineRef point:linePoint];
        CGRect resultRect = CGRectApplyAffineTransform(flippedRect, [self transformForCoreText]);
        resultRect = CGRectInset(resultRect, 0, -5);
        resultRect = CGRectOffset(resultRect, 0, 0);
        if (CGRectContainsPoint(resultRect, point)) {
            CGPoint rePoint = CGPointMake(point.x - CGRectGetMinX(resultRect), point.y - CGRectGetMidY(resultRect));
            CFIndex index = CTLineGetStringIndexForPosition(lineRef, rePoint);
            NSLog(@"index : %@", @(index));
        }
    }
}

- (CGRect)getLineBounds:(CTLineRef)lineRef point:(CGPoint)point
{
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

- (CGAffineTransform)transformForCoreText
{
    return CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.frame.size.height), 1, -1);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    [self urlForPoint:[touch locationInView:self]];
}

@end
