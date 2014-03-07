//
//  ProductViewController.m
//  mageios
//
//  Created by KTPL - Mobile Development on 06/03/14.
//  Copyright (c) 2014 KTPL - Mobile Development. All rights reserved.
//

#import "ProductViewController.h"
#import "Service.h"
#import "Product.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"


@interface ProductViewController ()

@end

@implementation ProductViewController {
    Service *service;
    Product *product;
}

@synthesize current_product,loading,product_image,price,stock_status,short_desc;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    
    [self.loading hide:YES];
    
    if ([[notification name] isEqualToString:@"productDataLoadedNotification"]) {
        
        [self updateProductData];
        
    }
}

- (void)addObservers
{
    // Add product load observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"productDataLoadedNotification"
                                               object:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // show loading
    self.loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.loading.labelText = @"Loading";
    
    [self addObservers];
    
    service = [Service getInstance];
    
    // set basic product information which we got from list page
    [self setBasicInfo];
    
    if (service.initialized) {
        [self updateCommonStyles];
        
        if (self.current_product != nil) {
            int product_id = [[self.current_product valueForKey:@"entity_id"] integerValue];
            product = [[Product alloc] initWithId:product_id];
        }
    }
}

- (void)setBasicInfo
{
    if (self.current_product != nil) {
        // set icon
        UIImage *icon_image = [UIImage imageWithData:
                               [NSData dataWithContentsOfURL:
                                [NSURL URLWithString:[self.current_product valueForKeyPath:@"icon.@innerText"]]]];
        [self.product_image setImage:icon_image];
        
        //border to icon
        CALayer *borderLayer = [CALayer layer];
        CGRect borderFrame = CGRectMake(0, 0, (self.product_image.frame.size.width), (self.product_image.frame.size.height));
        [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
        [borderLayer setFrame:borderFrame];
        [borderLayer setBorderWidth:1.0];
        [borderLayer setBorderColor:[[UIColor colorWithHex:[service.config_data valueForKeyPath:@"body.backgroundColor"] alpha:1.0] CGColor]];
        [self.product_image.layer addSublayer:borderLayer];
        
        // set price
        NSDictionary *price_attributes = [self.current_product valueForKeyPath:@"price.@attributes"];
        NSString *price_text;
        
        if ([price_attributes valueForKey:@"regular"]) price_text = [price_attributes valueForKey:@"regular"];
        else if ([price_attributes valueForKey:@"starting_at"]) {
            price_text = @"Starting At ";
            price_text = [price_text stringByAppendingString:[price_attributes valueForKey:@"starting_at"]];
        }
        
        self.price.backgroundColor=[UIColor clearColor];
        self.price.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
        self.price.text = price_text;
        
        // set stock status
        if ([[self.current_product valueForKey:@"in_stock"] isEqualToString:@"1"]) {
            self.stock_status.text = @"In Stock";
        } else {
            self.stock_status.text = @"Out of Stock";
        }
        
        // set short description
        self.short_desc.text = [self.current_product valueForKey:@"short_description"];
        
        //NSLog(@"%@", self.current_product);
    }
}

- (void)updateProductData
{
    //NSLog(@"%@", product.data);
    
    if (product.data != nil) {
        
        // set icon
        UIImage *icon_image = [UIImage imageWithData:
                               [NSData dataWithContentsOfURL:
                                [NSURL URLWithString:[product.data valueForKeyPath:@"icon.@innerText"]]]];
        [self.product_image setImage:icon_image];
        
        //border to icon
        CALayer *borderLayer = [CALayer layer];
        CGRect borderFrame = CGRectMake(0, 0, (self.product_image.frame.size.width), (self.product_image.frame.size.height));
        [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
        [borderLayer setFrame:borderFrame];
        [borderLayer setBorderWidth:1.0];
        [borderLayer setBorderColor:[[UIColor colorWithHex:[service.config_data valueForKeyPath:@"body.backgroundColor"] alpha:1.0] CGColor]];
        [self.product_image.layer addSublayer:borderLayer];
    }
}

- (void)updateCommonStyles
{
    // set backgroundcolor
    [self.tableView setBackgroundColor:[UIColor colorWithHex:[service.config_data valueForKeyPath:@"body.backgroundColor"] alpha:1.0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
