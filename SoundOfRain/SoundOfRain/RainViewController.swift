//
//  RainViewController.swift
//  SoundOfRain
//
//  Created by Yeon on 24/07/2018.
//  Copyright © 2018 Yeon. All rights reserved.
//

import GoogleMobileAds
import UIKit
import SnapKit
import AVFoundation
import Firebase

class RainViewController: UIViewController, AVAudioPlayerDelegate, GADBannerViewDelegate {
    
    var didSetupConstraints = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
//    var bannerView: GADBannerView!
    
    @IBOutlet weak var imgView: UIImageView!
    
    var player: AVAudioPlayer!
    var timer: Timer!
    
    let playPauseButton: UIButton = {
        let playPauseButton = UIButton()
        playPauseButton.setImage(UIImage(named: "play-button"), for: UIControlState.normal)
        playPauseButton.setImage(UIImage(named: "pause-button"), for: UIControlState.selected)
        playPauseButton.addTarget(self, action: #selector(btnTouch(_ :)), for: UIControlEvents.touchUpInside)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        return playPauseButton
    }()
    
    let currentTimeLabel: UILabel = {
        let currentTimeLabel = UILabel()
        currentTimeLabel.text = "start"
        currentTimeLabel.textColor = UIColor.darkGray
        currentTimeLabel.textAlignment = NSTextAlignment.center
        currentTimeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        return currentTimeLabel
    }()
    
    let progressSlider: UISlider = {
        let progressSlider = UISlider()
        progressSlider.minimumTrackTintColor = UIColor.black
        progressSlider.addTarget(self, action: #selector(sliderValueChanged(_ :)), for: UIControlEvents.valueChanged)
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        return progressSlider
    }()
    
    let repeatButton: UIButton = {
        let repeatButton = UIButton()
        repeatButton.setImage(UIImage(named: "circular-arrow"), for: UIControlState.normal)
        repeatButton.setImage(UIImage(named: "reload"), for: UIControlState.selected)
        repeatButton.addTarget(self, action: #selector(repeatClickButton(_ :)), for: UIControlEvents.touchUpInside)
        repeatButton.translatesAutoresizingMaskIntoConstraints = false
        return repeatButton
    }()
    
    let cpRightLabel: UILabel = {
        let cpRightLabel = UILabel()
        cpRightLabel.text = "designed by Smashicons from Flaticon"
        cpRightLabel.textAlignment = NSTextAlignment.center
        cpRightLabel.textColor = UIColor.darkGray
        cpRightLabel.font = UIFont.boldSystemFont(ofSize: 11)
        return cpRightLabel
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Sound Of Rain"
        titleLabel.textColor = UIColor.darkGray
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        return titleLabel
    }()
    
    var bannerView: GADBannerView = {
        var bannerView = GADBannerView()
        bannerView.backgroundColor = UIColor.lightGray
        return bannerView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backGroundImageView()
        self.addView()
        self.initPlay()
        self.loadBanner()
    }
    
    func loadBanner() {
        //        bannerView.adUnitID = "ca-app-pub-2566181417052384/7765063704"
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    
    func addView() {
        view.addSubview(progressSlider)
        view.addSubview(playPauseButton)
        view.addSubview(currentTimeLabel)
        view.addSubview(repeatButton)
        view.addSubview(cpRightLabel)
        view.addSubview(titleLabel)
        view.addSubview(bannerView)
        
        view.setNeedsUpdateConstraints()
    }
    
    func backGroundImageView() {
        self.imgView.image = UIImage(named: "backImage2.jpg")
    }

    
    override func updateViewConstraints() {
        
        if(!didSetupConstraints) {
            
            progressSlider.snp.makeConstraints { (make) in
                make.center.equalTo(view)
                make.left.equalTo(self.view).offset(10)
                make.right.equalTo(self.view).offset(-10)
            }
            
            currentTimeLabel.snp.makeConstraints { (make) in
                make.top.equalTo(progressSlider.snp.top).offset(-30)
                make.centerX.equalTo(self.view)
                make.size.equalTo(CGSize(width: 100, height: 30))
            }
            
            playPauseButton.snp.makeConstraints { (make) in
                make.bottom.equalTo(currentTimeLabel.snp.top).offset(-10)
                make.centerX.equalTo(self.view)
                make.size.equalTo(CGSize(width: 100, height: 100))
            }
            
            titleLabel.snp.makeConstraints { (make) in
                make.bottom.equalTo(playPauseButton.snp.top).offset(-30)
                make.centerX.equalTo(self.view)
            }
            
            repeatButton.snp.makeConstraints { (make) in
                make.top.equalTo(progressSlider.snp.bottom).offset(10)
//                make.right.equalTo(self.view).offset(-10)
//                make.size.equalTo(CGSize(width: 30, height: 30))
                make.centerX.equalTo(self.view)
                make.size.equalTo(CGSize(width: 50, height: 50))
            }
            
            cpRightLabel.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view)
                make.bottom.equalTo(self.view.snp.bottom).offset(-10)
//                make.top.equalTo(self.titleLabel.snp.top).offset(-60)
            }
            
            bannerView.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view)
                make.bottom.equalTo(cpRightLabel.snp.top).offset(-20)
                make.size.equalTo(CGSize(width: 320, height: 50))
            }
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }

    
    func initPlay() {
        guard let audioFile = Bundle.main.url(forResource: "rain", withExtension: "mp3") else {
            let alert = UIAlertController(title: nil, message: "음원파일을 찾을수가 없습니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .destructive, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true)
            return
        }
        
        do {
            try self.player = AVAudioPlayer(contentsOf: audioFile)
            self.player.delegate = self
        } catch let error as NSError {
            let alert = UIAlertController(title: nil, message: "음악플레이어 초기화에 실패했습니다. \nCode: \(error.code), \(error.localizedDescription)", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .destructive, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
        
        self.progressSlider.maximumValue = Float(self.player.duration)
        self.progressSlider.minimumValue = 0
        self.progressSlider.value = Float(self.player.currentTime)
        self.currentTimeLabel.text = self.updateTiemLabelText(player.currentTime)
    }
    
//    @discardableResult
    func updateTiemLabelText(_ time: TimeInterval) -> String{
        let minute: Int = Int(time / 60)
        let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
        let milesecond: Int = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        
        let stringTimeText: String = String(format: "%02ld:%02ld:%02ld", minute, second, milesecond)
        return stringTimeText
        
    }
    
    
    func startStopTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] (timer: Timer) in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.progressSlider.isTracking { return }
            strongSelf.currentTimeLabel.text = strongSelf.updateTiemLabelText(strongSelf.player.currentTime)
            strongSelf.progressSlider.value = Float(strongSelf.player.currentTime)
        })
        self.timer.fire()
    }
    
    
    func invalidateTimer() {
        self.timer.invalidate()
        self.timer = nil
    }
    
    
    @objc func btnTouch(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.player?.play()
        } else {
            self.player?.pause()
        }
        
        if sender.isSelected {
            self.startStopTimer()
        } else {
            self.invalidateTimer()
        }
    }
    
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        self.currentTimeLabel.text = self.updateTiemLabelText(TimeInterval(sender.value))
        
        if sender.isTracking { return }
        self.player.currentTime = TimeInterval(sender.value)
    }
    
    
    @objc func repeatClickButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.player.numberOfLoops = -1
        } else {
            self.player.numberOfLoops = 0
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        guard let error: Error = error else {
            print("오디오 플레이어 디코드 오류 발생")
            return
        }
        
        let message: String
        message = "오디오 플레이어 오류 발생 \(error.localizedDescription)"
        
        let alert: UIAlertController = UIAlertController(title: "알림", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playPauseButton.isSelected = false
        self.progressSlider.value = 0
        self.currentTimeLabel.text = updateTiemLabelText(0)
        self.invalidateTimer()
    }

}
