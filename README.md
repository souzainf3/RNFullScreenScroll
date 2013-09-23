RNFullScreenScroll
==================

Pinterest-like scroll-to-fullscreen UI for iOS5+.

Working with iOS 7;

<img src="https://github.com/souzainf3/RNFullScreenScroll/blob/master/Screenshots/screenshot1.png" alt="ScreenShot1" width="225px" style="width:225px;" />

<img src="https://github.com/souzainf3/RNFullScreenScroll/blob/master/Screenshots/screenshot1.png" alt="ScreenShot2" width="225px" style="width:225px;" />


`RNFullScreenScroll` uses [JRSwizzle](https://github.com/rentzsch/jrswizzle/) to extend `UIViewController`'s functionality, and KVO (Key-Value-Observing) instead of conforming to `UIScrollViewDelegate` for easiler implementation.


How to use
----------

```
#import "RNFullScreenScroll.h"

...

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fullScreenScroll = [[RNFullScreenScroll alloc] initWithViewController:self scrollView:self.tableView];    
//    self.fullScreenScroll.shouldHideToolbarOnScroll = NO;
//    self.fullScreenScroll.shouldHideTabBarOnScroll = NO;
}


Dependencies
------------
- [JRSwizzle 1.0](https://github.com/rentzsch/jrswizzle)
- [ViewUtils 1.1](https://github.com/nicklockwood/ViewUtils)


