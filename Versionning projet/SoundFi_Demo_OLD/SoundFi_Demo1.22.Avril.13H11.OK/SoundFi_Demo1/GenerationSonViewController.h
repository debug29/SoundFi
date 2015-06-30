//
//  GenerationSonViewController.h
//  SoundFi_Demo1
//
//  Created by François Le Brun on 04/04/2014.
//  Copyright (c) 2014 SoundFi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>

@interface GenerationSonViewController : UIViewController
{
    @public
    
    UILabel *Lab_frequence;
    UILabel *Lab_amplitude;
    UIButton *But_lecture;
    UIButton *But_send_img;
    UIButton *But_send_msg;
    UISlider *Sli_frequence;
    UISlider *Sli_amplitude;
    UITextField *message;
    
    NSString *lemessage;
    
    int compteur;
    
    AudioComponentInstance uniteSon;
    

    double frequence;
    double amplitude;
    double ratioEchantillon;
    double theta;
    
}


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) IBOutlet UILabel *Lab_frequence;
@property (nonatomic,retain) IBOutlet UILabel *Lab_amplitude;
@property (nonatomic,retain) IBOutlet UIButton *But_lecture;
@property (nonatomic,retain) IBOutlet UIButton *But_send_img;
@property (nonatomic,retain) IBOutlet UIButton *But_send_msg;
@property (nonatomic,retain) IBOutlet UISlider *Sli_frequence;
@property (nonatomic,retain) IBOutlet UISlider *Sli_amplitude;
@property (nonatomic,retain) IBOutlet UITextField *message;


-(IBAction)sliderChanged:(UISlider *)slider;
-(IBAction)sliderAmpChanged:(UISlider *)slider;
-(IBAction)lancerLecture:(UIButton *)bouton;
-(IBAction)sendImage:(UIButton*)bouton;
-(IBAction)sendMessage:(UIButton*)bouton;
-(void)stop;

@end