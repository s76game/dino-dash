//
//  ViewController.h
//  Dodge Template
//
//  Copyright (c) 2014 Baboolagoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <StoreKit/StoreKit.h>
#import "GameCenterManager.h"


@interface ViewController : UIViewController <ADBannerViewDelegate, SKProductsRequestDelegate,SKPaymentTransactionObserver, GameCenterManagerDelegate>

//Images
@property (weak, nonatomic) IBOutlet UIImageView *hero;
@property (weak, nonatomic) IBOutlet UIImageView *background;

//Stuff
@property (weak, nonatomic) IBOutlet UIImageView *object1;
@property (weak, nonatomic) IBOutlet UIImageView *object2;
@property (weak, nonatomic) IBOutlet UIImageView *object3;
@property (weak, nonatomic) IBOutlet UIImageView *object4;
@property (weak, nonatomic) IBOutlet UIImageView *object5;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet ADBannerView *banner;
@property (weak, nonatomic) IBOutlet UIView *gameoverView;
@property (weak, nonatomic) IBOutlet UILabel *finalScore;
@property (weak, nonatomic) IBOutlet UILabel *bestScore;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIImageView *instructions;
@property (weak, nonatomic) IBOutlet UIImageView *connecting;

//Buttons
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UIButton *noAdsButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
@property (weak, nonatomic) IBOutlet UIButton *characterSelectButton;
@property (weak, nonatomic) IBOutlet UIButton *backToMainMenuButton;

//Character Buttons
@property (weak, nonatomic) IBOutlet UIButton *character1Button;
@property (weak, nonatomic) IBOutlet UIButton *character2Button;
@property (weak, nonatomic) IBOutlet UIButton *character3Button;
@property (weak, nonatomic) IBOutlet UIButton *character4Button;
@property (weak, nonatomic) IBOutlet UIButton *character5Button;
@property (weak, nonatomic) IBOutlet UIButton *character6Button;

//Character Labels
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;
@property (weak, nonatomic) IBOutlet UILabel *label6;

@property (nonatomic) int gameCount;

- (IBAction)rate:(id)sender;
- (IBAction)retry:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)highscores:(id)sender;
- (IBAction)noAds:(id)sender;
- (IBAction)restore:(id)sender;
- (IBAction)loadCharacterView:(id)sender;
- (IBAction)setCharacter:(id)sender;
- (IBAction)backToMainMenu:(id)sender;

@end
