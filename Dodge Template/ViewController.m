//
//  ViewController.m
//  Dodge Template
//
//  Copyright (c) 2014 Baboolagoon. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
@import iAd;

#import "AppDelegate.h"

#define kRemoveAdsProductIdentifier @"com.romit.godzilladodger.noads"

#define kLeaderboardIdentifier @"com.romit.godzilladodger.score"

#define kIDRateApp @"https://itunes.apple.com/us/app/can-you-escape-doom-godzilla/id884656945?ls=1&mt=8"


#define kGameStateMenu 1
#define kGameStateStart 2
#define kGameStateRunning 3
#define kGameStatePaused 4
#define kGameStateOver 5

NSInteger totalBombsDodged = 0;


@interface ViewController ()
{
    BOOL isGameOver; //
}

@end

@implementation ViewController


NSInteger gameState;
int score;
NSTimer *gameTimer;
int difficulty;
SystemSoundID mySound;
int lol;

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isGameOver = NO;
    
    //Load total number of bombs dodged
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"totalbombs"] == nil) {
        [[NSUserDefaults standardUserDefaults] setInteger:totalBombsDodged forKey:@"totalbombs"];
    } else {
        totalBombsDodged = [[NSUserDefaults standardUserDefaults] integerForKey:@"totalbombs"];
    }
    
    //Load the image for the background and hero
    NSInteger backgroundHeroID = [[NSUserDefaults standardUserDefaults] integerForKey:@"background-hero"];
    
    NSString *heroImage = [NSString stringWithFormat:@"hero%ld.png", backgroundHeroID];
    NSString *backgroundImage = [NSString stringWithFormat:@"background%ld.png", backgroundHeroID];
    
    [_hero setImage:[UIImage imageNamed:heroImage]];
    [_background setImage:[UIImage imageNamed:backgroundImage]];
    
    _connecting.hidden = YES;
    [[GameCenterManager sharedManager] setDelegate:self];
    self.banner.delegate = self;
    //show ads?
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"noads"] != nil){
        if([[defaults objectForKey:@"noads"]isEqualToString:@"YES"]){
            self.banner.hidden = YES;
        }
    }
    _scoreLabel.font = [UIFont fontWithName:@"8BIT WONDER" size:35];
    _scoreLabel.textColor = [UIColor whiteColor];
    
    _finalScore.font = [UIFont fontWithName:@"8BIT WONDER" size:20];
    _finalScore.textColor = [UIColor grayColor];
    
    _bestScore.font = [UIFont fontWithName:@"8BIT WONDER" size:20];
    _bestScore.textColor = [UIColor blackColor];
    
    [self initObject1];
    [self initObject2];
    [self initObject3];
    [self initObject4];
    [self initObject5];
    
    gameState = kGameStateMenu;
    
    [self menu];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MENU

- (void) menu
{
    _scoreLabel.hidden = YES;
    _instructions.hidden = NO;
    [self resetHero];
    CGRect menu;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if(UI_USER_INTERFACE_IDIOM() == UI_USER_INTERFACE_IDIOM()){
        if(screenSize.height >480.0f){
            menu= CGRectMake(17,79,287,270);
        }
        else{
            menu= CGRectMake(17,56,287,270);
        }
        
    }
    
    [UIView animateWithDuration: 1.0f
                     animations:^{
                         _titleView.frame = menu;
                     }
                     completion:^(BOOL finished){
                         
                     }];
        
}

- (IBAction)play:(id)sender
{
    isGameOver = NO;
    
    _instructions.hidden = YES;
    _scoreLabel.hidden = NO;
    score = 0;
    _scoreLabel.text = @"0";
    
    difficulty = 4.0;
    
    if(gameTimer)
    {
        [gameTimer invalidate];
        gameTimer = nil;
    }
    [self initObject1];
    [self initObject2];
    [self initObject3];
    [self initObject4];
    [self initObject5];
    [self resetHero];
    gameState = kGameStateRunning;
    
    CGRect menu;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if(UI_USER_INTERFACE_IDIOM() == UI_USER_INTERFACE_IDIOM()){
        if(screenSize.height >480.0f){
            menu= CGRectMake(17,700,287,270);
        }
        else{
            menu= CGRectMake(17,600,287,270);
        }
        
    }
    
    [UIView animateWithDuration: 1.0f
                     animations:^{
                         _titleView.frame = menu;
                     }
                     completion:^(BOOL finished){
                         gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.007 target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
                         
                     }];
}
- (IBAction)highscores:(id)sender
{
    [self showLeaderboard];
}

- (IBAction)retry:(id)sender
{
    CGRect done;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if(UI_USER_INTERFACE_IDIOM() == UI_USER_INTERFACE_IDIOM()){
        if(screenSize.height >480.0f){
            done = CGRectMake(16,700,280,286);
        }
        else{
            done = CGRectMake(16,600,280,286);
        }
        
    }
    
    
    [UIView animateWithDuration: 0.6f
                          delay: 0.3f
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _gameoverView.frame = done;
                     }
                     completion:^(BOOL finished){
                         [self play:self];
                     }];
    
    gameState = kGameStateStart;
    
    
    NSInteger heroImageID = [[NSUserDefaults standardUserDefaults] integerForKey:@"background-hero"];
    NSString *heroImage = [NSString stringWithFormat:@"hero%ld.png", heroImageID];
    
    [_hero setImage:[UIImage imageNamed:heroImage]];
}

- (IBAction)rate:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:kIDRateApp]]];
}

#pragma mark - GAME

- (void) gameLoop
{
    if(score > 15){
        difficulty = 5.0;
    }
    if(score > 50){
        difficulty = 5.5;
    }
    if(score >75){
        difficulty = 6.0;
    }
    if(score > 115){
        difficulty = 6.5;
    }
    if(score > 150){
        difficulty = 7.0;
    }
    
    _object1.center = CGPointMake(_object1.center.x, _object1.center.y + difficulty);
    _object2.center = CGPointMake(_object2.center.x, _object2.center.y +difficulty);
    _object3.center = CGPointMake(_object3.center.x, _object3.center.y + difficulty);
    _object4.center = CGPointMake(_object4.center.x, _object4.center.y +difficulty);
    _object5.center = CGPointMake(_object5.center.x, _object5.center.y +difficulty);
    
    
    if(gameState == kGameStateRunning ){
        
        //Update Asteroids and check collisions
        
        //Move the objects down
        
        //Check if the object is off the screen, if so reset the position
        if(_object1.center.y > 660){
            score++;
            NSString *path  = [[NSBundle mainBundle] pathForResource:@"point" ofType:@"mp3"];
            NSURL *pathURL = [NSURL fileURLWithPath : path];
            
            SystemSoundID audioEffect;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
            AudioServicesPlaySystemSound(audioEffect);
            //if the asteroid is successfully dodged, update the score
            [self initObject1];
            
        }
        if(_object2.center.y > 660){
            score++;
            NSString *path  = [[NSBundle mainBundle] pathForResource:@"point" ofType:@"mp3"];
            NSURL *pathURL = [NSURL fileURLWithPath : path];
            
            SystemSoundID audioEffect;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
            AudioServicesPlaySystemSound(audioEffect);
            [self initObject2];
            
            //if the asteroid is successfully dodged, update the score
        }
        if(_object3.center.y > 660){
            score++;
            NSString *path  = [[NSBundle mainBundle] pathForResource:@"point" ofType:@"mp3"];
            NSURL *pathURL = [NSURL fileURLWithPath : path];
            
            SystemSoundID audioEffect;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
            AudioServicesPlaySystemSound(audioEffect);
            [self initObject3];
            
            //if the asteroid is successfully dodged, update the score
        }
        if(_object4.center.y > 660){
            score++;
            NSString *path  = [[NSBundle mainBundle] pathForResource:@"point" ofType:@"mp3"];
            NSURL *pathURL = [NSURL fileURLWithPath : path];
            
            SystemSoundID audioEffect;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
            AudioServicesPlaySystemSound(audioEffect);
            //if the asteroid is successfully dodged, update the score
            [self initObject4];
            
        }
        if(_object5.center.y > 660){
            score++;
            NSString *path  = [[NSBundle mainBundle] pathForResource:@"point" ofType:@"mp3"];
            NSURL *pathURL = [NSURL fileURLWithPath : path];
            
            SystemSoundID audioEffect;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
            AudioServicesPlaySystemSound(audioEffect);
            //if the asteroid is successfully dodged, update the score
            [self initObject5];
            
        }
        
        //check collision
        CGRect heroRect = CGRectMake(_hero.frame.origin.x, _hero.frame.origin.y, _hero.frame.size.width - 15 , _hero.frame.size.height - 50);
        
        if(CGRectIntersectsRect(heroRect, _object1.frame)){
            gameState = kGameStateOver;
            [self gameOver];
        }
        if(CGRectIntersectsRect(heroRect, _object2.frame)){
            
            gameState = kGameStateOver;
            [self gameOver];
            
        }
        if(CGRectIntersectsRect(heroRect, _object3.frame)){
            
            gameState = kGameStateOver;
            [self gameOver];
            
        }
        if(CGRectIntersectsRect(heroRect, _object4.frame)){
            
            gameState = kGameStateOver;
            [self gameOver];
            
        }
        if(CGRectIntersectsRect(heroRect, _object5.frame)){
            
            gameState = kGameStateOver;
            [self gameOver];
            
        }
        
        _scoreLabel.text = [NSString stringWithFormat:@"%d", score];
    }
    if(gameState == kGameStatePaused){
        //pause everything
        
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isGameOver)
    {
        return;
    }
    
    //moves hero
    [self touchesMoved:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isGameOver)
    {
        return;
    }
    
    UITouch *touch = [[event allTouches]anyObject];
    CGPoint location = [touch locationInView:touch.view];
    CGPoint xLocation = CGPointMake(location.x, _hero.center.y);
    
    /* if (location.x > _hero.center.x)
    {
        _hero.image = [UIImage imageNamed:@"hero.png"];
    }
    else{
        _hero.image = [UIImage imageNamed:@"hero.png"];
    } */
    NSInteger heroImageID = [[NSUserDefaults standardUserDefaults] integerForKey:@"background-hero"];
    NSString *heroImage = [NSString stringWithFormat:@"hero%ld.png", heroImageID];
    
    [_hero setImage:[UIImage imageNamed:heroImage]];
    [_hero setCenter:xLocation];
}

#pragma mark - GAME OVER

/*
- (void) showApplovinAd
{
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"noads"] isEqual:@"YES"])
    {
        //[ADInterstitialAd showOver:[[UIApplication sharedApplication] keyWindow]];
    }
    
}
*/

- (void) showExplosion
{
    NSMutableArray * exploImages = [[NSMutableArray alloc] init];
    
    for (int i = 0; i <= 40; i++)
    {
        [exploImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"explosion%d", i]]];
    }
    
    UIImageView * exploImageView = [[UIImageView alloc] initWithFrame:
                                    CGRectMake(_hero.frame.origin.x - _hero.frame.size.width * 0.5,
                                               _hero.frame.origin.y - _hero.frame.size.height * 0.5,
                                               _hero.frame.size.width * 2,
                                               _hero.frame.size.height * 2)];
    
    exploImageView.animationImages = exploImages;
    exploImageView.animationDuration = 1;
    exploImageView.animationRepeatCount = 1;
    
    [self.view addSubview:exploImageView];
    [exploImageView startAnimating];

    [UIImageView setAnimationDelegate:self];
    [UIImageView setAnimationDidStopSelector:@selector(removeFromSuperview)];
}

- (void) gameOver
{
    isGameOver = YES;
    
    _scoreLabel.hidden = YES;
    
    totalBombsDodged += score;
    [[NSUserDefaults standardUserDefaults] setInteger:totalBombsDodged forKey:@"totalbombs"];
    NSLog(@"%ld", (long)totalBombsDodged);
    
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"deadSound" ofType:@"wav"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    
    SystemSoundID audioEffect;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
    AudioServicesPlaySystemSound(audioEffect);
    
    _hero.image = [UIImage imageNamed:@"hero_black.png"];
    
    [self showExplosion];
    /*
    int gameCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"NUM_GAME"];
    
    if (!gameCount)
    {
        gameCount = 1;
        
        [[NSUserDefaults standardUserDefaults] setInteger:gameCount forKey:@"NUM_GAME"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    */
    
    //Show an ad from ChartBoost, with the method showAds in AppDelegate
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showAds)];

    
    _gameCount++;
    if (_gameCount % 5 == 0)
    {
        _gameCount = 1;
        
        //[[NSUserDefaults standardUserDefaults] setInteger:gameCount forKey:@"NUM_GAME"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        
        //[self showApplovinAd];
    }
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;

    /*
    CGRect heroRect;
     
    if (UI_USER_INTERFACE_IDIOM() == UI_USER_INTERFACE_IDIOM())
    {
        if (screenSize.height > 480.0f)
        {
            heroRect = CGRectMake(_hero.frame.origin.x,700,39,48);
        }
        else
        {
            heroRect = CGRectMake(_hero.frame.origin.x,600,39,48);
        }
    }
    
    
    CGRect heroUp = CGRectMake(_hero.frame.origin.x, _hero.frame.origin.y - 30, _hero.frame.size.width, _hero.frame.size.height);
    
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _hero.frame = heroUp;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration: 0.5f
                                               delay: 0.1f
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              _hero.frame = heroRect;
                                          }
                                          completion:^(BOOL finished){
                                              // [self gameOver];
                                          }];
                     }];
    
    
    */
    
    
    _finalScore.text = [NSString stringWithFormat:@"%i", score];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults valueForKey:@"highscore"] == NULL) {
        [defaults setValue:@"0" forKey:@"highscore"];
    }
    if(score > [[defaults objectForKey:@"highscore"]intValue]){
        int x = [_finalScore.text intValue];
        [self submitToLeaderboard:x];
        [defaults setObject:_finalScore.text forKey:@"highscore"];
        [defaults synchronize];
    }
    
    _bestScore.text = [defaults objectForKey:@"highscore"];
    
    CGRect gameOver;
    
    if(UI_USER_INTERFACE_IDIOM() == UI_USER_INTERFACE_IDIOM()){
        if(screenSize.height >480.0f){
            gameOver= CGRectMake(20,88,280,286);
            
        }
        else{
            gameOver= CGRectMake(20,57,280,286);
        }
        
    }
    
    
    [UIView animateWithDuration: 1.0f
                     animations:^{
                         _gameoverView.frame = gameOver;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}

#pragma mark - INIT OBJECTS
-(void)resetHero{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if(UI_USER_INTERFACE_IDIOM() == UI_USER_INTERFACE_IDIOM()){
        if(screenSize.height >480.0f){
            _hero.frame = CGRectMake(141,399,39,48);
        }
        else{
            _hero.frame = CGRectMake(141,331,39,48);
        }
    }
}

-(void)initObject1{
    int r = arc4random_uniform(320) ;
    int h = arc4random_uniform(100) - 250;
    _object1.center = CGPointMake(r, h);
    //pick random x coordinate, high y coordinate
}
-(void)initObject2{
    int r = arc4random_uniform(320) ;
    int h = arc4random_uniform(300) - 950;
    _object2.center = CGPointMake(r, h);
}
-(void)initObject3{
    int r = arc4random_uniform(320) ;
    int h = arc4random_uniform(100) - 350;
    _object3.center = CGPointMake(r, h);
}
-(void)initObject4{
    int r = arc4random_uniform(320) ;
    int h = arc4random_uniform(300) - 400;
    _object4.center = CGPointMake(r, h);
}
-(void)initObject5{
    int r = arc4random_uniform(320) ;
    int h = arc4random_uniform(300) - 450;
    _object5.center = CGPointMake(r, h);
}


#pragma mark - iAD Banner
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    return YES;
}
- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
}


#pragma mark - inApp PURCHASE
- (void) failedTransaction: (SKPaymentTransaction *)transaction{
    if (transaction.error.code != SKErrorPaymentCancelled){
        // Display an error here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Unsuccessful"
                                                        message:@"Your purchase failed. Please try again."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    _connecting.hidden = YES;
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
    _connecting.hidden = YES;

}
- (IBAction)noAds:(id)sender {
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Buy Full Version"
                                                    message:@"The option to buy a full version of this app with no ads is coming soon!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    */

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"noads"] != nil){
        if([[defaults objectForKey:@"noads"]isEqualToString:@"YES"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops."
                                                            message:@"You've already bought this."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }else{
        if([SKPaymentQueue canMakePayments]){
            NSLog(@"User can make payments");
            SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifier]];
            productsRequest.delegate = self;
            [productsRequest start];
            _connecting.hidden = NO;
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops."
                                                            message:@"I don't think you are allowed to make in-app purchases."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            //the user cannot make payments, most likely due to parental controls
        }
        
    }
}

- (IBAction)restore:(id)sender {
    //this is called when the user restores purchases, you should hook this up to a button
    _connecting.hidden = NO;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = (int)[response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        _connecting.hidden = YES;
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %i",(int) queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if(SKPaymentTransactionStateRestored){
            NSLog(@"Transaction state -> Restored");
            //called when the user successfully restores a purchase
            [self doRemoveAds];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
        
    }
    _connecting.hidden = YES;
   
}
-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"%@",error);
    _connecting.hidden = YES;
}
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                _connecting.hidden = YES;
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                _connecting.hidden = YES;
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finnish
                if(transaction.error.code != SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                _connecting.hidden = YES;
                break;
        }
    }
    
}
-(void)doRemoveAds{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"YES"forKey:@"noads"];
    [defaults synchronize];
    self.banner.hidden = YES;
}

#pragma mark - GAME CENTER
- (void)gameCenterManager:(GameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController{
    [self presentViewController:gameCenterLoginController animated:YES completion:^{
        //You can comment this line, it's simply so we know that we are currently authenticating the user and presenting the controller
        // NSLog(@"Finished Presenting Authentication Controller");
        
    }];
}
- (void) showLeaderboard{
    BOOL isAvailable = [[GameCenterManager sharedManager] checkGameCenterAvailability];
    
    if(isAvailable){
        [[GameCenterManager sharedManager] presentLeaderboardsOnViewController:self];
        
    }else{
        //Showing an alert message that Game Center is unavailable
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Highscore" message: @"Game Center is currently unavailable. Make sure you are logged in." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alert show];
    }
}
//Submitting to leaderboard - the GameCenterManager framework takes care of submitting the score
-(void)submitToLeaderboard: (int)score{
    //Is Game Center available?
    BOOL isAvailable = [[GameCenterManager sharedManager] checkGameCenterAvailability];
    
    if(isAvailable){
        [[GameCenterManager sharedManager] saveAndReportScore:score leaderboard:kLeaderboardIdentifier sortOrder:GameCenterSortOrderHighToLow];
    }
}
-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)loadCharacterView:(id)sender {
    //Hide all main menu stuff
    [_playButton setHidden:true];
    [_leaderboardButton setHidden:true];
    [_rateButton setHidden:true];
    [_noAdsButton setHidden:true];
    [_restoreButton setHidden:true];
    [_characterSelectButton setHidden:true];
    
    //Show all character set buttons, and back button
    [_character1Button setHidden:false];
    [_character2Button setHidden:false];
    [_character3Button setHidden:false];
    [_character4Button setHidden:false];
    [_character5Button setHidden:false];
    [_character6Button setHidden:false];
    
    [_label1 setHidden:false];
    [_label2 setHidden:false];
    [_label3 setHidden:false];
    [_label4 setHidden:false];
    [_label5 setHidden:false];
    [_label6 setHidden:false];
    
    [_backToMainMenuButton setHidden:false];
}

-(IBAction)setCharacter:(id)sender {
    NSInteger x = [sender tag];
    
    [[NSUserDefaults standardUserDefaults] setInteger:x forKey:@"background-hero"];
    
    NSString *backgroundImage = [NSString stringWithFormat:@"background%ld.png", (long)x];
    NSString *heroImage = [NSString stringWithFormat:@"hero%ld.png", (long)x];
    
    [_background setImage:[UIImage imageNamed:backgroundImage]];
    [_hero setImage:[UIImage imageNamed:heroImage]];
}

-(IBAction)backToMainMenu:(id)sender {
    //Show all main menu stuff
    [_playButton setHidden:false];
    [_leaderboardButton setHidden:false];
    [_rateButton setHidden:false];
    [_noAdsButton setHidden:false];
    [_restoreButton setHidden:false];
    [_characterSelectButton setHidden:false];
    
    //Hide all character set buttons, and back button
    [_character1Button setHidden:true];
    [_character2Button setHidden:true];
    [_character3Button setHidden:true];
    [_character4Button setHidden:true];
    [_character5Button setHidden:true];
    [_character6Button setHidden:true];
    
    [_label1 setHidden:true];
    [_label2 setHidden:true];
    [_label3 setHidden:true];
    [_label4 setHidden:true];
    [_label5 setHidden:true];
    [_label6 setHidden:true];
    
    [_backToMainMenuButton setHidden:true];
}

@end
