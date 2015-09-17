//
//  SecondView.m
//  EventDelivery
//
//  Created by scott on 15/9/15.
//  Copyright © 2015年 xbdx. All rights reserved.
//

#import "SecondView.h"

@implementation SecondView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"SecondView:touchesBegan");
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    return  [super hitTest:point withEvent:event];
//}
//

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    return NO;
//}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            NSLog(@"SecondView:Play");
            break;
            
        default:
            break;
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
