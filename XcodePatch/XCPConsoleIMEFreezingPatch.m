//
//  XCPConsoleIMEFreezingPatch.m
//  XcodePatch
//
//  Created by Cyandev on 2022/3/29.
//

#import <Foundation/Foundation.h>

#import "hook_utils.h"

@interface XCPConsoleIMEFreezingPatch : NSObject
@end

@implementation XCPConsoleIMEFreezingPatch

+ (Class)buggyViewClass __attribute__((objc_direct)) {
    static Class cls = nil;
    if (!cls) {
        cls = objc_getClass("SourceEditor.SourceEditorContentView");
    }
    return cls;
}

+ (void)load {
    NSLog(@"** XCPConsoleIMEFreezingPatch loaded! **");
    
    Class targetCls = objc_getClass("_NSViewBackingLayer");
    SEL targetSEL = sel_registerName("layoutSublayers");
    xcp_hook_method(targetCls, targetSEL, ^id(IMP origIMP) {
        return ^(id _self) {
            static void *kResetTimerKey = &kResetTimerKey;
            static void *kLayoutCyclesKey = &kLayoutCyclesKey;
            
            id view = [_self delegate];
            if ([view class] == [self buggyViewClass]) {
                NSTimer *timer = objc_getAssociatedObject(view, kResetTimerKey);
                if (!timer) {
                    // Create a timer to reset the counter of the receiver view.
                    __weak id weakView = view;
                    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                        __strong id strongView = weakView;
                        if (!strongView) {
                            [timer invalidate];
                            return;
                        }
                        objc_setAssociatedObject(strongView, kLayoutCyclesKey, @(0), OBJC_ASSOCIATION_COPY_NONATOMIC);
                    }];
                    objc_setAssociatedObject(view, kResetTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                }
                
                NSInteger layoutCycles = ((NSNumber *) objc_getAssociatedObject(view, kLayoutCyclesKey)).integerValue;
                if (layoutCycles > 100) {
                    // Unreasonable layout cycles in one frame, ignore further invocation until
                    // the frame is finished.
                    return;
                }
                objc_setAssociatedObject(view, kLayoutCyclesKey, @(layoutCycles + 1), OBJC_ASSOCIATION_COPY_NONATOMIC);
            }
            
            ((void (*)(id, SEL)) origIMP)(_self, nil);
        };
    });
}

@end
