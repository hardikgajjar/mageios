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
#import "Quote.h"
#import "XMLDictionary.h"
#import "UIColor+CreateMethods.h"

#import "SelectOptionsViewController.h"
#import "PPRevealSideViewController.h"


@interface ProductViewController ()

@end

@implementation ProductViewController {
    Service *service;
    Product *product;
    Quote   *quote;
    float regular_price;
    NSString *front_demo;
    NSString *back_demo;
}

@synthesize current_product,loading,productOptions,product_image,price,stock_status,short_desc,ratings,reviewCount,reviewText,qty,selectOptions,addToCart;

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
    } else if ([[notification name] isEqualToString:@"productAddedToCartNotification"]) {
        // show continue or view cart popup
        quote = [Quote getInstance];
        [self showAlertWithSuccessMessage:[quote.response valueForKey:@"text"]];
    }
}

- (void)showAlertWithSuccessMessage:(NSString *)message
{
    if (message == nil) message = @"Product is added to cart.";
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:nil
                          message:message
                          delegate:self
                          cancelButtonTitle:@"Continue"
                          otherButtonTitles:@"View Cart", nil];
    
    [alert show];
}

- (void)addObservers
{
    // Add product load observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"productDataLoadedNotification"
                                               object:nil];
    // Add product add to cart observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"productAddedToCartNotification"
                                               object:nil];

    // Add request completed observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer:)
                                                 name:@"requestCompletedNotification"
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
        
        if ([price_attributes valueForKey:@"regular"]) {
            price_text = [price_attributes valueForKey:@"regular"];
            regular_price = [[price_attributes valueForKey:@"regular"] floatValue];
        } else if ([price_attributes valueForKey:@"starting_at"]) {
            price_text = @"Starting At ";
            price_text = [price_text stringByAppendingString:[price_attributes valueForKey:@"starting_at"]];
        }
        
        //self.price.backgroundColor=[UIColor clearColor];
        //self.price.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
        self.price.text = price_text;
        
        // set stock status
        if ([[self.current_product valueForKey:@"in_stock"] isEqualToString:@"1"]) {
            self.stock_status.text = @"In Stock";
        } else {
            self.stock_status.text = @"Out of Stock";
        }
        
        // set short description
        self.short_desc.text = [self.current_product valueForKey:@"short_description"];
        
        // set review and ratings
        self.ratings.canEdit = NO;
        self.ratings.maxRating = 5;
        if ([[self.current_product valueForKey:@"reviews_count"] integerValue] > 0) {
            self.ratings.rating = [[self.current_product valueForKey:@"reviews_count"] integerValue];
            self.reviewCount.text = [NSString stringWithFormat:@"(%@)",[self.current_product valueForKey:@"reviews_count"]];
        } else {
            self.ratings.hidden = YES;
            self.reviewCount.hidden = YES;
            self.reviewText.text = @"No Ratings";
        }
        
        //NSLog(@"%@", self.current_product);
    }
}

- (void)updateProductData
{
    //NSLog(@"%@", product.data);
    
    if (product.data != nil) {
        //NSLog(@"%@", product.data);
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
        
        // set price
        NSDictionary *price_attributes = [product.data valueForKeyPath:@"price.@attributes"];
        NSString *price_text;
        
        if ([price_attributes valueForKey:@"regular"]) {
            price_text = [price_attributes valueForKey:@"regular"];
            regular_price = [[price_attributes valueForKey:@"regular"] floatValue];
        } else if ([price_attributes valueForKey:@"starting_at"]) {
            price_text = @"Starting At ";
            price_text = [price_text stringByAppendingString:[price_attributes valueForKey:@"starting_at"]];
        }
        
        //self.price.backgroundColor=[UIColor clearColor];
        //self.price.textColor=[UIColor colorWithHex:[service.config_data valueForKeyPath:@"categoryItem.tintColor"] alpha:1.0];
        self.price.text = price_text;
        
        
        // set product options
        
        if ([[product.data valueForKeyPath:@"product.options.option"] isKindOfClass:[NSDictionary class]]) {
            self.productOptions = [NSArray arrayWithObjects:[product.data valueForKeyPath:@"product.options.option"], nil];
        } else {
            self.productOptions = [product.data valueForKeyPath:@"product.options.option"];
        }
        
        if (self.productOptions != nil) {
            // enable select options button
            self.selectOptions.hidden = false;
        }
        
        // additional_attributes
        
        if ([product.data valueForKey:@"additional_attributes"] != nil) {
            if ([[product.data valueForKeyPath:@"additional_attributes.item"] isKindOfClass:[NSArray class]]) {
                for (NSDictionary *attr in [product.data valueForKeyPath:@"additional_attributes.item"]) {
                    if ([attr valueForKey:@"label"] != NULL) {
                        if ([[attr valueForKey:@"label"] isEqualToString:@"Frontend Demo"]) {
                            front_demo = [attr valueForKey:@"value"];
                        } else if ([[attr valueForKey:@"label"] isEqualToString:@"Backend Demo"]) {
                            back_demo = [attr valueForKey:@"value"];
                        }
                    }
                }
            } else {
                NSDictionary *attr = [product.data valueForKeyPath:@"additional_attributes.item"];
                if ([[attr valueForKey:@"label"] isEqualToString:@"Frontend Demo"]) {
                    front_demo = [attr valueForKey:@"value"];
                } else if ([[attr valueForKey:@"label"] isEqualToString:@"Backend Demo"]) {
                    back_demo = [attr valueForKey:@"value"];
                }
            }
        }
        
        if (front_demo == nil || [front_demo isEqualToString:@"No"]) {
            self.front_demo_btn.hidden = YES;
        }
        if (back_demo == nil || [back_demo isEqualToString:@"No"]) {
            self.back_demo_btn.hidden = YES;
        }
        
        /*if (options != nil) {
            
            // enable select options button
            self.selectOptions.hidden = false;
            
            int is_required = 0;
            
            if ([options isKindOfClass:[NSDictionary class]]) {
                if ([[options valueForKey:@"_is_required"] isEqualToString:@"1"]) {
                    is_required = 1;
                }
            } else {
                for (NSArray *option in options) {
                    if ([[option valueForKey:@"_is_required"] isEqualToString:@"1"]) {
                        is_required = 1;
                    }
                }
            }
            
            // disable add to cart button if any of the options is required
            if (is_required) {
                self.addToCart.enabled = false;
            }
        }*/
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


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectOptionsSegue"]) {
        SelectOptionsViewController *selectOptionController = segue.destinationViewController;
        selectOptionController.delegate = self;
        selectOptionController.options = self.productOptions;
    }
}


- (IBAction)addToCart:(id)sender {
    
    BOOL is_valid = true;
    
    if (self.productOptions != nil) {
        
        // check if all required options are having values?
        for (NSArray *option in self.productOptions) {
            
            if ([option valueForKey:@"value"] != nil) { // has childs
                
                // iterate childs and check if it is required
                NSArray *childs = [option valueForKey:@"value"];
                
                if ([childs isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *child = (NSMutableDictionary *)childs;
                    if ([[child valueForKey:@"_is_required"] isEqualToString:@"1"]) {
                        if ([child valueForKey:@"selected_value"] == nil || [[child valueForKey:@"selected_value"] isEqualToString:@""]) {
                            is_valid = false;
                            break;
                        }
                    }
                } else {
                    for (NSMutableDictionary *child in childs) {
                        if ([[child valueForKey:@"_is_required"] isEqualToString:@"1"]) {
                            if ([child valueForKey:@"selected_value"] == nil || [[child valueForKey:@"selected_value"] isEqualToString:@""]) {
                                is_valid = false;
                                break;
                            }
                        }
                    }
                }
            } else if ([[option valueForKey:@"_is_required"] isEqualToString:@"1"]) {
                
                    if ([option valueForKey:@"selected_value"] == nil || [[option valueForKey:@"selected_value"] isEqualToString:@""]) {
                        is_valid = false;
                        break;
                    }
                
            }
        }
        
    }
    
    if (is_valid) {
        
        quote = [Quote getInstance];
        
        if (quote) {
            
            [self.loading show:YES];
            
            // prepare post data
            NSMutableDictionary *post_data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[self.current_product valueForKey:@"entity_id"], @"product", self.qty.text, @"qty", nil];
            
            for (NSArray *option in self.productOptions) {
                
                if ([option valueForKey:@"value"] != nil) { // has childs
                    
                    if ([[option valueForKey:@"_type"] isEqualToString:@"checkbox"]) {
                        // iterate childs and get their selected values
                        NSArray *childs = [option valueForKey:@"value"];
                        
                        if ([childs isKindOfClass:[NSDictionary class]]) {
                            
                            NSMutableDictionary *child = (NSMutableDictionary *)childs;
                            
                            if ([child valueForKey:@"selected_value"] != nil) {
                                [post_data setValue:[child valueForKey:@"selected_value"] forKey:[option valueForKey:@"_code"]];
                            }
                            
                        } else {
                            
                            for (NSMutableDictionary *child in childs) {
                                if ([child valueForKey:@"selected_value"] != nil) {
                                    if ([post_data valueForKey:[option valueForKey:@"_code"]]) {
                                        NSMutableArray *values =[post_data valueForKey:[option valueForKey:@"_code"]];
                                        [values addObject:[child valueForKey:@"selected_value"]];
                                    } else {
                                        NSMutableArray *values = [NSMutableArray arrayWithObject:[child valueForKey:@"selected_value"]];
                                        [post_data setValue:values forKey:[option valueForKey:@"_code"]];
                                    }
                                }
                            }
                        }
                    } else if ([[option valueForKey:@"_type"] isEqualToString:@"select"]) {
                        if ([option valueForKey:@"selected_value"])
                            [post_data setValue:[option valueForKey:@"selected_value"] forKey:[option valueForKey:@"_code"]];
                    }
                    
                } else {
                    [post_data setValue:[option valueForKey:@"selected_value"] forKey:[option valueForKey:@"_code"]];
                }
                
            }
            NSLog(@"%@", post_data);
            [quote addToCart:post_data];
            
        }
        
    } else {
        // show alert
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"An Error Occured"
                              message:@"Please specify the product required option(s)."
                              delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil];
        
        [alert show];

    }
}


#pragma mark - alert view methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) { //view cart
        // go to cart tab
        UITabBarController *root = (UITabBarController *)self.revealSideViewController.rootViewController;
        root.selectedIndex = 2;
    }
}

#pragma mark - table view methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.qty resignFirstResponder];

    if (indexPath.row == 2) {
        NSURL *URL = [NSURL URLWithString:front_demo];
        [[UIApplication sharedApplication] openURL:URL];
    } else if (indexPath.row == 3) {
        NSURL *URL = [NSURL URLWithString:back_demo];
        [[UIApplication sharedApplication] openURL:URL];
    }
}


#pragma mark - select options methods

- (void)addItemViewController:(SelectOptionsViewController *)controller didFinishEnteringItem:(NSArray *)options withAddToCart:(BOOL)callAddToCart
{
    self.productOptions = options;

    if (callAddToCart) {
        [self addToCart:self];
    }
}

@end
