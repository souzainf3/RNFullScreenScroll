//
//  RNFullScreenScroll.m
//  ExpandingView
//
//  Created by Romilson Nunes on 20/09/13.
//
//

#import "RNFullScreenScroll.h"
#import <objc/runtime.h>
#import "UITabBarController+hidable.h"



static char __fullScreenScrollContext;


@implementation RNFullScreenScroll{
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    BOOL hidden;
    BOOL isAnimating;
    
    
    __weak UINavigationController* _navigationController;
    __weak UITabBarController*     _tabBarController;
}



#pragma mark -

#pragma mark Init/Dealloc

- (id)initWithViewController:(UIViewController*)viewController
                  scrollView:(UIScrollView*)scrollView
{
    return [self initWithViewController:viewController
                             scrollView:scrollView
                     ignoresTranslucent:YES];
}

- (id)initWithViewController:(UIViewController*)viewController
                  scrollView:(UIScrollView*)scrollView
          ignoresTranslucent:(BOOL)ignoresTranslucent
{
    self = [super init];
    if (self) {
        
        _viewController = viewController;
        
        _shouldHideNavigationBarOnScroll = YES;
        _shouldHideTabBarOnScroll = YES;
        _shouldHideUIBarsWhenNotDragging = NO;


        self.scrollView = scrollView;
        
        hidden = NO;
        isAnimating = NO;
        
    }
    return self;
}

- (void)dealloc
{
    self.scrollView = nil;
}

#pragma mark -

#pragma mark Accessors

- (void)setScrollView:(UIScrollView *)scrollView
{
    if (scrollView != _scrollView) {
        
        if (_scrollView) {
            [_scrollView removeObserver:self forKeyPath:@"contentOffset" context:&__fullScreenScrollContext];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        }
        
        _scrollView = scrollView;
        
        if (_scrollView) {
            [_scrollView addObserver:self forKeyPath:@"contentOffset" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&__fullScreenScrollContext];
            
            //
            // observe willEnterForeground to properly set both navBar & tabBar
            // (fixes https://github.com/inamiy/YIFullScreenScroll/issues/5)
            //
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(onWillEnterForegroundNotification:)
                                                         name:UIApplicationWillEnterForegroundNotification
                                                       object:nil];
            
        }
        
    }
}


#pragma mark - The Magic!

-(void)expand
{
    [self expand:YES];
}

-(void)expand:(BOOL)animated {
    @synchronized(self){
        if(hidden)
            return;
        hidden = YES;
        isAnimating = animated;
    }
    
    if (_shouldHideTabBarOnScroll && self.isTabBarExisting){
        [self.tabBarController setTabBarHidden:YES
                                      animated:animated];
    }
    
    if (_shouldHideNavigationBarOnScroll && self.isNavigationBarExisting){
        [self.navigationController setNavigationBarHidden:YES
                                                 animated:animated];
    }
    
    @synchronized(self){
        if (animated){
            [self performSelector:@selector(endAnimation:) withObject:nil afterDelay:0.2];
        }
    }
    
}


-(void)contract
{
    [self contract:YES];
}

-(void)contract:(BOOL)animated {
    @synchronized(self){
        if(!hidden)
            return;
        hidden = NO;
        isAnimating = animated;
    }
    
    if (_shouldHideTabBarOnScroll && !self.isTabBarExisting)
        [self.tabBarController setTabBarHidden:NO
                                      animated:animated];
    
    if (_shouldHideNavigationBarOnScroll && !self.isNavigationBarExisting)
        [self.navigationController setNavigationBarHidden:NO
                                                 animated:animated];
    
    @synchronized(self){
        if (animated){
            [self performSelector:@selector(endAnimation:) withObject:nil afterDelay:0.2];
        }
    }
}

-(void)endAnimation:(id)sender {
    @synchronized(self){
        isAnimating = NO;
    }
}

#pragma mark -

#pragma mark Public

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:hidden
                                             animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tabBarController setTabBarHidden:hidden
                                  animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self contract:NO];
    
//    if (_shouldHideTabBarOnScroll && !self.isTabBarExisting)
//        [self.tabBarController setTabBarHidden:NO
//                                      animated:NO];
//    
//    if (_shouldHideNavigationBarOnScroll && !self.isNavigationBarExisting)
//        [self.navigationController setNavigationBarHidden:NO
//                                                 animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self contract];
}



#pragma mark -

#pragma mark KVO

#define MAX_SHIFT_PER_SCROLL    10  // used when _shouldHideUIBarsGradually=YES


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &__fullScreenScrollContext) {
        
        if ([keyPath isEqualToString:@"contentOffset"]) {
            
//            CGFloat currentOffset = _scrollView.contentOffset.y;
//            CGFloat differenceFromStart = startContentOffset - currentOffset;
//            CGFloat differenceFromLast = lastContentOffset - currentOffset;
//            lastContentOffset = currentOffset;
            
            
            CGPoint newPoint = [change[NSKeyValueChangeNewKey] CGPointValue];
            CGPoint oldPoint = [change[NSKeyValueChangeOldKey] CGPointValue];
            
            CGFloat deltaY = newPoint.y - oldPoint.y;
            if (deltaY == 0.0) return;

            // return if user hasn't dragged but trying to hide UI-bars (e.g. orientation change)
            if (deltaY > 0 && !self.scrollView.isDragging && !self.shouldHideUIBarsWhenNotDragging) return;

//            CGFloat maxShiftPerScroll = CGFLOAT_MAX;
//           // if (/*_shouldHideUIBarsGradually && */!isContentHeightTooShortToLimitShiftPerScroll) {
//                maxShiftPerScroll = MAX_SHIFT_PER_SCROLL;
//          //  }
//            
//            deltaY = MIN(deltaY, maxShiftPerScroll);
//            
//            if (deltaY == 0.0) return;
//            
//            if (_scrollView.isDecelerating) return;
//            
//            // return if user hasn't dragged but trying to hide UI-bars (e.g. orientation change)
//            if (deltaY > 0 && !self.scrollView.isDragging && !self.shouldHideUIBarsWhenNotDragging) return;
            
            
            if (newPoint.y <= 0){
                
                @synchronized(self){
                    if(!hidden)
                        return;
                }
                [self contract:NO];
                
                return;
            }
            
            @synchronized(self){
                if (isAnimating){
                    return;
                }
            }
            
            
            if (newPoint.y > oldPoint.y /* && (differenceFromStart) < 0*/){
                if(_scrollView.isTracking && _scrollView.isDragging /* && (abs(differenceFromLast)>1)*/ ){
                    @synchronized(self){
                        if(hidden)
                            return;
                    }
                    [self expand];
                }
            }
            else {
                if(_scrollView.isTracking && _scrollView.isDragging /* && (abs(differenceFromLast)>1) */){
                    @synchronized(self){
                        if(!hidden)
                            return;
                    }
                    [self contract];
                }
            }
        }
    }
}



#pragma mark Notifications

- (void)onWillEnterForegroundNotification:(NSNotification*)notification
{
    [self contract];
}

#pragma mark -

#pragma mark UIBars

- (UINavigationController*)navigationController
{
    if (!_navigationController) {
        _navigationController = _viewController.navigationController;
    }
    return _navigationController;
}

//
// NOTE: weakly referencing tabBarController is important to safely reset its size on viewDidDisappear
// (fixes https://github.com/inamiy/YIFullScreenScroll/issues/7#issuecomment-17991653)
//
- (UITabBarController*)tabBarController
{
    if (!_tabBarController) {
        _tabBarController = _viewController.tabBarController;
    }
    return _tabBarController;
}

- (UINavigationBar*)navigationBar
{
    return self.navigationController.navigationBar;
}

- (UITabBar*)tabBar
{
    return self.tabBarController.tabBar;
}

- (BOOL)isNavigationBarExisting
{
    UINavigationBar* navBar = self.navigationBar;
    return navBar && navBar.superview && !navBar.hidden && !self.navigationController.navigationBarHidden;
}


- (BOOL)isTabBarExisting
{
    UITabBar* tabBar = self.tabBar;
    return tabBar && tabBar.superview && !tabBar.hidden && (tabBar.frame.origin.y != self.tabBarController.view.bounds.size.height);
}


@end
