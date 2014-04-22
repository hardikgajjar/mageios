//
//  SliderViewController.h
//  mageios
//
//  Created by KTPL - Mobile Development on 22/04/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SliderViewController : UIViewController <UIScrollViewDelegate> {
    
	BOOL pageControlBeingUsed;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)changePage;

@end
