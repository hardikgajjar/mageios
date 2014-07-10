//
//  SliderViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 22/04/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "SliderViewController.h"
#import "ProductViewController.h"
#import "Home.h"

@interface SliderViewController ()

@end

@implementation SliderViewController {
    Home *home;
    NSDictionary *selectedProduct;
}

@synthesize scrollView, pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) observer:(NSNotification *) notification
{
    // perform ui updates from main thread so that they updates correctly
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(observer:) withObject:notification waitUntilDone:NO];
        return;
    }
    
    if ([[notification name] isEqualToString:@"homeDataLoadedNotification"]) {
        home = [Home getInstance];
        [self updateProducts];
    }
}

- (void)addObservers
{
    // Add home observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"homeDataLoadedNotification"
                                               object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addObservers];

    pageControlBeingUsed = NO;
    
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    int height = 182;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.height > 480.0f) height = 270; //iphone5
    
    [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, height)];
    
    self.pageControl.hidden = YES;
}

- (void)updateProducts
{
    int i = 0;
    if ([home.data valueForKeyPath:@"home_products.item"] != nil) {
        if ([[home.data valueForKeyPath:@"home_products.item"] isKindOfClass:[NSDictionary class]]) {
            [self prepareProductToDisplayWithIndex:i andProduct:[home.data valueForKeyPath:@"home_products.item"]];
        } else {
            for (NSDictionary *product in [home.data valueForKeyPath:@"home_products.item"]) {
                [self prepareProductToDisplayWithIndex:i andProduct:product];
                i++;
            }
        }
    
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * i, self.scrollView.frame.size.height);
        
        self.pageControl.currentPage = 0;
        self.pageControl.numberOfPages = i;
    }
    [self updatePageControl];
}

- (void)updatePageControl
{
    self.pageControl.hidden = NO;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    int y = 193;
    if (screenSize.height > 480.0f) y = 280; //iphone5
        
    [self.pageControl setFrame:CGRectMake(0, y, 320, 2)];
    
    UIImage *activeImage = [UIImage imageNamed:@"active-page"];
    UIImage *inactiveImage = [UIImage imageNamed:@"inactive-page"];

    float j = (320 - (50 * [[self.pageControl subviews] count])) / 2;
    NSMutableArray *subViews = [NSMutableArray array];
    NSInteger count = [[self.pageControl subviews] count];
    for (int i = 0; i < count; i++)
    {
        
        if (i == self.pageControl.currentPage) {
            UIImageView *dot_image = [[UIImageView alloc] initWithFrame:CGRectMake(j, 0, 50, 1)];
            dot_image.image = activeImage;
            [subViews addObject:dot_image];
        } else {
            UIImageView *dot_image = [[UIImageView alloc] initWithFrame:CGRectMake(j, 0, 50, 1)];
            dot_image.image = inactiveImage;
            [subViews addObject:dot_image];
        }
        j += 50;
    }
    
    [[self.pageControl subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i = 0; i < count; i++) {
        [self.pageControl addSubview:[subViews objectAtIndex:i]];
    }

}

- (void)prepareProductToDisplayWithIndex:(int)i andProduct:(NSDictionary *)product {
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * i;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    
    UIView *subview = [[UIView alloc] initWithFrame:frame];
    [subview setTag:[[product valueForKey:@"entity_id"] integerValue]];
    
    //icon
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    NSString *icon_image_name = @"icon_iphone4.@innerText";
    
    if (screenSize.height > 480.0f) { //iphone5
        icon_image_name = @"icon_iphone5.@innerText";
    }
    
    UIImage *icon_image = [UIImage imageWithData:
                           [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:[product valueForKeyPath:icon_image_name]]]];
    icon_image = [UIImage imageWithCGImage:[icon_image CGImage] scale:2.0 orientation:UIImageOrientationUp];
    
    int height = 182;
    
    if (screenSize.height > 480.0f) height = 270; //iphone5
        
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, height)];
    [icon setImage:icon_image];
    [subview addSubview:icon];
    
    // bind touch gesture
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(productTap:)];
    [subview addGestureRecognizer:singleFingerTap];
    
    [self.scrollView addSubview:subview];
}

- (void)productTap:(UITapGestureRecognizer *)recognizer {
    
    // get touched product
    if ([[home.data valueForKeyPath:@"home_products.item"] isKindOfClass:[NSDictionary class]]) {
        
        // open product view page
        selectedProduct = [home.data valueForKeyPath:@"home_products.item"];
        [self performSegueWithIdentifier:@"viewProductSegue" sender:self];
        
    } else {
        for (NSDictionary *product in [home.data valueForKeyPath:@"home_products.item"]) {
            if ([[product valueForKey:@"entity_id"] integerValue] == recognizer.view.tag) {
                
                // open product view page
                selectedProduct = product;
                [self performSegueWithIdentifier:@"viewProductSegue" sender:self];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (!pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
		CGFloat pageWidth = self.scrollView.frame.size.width;
		int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		self.pageControl.currentPage = page;
        [self updatePageControl];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (IBAction)changePage {
	// Update the scroll view to the appropriate page
	CGRect frame;
	frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.scrollView.frame.size;
	[self.scrollView scrollRectToVisible:frame animated:YES];
    
	// Keep track of when scrolls happen in response to the page control
	// value changing. If we don't do this, a noticeable "flashing" occurs
	// as the the scroll delegate will temporarily switch back the page
	// number.
	pageControlBeingUsed = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // set product information
    ProductViewController *product_controller = [segue destinationViewController];
    product_controller.title = [selectedProduct valueForKey:@"name"];
    product_controller.current_product = selectedProduct;
}

@end
