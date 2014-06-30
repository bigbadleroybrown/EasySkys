//
//  ViewController.m
//  EasySkys
//
//  Created by Eugene Watson on 6/30/14.
//  Copyright (c) 2014 Eugene Watson. All rights reserved.
//

#import "ViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

@interface ViewController ()

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImageView *blurredImageView;
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) CGFloat screenHeight;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIImage *background = [UIImage imageNamed:@"nycSmallbg"];
    
    self.backgroundImageView = [[UIImageView alloc]init];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.blurredImageView = [[UIImageView alloc]init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(UIStatusBarStyle)preferredStatusBarStyle

{
    
    return UIStatusBarStyleLightContent;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
    //Will eventually return forecast
    return 2;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    
    return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    static NSString *cellIdentifier = @"CellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
    //Determine how big cell is based on screen
    return 44;
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
