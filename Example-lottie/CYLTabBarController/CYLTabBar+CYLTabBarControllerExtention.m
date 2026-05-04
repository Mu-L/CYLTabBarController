/*
 //  CYLTabBarController
 //  CYLTabBarController
 //
 //  Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 03/06/19.
 //  Copyright © 2019 https://github.com/ChenYilong . All rights reserved.
 */

#import "CYLTabBar+CYLTabBarControllerExtention.h"
#import "UIView+CYLTabBarControllerExtention.h"
#import "UIControl+CYLTabBarControllerExtention.h"
#import "CYLTabBarController.h"
#import <objc/runtime.h>
#import <CYLTabBarController/CYLTabBarController-Swift.h>
#import "CYLTabBar.h"


@implementation CYLTabBar (CYLTabBarControllerExtention)

- (BOOL)cyl_hasPlusChildViewController {
    NSString *context = CYLPlusChildViewController.cyl_context;
    BOOL isSameContext = [context isEqualToString:self.context] && (context && (context.length > 0) && self.context && self.context.length > 0);
    BOOL isAdded = [[self cyl_tabBarController].viewControllers containsObject:CYLPlusChildViewController];
    BOOL isEverAdded = CYLPlusChildViewController.cyl_plusViewControllerEverAdded;
    if (CYLPlusChildViewController && isSameContext && isAdded && isEverAdded) {
        return YES;
    }
    return NO;
}

- (NSArray *)cyl_originalTabBarButtons {
    NSArray *tabBarButtons = [self cyl_tabBarButtonFromTabBarSubviews:[self cyl_sortedSubviews]];
    return tabBarButtons;
}

- (NSArray *)cyl_sortedSubviews {
    if (self.subviews.count == 0) {
        return self.subviews;
    }
    NSMutableArray *tabBarButtonArray = [NSMutableArray arrayWithCapacity:self.subviews.count];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj cyl_isTabButton]) {
            [tabBarButtonArray addObject:obj];
        }
    }];
    
    NSArray *sortedSubviews = [[tabBarButtonArray copy] sortedArrayUsingComparator:^NSComparisonResult(UIView * formerView, UIView * latterView) {
        CGFloat formerViewX = formerView.frame.origin.x;
        CGFloat latterViewX = latterView.frame.origin.x;
        return  (formerViewX > latterViewX) ? NSOrderedDescending : NSOrderedAscending;
    }];
    return sortedSubviews;
}

- (NSArray *)cyl_tabBarButtonFromTabBarSubviews:(NSArray *)tabBarSubviews {
    if (tabBarSubviews.count == 0) {
        return tabBarSubviews;
    }
    NSMutableArray *tabBarButtonMutableArray = [NSMutableArray arrayWithCapacity:tabBarSubviews.count];
    [tabBarSubviews enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj cyl_isTabButton]) {
            [tabBarButtonMutableArray addObject:obj];
            [obj cyl_setTabBarChildViewControllerIndex:idx];
        }
    }];
    if ([self cyl_hasPlusChildViewController]) {
        @try {
            UIControl *control = tabBarButtonMutableArray[CYLPlusButtonIndex];
            control.userInteractionEnabled = NO;
            control.hidden = YES;
        } @catch (NSException *exception) {}
    }
    return [tabBarButtonMutableArray copy];
}

- (NSArray *)cyl_visibleControls {
    NSMutableArray *originalTabBarButtons = [NSMutableArray arrayWithArray:[self.cyl_originalTabBarButtons copy]];
    BOOL notAdded = (NSNotFound == [originalTabBarButtons indexOfObject:CYLExternPlusButton]);
    if (CYLExternPlusButton && notAdded) {
        [originalTabBarButtons addObject:CYLExternPlusButton];
    }
        if (originalTabBarButtons.count == 0) {
            return nil;
        }
        NSMutableArray *tabBarButtonArray = [NSMutableArray arrayWithCapacity:originalTabBarButtons.count];
        [originalTabBarButtons enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat width = obj.frame.size.width;
            BOOL isInvisiable = obj.cyl_canNotResponseEvent;
            BOOL isNotSubView = (width < 10);
            BOOL canNotResponseEvent = isInvisiable || isNotSubView ;
            if (canNotResponseEvent) {
                return;
            }
            if (([obj cyl_isTabButton] || [obj cyl_isPlusButton] ) ) {
                [tabBarButtonArray addObject:obj];
            }
        }];
        
        NSArray *sortedSubviews = [[tabBarButtonArray copy] sortedArrayUsingComparator:^NSComparisonResult(UIView * formerView, UIView * latterView) {
            CGFloat formerViewX = formerView.frame.origin.x;
            CGFloat latterViewX = latterView.frame.origin.x;
            return  (formerViewX > latterViewX) ? NSOrderedDescending : NSOrderedAscending;
        }];
        return sortedSubviews;
}

- (NSArray<UIControl *> *)cyl_subTabBarButtons {
    NSMutableArray *subControls = [NSMutableArray arrayWithCapacity:self.cyl_visibleControls.count];
    [self.cyl_visibleControls enumerateObjectsUsingBlock:^(UIControl * _Nonnull control, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([control cyl_isPlusButton] && !CYLPlusChildViewController.cyl_plusViewControllerEverAdded) {
            return;
        }
        [subControls addObject:control];
    }];
    return subControls;
}

- (NSArray<UIControl *> *)cyl_subTabBarButtonsWithoutPlusButton {
    NSMutableArray *subControls = [NSMutableArray arrayWithCapacity:self.cyl_visibleControls.count];
    [self.cyl_visibleControls enumerateObjectsUsingBlock:^(UIControl * _Nonnull control, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([control cyl_isPlusButton]) {
            return;
        }
        [subControls addObject:control];
    }];
    return subControls;
}

- (UIControl *)cyl_tabBarButtonWithTabIndex:(NSUInteger)tabIndex {
    UIControl *selectedControl = [self cyl_visibleControlWithIndex:tabIndex];
    
    NSInteger plusViewControllerIndex = [self.cyl_tabBarController.viewControllers indexOfObject:CYLPlusChildViewController];
    BOOL isPlusViewControllerAdded =  CYLPlusChildViewController.cyl_plusViewControllerEverAdded && (plusViewControllerIndex != NSNotFound);
    
    if (isPlusViewControllerAdded) {
        return selectedControl;
    }
    
    @try {
        selectedControl = [self cyl_subTabBarButtonsWithoutPlusButton][tabIndex];
    } @catch (NSException *exception) {
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), exception.reason);
    }
    return selectedControl;
}

- (UIControl *)cyl_visibleControlWithIndex:(NSUInteger)index {
    UIControl *selectedControl;
    @try {
        NSArray *subControls =  self.cyl_visibleControls;
        selectedControl = subControls[index];
    } @catch (NSException *exception) {
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), exception.reason);
    }
    return selectedControl;
}
- (void)cyl_animationLottieImageWithSelectedControl:(UIControl *)selectedControl
                                     lottieFilePath:(NSString *)lottieFilePath
                                               size:(CGSize)size
                                    defaultSelected:(BOOL)defaultSelected {
#if __has_include(<Lottie/Lottie-Swift.h>)
    [selectedControl cyl_addLottieImageWithLottieFilePath:lottieFilePath size:size];
    [self cyl_stopAnimationOfAllLottieView];
    CYLLOTAnimationView *lottieView = (CYLLOTAnimationView *)selectedControl.cyl_lottieAnimationView;
    if (!lottieView) {
        [selectedControl cyl_addLottieImageWithLottieFilePath:lottieFilePath size:size];
    }
    if (lottieView && [lottieView isKindOfClass:[CYLLOTAnimationView class]]) {
        if (defaultSelected) {
            //Avoid triggering Lottie animation when index == 0 on app startup. 希望Lottie icon 启动后 index== 0 不执行动画 #389
            [lottieView animationProgress:1];
            [lottieView forceDrawingUpdate];
            return;
        }
        [lottieView animationProgress:0];
        [lottieView play];
    }
#else
#endif
}

- (void)cyl_stopAnimationOfAllLottieView {
#if __has_include(<Lottie/Lottie-Swift.h>)
    [self.cyl_visibleControls enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.cyl_lottieAnimationView stop];
    }];
#else
#endif
}

@end
