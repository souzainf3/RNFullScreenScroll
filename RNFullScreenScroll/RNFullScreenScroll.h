//
//  RNFullScreenScroll.h
//  ExpandingView
//
//  Created by Romilson Nunes on 20/09/13.
//
//

#import <Foundation/Foundation.h>

@interface RNFullScreenScroll : NSObject

@property (nonatomic, weak) UIViewController* viewController;
@property (nonatomic, strong) UIScrollView* scrollView;


@property (nonatomic) BOOL shouldHideNavigationBarOnScroll; // default = YES
@property (nonatomic) BOOL shouldHideTabBarOnScroll;        // default = YES


- (id)initWithViewController:(UIViewController*)viewController
                  scrollView:(UIScrollView*)scrollView;

// used in UIViewController+YIFullScreenScroll
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;



@end
