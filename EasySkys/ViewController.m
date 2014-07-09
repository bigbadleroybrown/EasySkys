//
//  ViewController.m
//  EasySkys
//
//  Created by Eugene Watson on 6/30/14.
//  Copyright (c) 2014 Eugene Watson. All rights reserved.
//

#import "ViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "WeatherManager.h"

@interface ViewController ()

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImageView *blurredImageView;
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) CGFloat screenHeight;
@property (strong, nonatomic) NSDateFormatter *hourFormatter;
@property (strong, nonatomic) NSDateFormatter *dayFormatter;

@end

@implementation ViewController

-(id)init
{
  //initialize date formatter only once
    if (self = [super init]) {
        _hourFormatter = [[NSDateFormatter alloc]init];
        _hourFormatter.dateFormat = @"h a";
        _dayFormatter = [[NSDateFormatter alloc]init];
        _dayFormatter.dateFormat = @"EEEE";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIImage *background = [UIImage imageNamed:@"nycbg@2x"];
    
    
    self.backgroundImageView = [[UIImageView alloc]initWithImage:background];
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
    
    //Frames and Margins
    
    
    //makes header of table the same size as screen
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    
    CGFloat inset = 20;
    
    //these are the 3 views being initialized - will need to make them more fluid, constants are not good
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    
    CGRect hiloFrame = CGRectMake(inset, headerFrame.size.height - hiloHeight, headerFrame.size.width - 2*inset, hiloHeight);;
    
    CGRect temperatureFrame = CGRectMake(inset, headerFrame.size.height - temperatureHeight - hiloHeight, headerFrame.size.width - 2*inset, temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset, temperatureFrame.origin.y - iconHeight, iconHeight, iconHeight);
    
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - 2*inset - iconHeight - 10;
    conditionsFrame.origin.x = iconFrame.origin.x + iconHeight + 10;
    
    
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    
    //this is the bottom left current temperature label
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    
    //this is the bottom left Hi / Lo temps label
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    
    //this is the top city label
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"Loading...";
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    //this will also be up top
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    conditionsLabel.textColor = [UIColor whiteColor];
    [header addSubview:conditionsLabel];
    
    
    //this will show the weather icons
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];

    

    [[RACObserve([WeatherManager sharedManager], currentCondition)

      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(Conditions *newCondition) {

         temperatureLabel.text = [NSString stringWithFormat:@"%.0f°",newCondition.temperature.floatValue];
         NSLog(@"%@", temperatureLabel.text);
         conditionsLabel.text = [newCondition.condition capitalizedString];
         cityLabel.text = [newCondition.locationName capitalizedString];
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
     }];
    
    RAC(hiloLabel, text) = [[RACSignal combineLatest:@[
                                                       
        RACObserve([WeatherManager sharedManager], currentCondition.tempHigh),
        RACObserve([WeatherManager sharedManager], currentCondition.tempLow)]
                reduce:^(NSNumber *hi, NSNumber *low) {
                    return [NSString  stringWithFormat:@"%.0f° / %.0f°",hi.floatValue,low.floatValue];
                }]
                deliverOn:RACScheduler.mainThreadScheduler];
    
    [[RACObserve([WeatherManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    [[RACObserve([WeatherManager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshControl:) forControlEvents:UIControlEventValueChanged];
    
        
    
    [[WeatherManager sharedManager] findCurrentLocation];
    
    
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)refresh:(id)sender

{
    
    NSLog(@"Refreshing");
    
    [[WeatherManager sharedManager] findCurrentLocation];
    
    [(UIRefreshControl *) sender endRefreshing];
    
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
    if (section ==0) {
        return MIN([[WeatherManager sharedManager].hourlyForecast count],6) +1;
    
    }
    return MIN([[WeatherManager sharedManager].dailyForecast count],6) +1;
    
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
    
    if (indexPath.section ==0) {
        if (indexPath.row ==0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        }
        else {
            Conditions *weather = [WeatherManager sharedManager].hourlyForecast[indexPath.row -1];
            [self configureHourlyCell:cell weather:weather];
        }
    }
    
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        }
        else {
            Conditions *weather = [WeatherManager sharedManager].dailyForecast[indexPath.row - 1];
            [self configureDailyCell:cell weather:weather];
        }
    }
    
    return cell;
}

- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

-(void)configureHourlyCell:(UITableViewCell *)cell weather:(Conditions *)weather
{

    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium"  size:18];
    cell.textLabel.text = [self.hourFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°", weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;

}

- (void)configureDailyCell:(UITableViewCell *)cell weather:(Conditions *)weather {
   
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dayFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°",weather.tempHigh.floatValue,weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
    //Determine how big cell is based on screen
    
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    
    return self.screenHeight / (CGFloat)cellCount;
    
}


-(void)viewWillLayoutSubviews

{
    
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
    
}


//blur effect

-(void)scrollViewDidScroll:(UIScrollView *)scrollView

{
    
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    CGFloat percent = MIN(position / height, 1.0);
    self.blurredImageView.alpha = percent;
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
