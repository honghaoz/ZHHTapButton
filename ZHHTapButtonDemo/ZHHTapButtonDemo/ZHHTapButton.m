//
//  ZHHTapButton.m
//
//  Created by Zhang Honghao on 6/13/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "ZHHTapButton.h"

#define NORMAL_BUTTON_ALPHA 1.0
#define DIMMED_STATE_ALPHA 0.7
#define HIGHLIGHT_BUTTON_ALPHA 0.55

@implementation ZHHTapButton {
    CGFloat _circleWidth; // Surrounding circle width
    CGFloat _shrinkWidth; // Widht between outer circle and inner button
    CGPoint touchBeginPoint; // Begin point in button view
    CGPoint touchEndPoint; // End point in button view

    CGFloat _shouldTapRadius; // The radius of touchable circle
    BOOL _shouldPassTouch; // Whether the touch on button should paased throught to the parent view

    UIImageView* _pressableImageView; // Inner button imageView
    BOOL _isDimmed; // State for highlighted button
}

/**
 *  Initiate a button with frame and default color (white)
 *
 *  @param frame Button rect frame
 *
 *  @return a TTHRTapButton instance
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    // Default color is white
    UIColor* whiteColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.85];
    return [self initWithFrame:frame circleWidth:10 buttonColor:whiteColor circleColor:whiteColor];
}

/**
 *  Initiate a button with frame, circle width, button color and circlr color
 *
 *  @param frame    Button rect frame
 *  @param cirWidth Circle width
 *  @param btnColor The color of the button inside the circle
 *  @param cirColor The color of the circle
 *
 *  @return a TTHRTapButton instance
 */
- (instancetype)initWithFrame:(CGRect)frame circleWidth:(CGFloat)cirWidth buttonColor:(UIColor*)btnColor circleColor:(UIColor*)cirColor
{
    self = [super initWithFrame:frame];
    if (self) {
        // Init values
        _circleWidth = cirWidth;
        _shrinkWidth = 9 + _circleWidth;
        _shouldTapRadius = MAX(frame.size.height, frame.size.width) / 2;
        _shouldPassTouch = YES;
        
        self.buttonColor = btnColor;
        self.buttonCircleColor = cirColor;
        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
        [btnColor getRed:&red green:&green blue:&blue alpha:&alpha];
        self.buttonColorHighLighted = [UIColor colorWithRed:red green:green blue:blue alpha:alpha - 0.3];
        _isDimmed = NO;

        // Set background image for two states
        //        [self setBackgroundImage:[self imageWithButtonColor:btnColor circleColor:cirColor] forState:UIControlStateNormal];
        //        [self setBackgroundImage:[self imageWithButtonColor:self.buttonColorHighLighted circleColor:cirColor] forState:UIControlStateHighlighted];

        // Set outer circle image
        [self setBackgroundImage:[self imageWithButtonColor:[UIColor clearColor] circleColor:cirColor] forState:UIControlStateNormal];
        // Set inner circle image
        _pressableImageView = [[UIImageView alloc] initWithImage:[self imageWithButtonColor:self.buttonColor circleColor:[UIColor clearColor]]];
        _pressableImageView.alpha = NORMAL_BUTTON_ALPHA;
        [self addSubview:_pressableImageView];
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

/**
 *  Set highlighted, there will be a animation of transiting from normal state to hightlight state (dimmed)
 *
 *  @param highlighted
 */
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    // Normal to highlighted
    if (!_isDimmed) {
        if (highlighted) {
            // NSLog(@"normal -> high");
            _pressableImageView.alpha = HIGHLIGHT_BUTTON_ALPHA;
        }
        // Highlighted to normal
        else {
            // NSLog(@"high -> normal")
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 _pressableImageView.alpha = NORMAL_BUTTON_ALPHA;
                             }
                             completion:nil];
        }
    }
}


- (void)setbuttonColor:(UIColor*)color
{
    _buttonColor = color;
}

- (void)setbuttonCircleColor:(UIColor*)color
{
    _buttonCircleColor = color;
}

- (void)setbuttonColorHighLighted:(UIColor*)color
{
    _buttonColorHighLighted = color;
}

- (void)setLabelAboveWithTitle:(NSString*)string andColor:(UIColor*)titleColor
{
    if (string == nil || [string isEqualToString:@""]) {
        [_labelAbove removeFromSuperview];
        return;
    } else {
        if (_labelAbove == nil) {
            _labelAbove = [[UILabel alloc] init];
        }
        [_labelAbove setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
        [_labelAbove setText:string];
        [_labelAbove setTextAlignment:NSTextAlignmentCenter];
        [_labelAbove setTextColor:titleColor];
        [_labelAbove setAdjustsFontSizeToFitWidth:YES];
        [_labelAbove sizeToFit];
        [_labelAbove setNumberOfLines:0];

        CGFloat width = _labelAbove.bounds.size.width;
        CGFloat height = _labelAbove.bounds.size.height;
        CGFloat x = (self.bounds.size.width - width) / 2;
        CGFloat y = self.titleLabel.frame.origin.y - height - 3;
        CGRect rect = CGRectMake(x, y, width, height);
        [_labelAbove setFrame:rect];
        [self addSubview:_labelAbove];
    }
}

- (void)setLabelBelowWithTitle:(NSString*)string andColor:(UIColor*)titleColor
{
    if (string == nil || [string isEqualToString:@""]) {
        [_labelBelow removeFromSuperview];
        return;
    } else {
        if (_labelBelow == nil) {
            _labelBelow = [[UILabel alloc] init];
        }
        [_labelBelow setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
        [_labelBelow setText:string];
        [_labelBelow setTextAlignment:NSTextAlignmentCenter];
        [_labelBelow setTextColor:titleColor];
        [_labelBelow setAdjustsFontSizeToFitWidth:YES];
        [_labelBelow sizeToFit];
        [_labelBelow setNumberOfLines:0];

        CGFloat width = _labelBelow.bounds.size.width;
        CGFloat height = _labelBelow.bounds.size.height;
        CGFloat x = (self.bounds.size.width - width) / 2;
        CGFloat y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 3;
        CGRect rect = CGRectMake(x, y, width, height);
        [_labelBelow setFrame:rect];
        [self addSubview:_labelBelow];
    }
}

#pragma mark - UIResponder methods

- (void)setShouldPassTouch:(BOOL)shouldPass
{
    _shouldPassTouch = shouldPass;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    //    LogMethod;
    for (UITouch* touch in touches) {
        touchBeginPoint = [touch locationInView:self];
    }
    [super touchesBegan:touches withEvent:event];
    if (_shouldPassTouch) {
        [self.nextResponder touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    //    LogMethod;
    //    [super touchesMoved:touches withEvent:event];
    if (_shouldPassTouch) {
        [self.nextResponder touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    //    LogMethod;
    for (UITouch* touch in touches) {
        touchEndPoint = [touch locationInView:self];
        // if touch end offset smaller than 15, touched
        if (abs(touchBeginPoint.x - touchEndPoint.x) < 15) {
            [super touchesEnded:touches withEvent:event];
        } else {
            [super touchesCancelled:touches withEvent:event];
        }
    }
    if (_shouldPassTouch) {
        [self.nextResponder touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    //    LogMethod;
    [super touchesCancelled:touches withEvent:event];
    if (_shouldPassTouch) {
        [self.nextResponder touchesCancelled:touches withEvent:event];
    }
}

#pragma mark - UIControl methods

- (void)enlargeShouldTapRaidus:(float)enlarge
{
    _shouldTapRadius += enlarge;
}

// Restrict the touch is responsible when it is inside the rounded button
- (BOOL)beginTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    //    CGFloat radius = self.bounds.size.height / 2;
    CGPoint touchedPoint = [touch locationInView:self];
    CGPoint center = CGPointMake(_shouldTapRadius, _shouldTapRadius);
    CGFloat distanceToCenter = sqrtf(pow(touchedPoint.x - center.x, 2) + pow(touchedPoint.y - center.y, 2));
    if (distanceToCenter < _shouldTapRadius - _shrinkWidth + _shouldTapRadius * 1 / 10) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Helper methods

/**
 *  Get Button Image using button color and circle color
 *
 *  @param btnColor color inside the circle
 *  @param cirColor color of the circle
 *
 *  @return UIImage of the button image
 */
- (UIImage*)imageWithButtonColor:(UIColor*)btnColor circleColor:(UIColor*)cirColor
{
    CGFloat cirRed = 0.0, cirGreen = 0.0, cirBlue = 0.0, cirAlpha = 0.0;
    [cirColor getRed:&cirRed green:&cirGreen blue:&cirBlue alpha:&cirAlpha];

    CGFloat btnRed = 0.0, btnGreen = 0.0, btnBlue = 0.0, btnAlpha = 0.0;
    [btnColor getRed:&btnRed green:&btnGreen blue:&btnBlue alpha:&btnAlpha];

    //    UIGraphicsBeginImageContext(self.bounds.size);
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1);
    CGContextSetRGBStrokeColor(ctx, cirRed, cirGreen, cirBlue, cirAlpha);
    CGContextSetRGBFillColor(ctx, btnRed, btnGreen, btnBlue, btnAlpha);

    // Draw rounded button
    CGRect roundRect = self.bounds;
    roundRect.size.height -= 2 * _shrinkWidth;
    roundRect.size.width -= 2 * _shrinkWidth;
    roundRect.origin.x = _shrinkWidth;
    roundRect.origin.y = _shrinkWidth;
    CGContextFillEllipseInRect(ctx, roundRect);

    // Draw Circle
    CGPoint center;
    center.x = self.bounds.size.width / 2.0;
    center.y = self.bounds.size.height / 2.0;
    CGFloat radius = self.bounds.size.height / 2;
    UIBezierPath* path = [[UIBezierPath alloc] init];
    path.lineWidth = _circleWidth; //shrinkPoints / 6;
    //[path moveToPoint:CGPointMake(center.x + radius - shrinkPoints, center.y)];
    [path addArcWithCenter:center radius:radius - path.lineWidth startAngle:0.0 endAngle:M_PI * 2.0 clockwise:YES];

    [path stroke];

    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/**
 *  Set the button to be dimmed state
 *
 *  @param isDim Whether need to dim
 */
- (void)setDimmed:(BOOL)isDim
{
    if (isDim) {
        //        CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
        //        [self.buttonColor getRed:&red green:&green blue:&blue alpha:&alpha];
        //        UIColor *dimColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha - 0.15];
        //        [self setBackgroundImage:[self imageWithButtonColor:dimColor circleColor:self.buttonCircleColor] forState:UIControlStateNormal];

        _pressableImageView.alpha = DIMMED_STATE_ALPHA;
        _isDimmed = YES;
    } else {
        //        [self setBackgroundImage:[self imageWithButtonColor:self.buttonColor circleColor:self.buttonCircleColor] forState:UIControlStateNormal];

        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             _pressableImageView.alpha = NORMAL_BUTTON_ALPHA;
                         }
                         completion:nil];
        _isDimmed = NO;
    }
    [self setNeedsDisplay];
}

@end
