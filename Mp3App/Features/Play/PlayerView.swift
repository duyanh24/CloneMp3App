//
//  PlayerView.swift
//  Mp3App
//
//  Created by AnhLD on 10/19/20.
//  Copyright © 2020 AnhLD. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa

class PlayerView: UIView, NibOwnerLoadable, ViewModelBased {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topContentStackView: UIStackView!
    @IBOutlet weak var audioPlayerView: AudioPlayerView!
    @IBOutlet weak var trackInformationView: TrackInformationView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var controlPlayerView: UIView!
    @IBOutlet weak var containerBottomView: UIView!
    @IBOutlet weak var slider: CustomSlider!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private var controlPlayerViewY: CGFloat = 0
    var viewModel: PlayerViewModel!
    private var duration = 0
    
    var isScrollEnabled: Bool = true {
        didSet {
            scrollView.isScrollEnabled = isScrollEnabled
        }
    }
    
    var isTableviewOnTop: Bool {
        return trackInformationView.isTableViewOnTop
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        loadNibContent()
        setupUI()
    }
    
    private func setupUI() {
        setupTrackImageView()
        setupScrollView()
        setupPageControl()
        setupSlider()
        setupControlPlayerView()
    }
    
    func configureViewModel(viewModel: PlayerViewModel) {
        self.viewModel = viewModel
        bindViewModel()
    }
    
    private func bindViewModel() {
        let input = PlayerViewModel.Input(nextButton: nextButton.rx.tap.asObservable(), playButton: playButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        output.playlist.subscribe(onNext: { [weak self] tracks in
            if !tracks.isEmpty {
                var tracksTransform: [Track] = []
                tracksTransform.append(tracks[0])
                tracksTransform.append(contentsOf: tracks)
                self?.trackInformationView.configureViewModel(viewModel: TrackInformationViewModel(tracks: tracksTransform))
            }
        })
        .disposed(by: disposeBag)
        
        output.nextTrack.subscribe().disposed(by: disposeBag)
        output.playTrack.subscribe().disposed(by: disposeBag)
        
        output.duration.subscribe(onNext: { [weak self] duration in
            self?.duration = duration
            self?.slider.maximumValue = Float(duration)
        })
        .disposed(by: disposeBag)
        
        output.currentTime.subscribe(onNext: { [weak self] currentTime in
            self?.slider.value = Float(currentTime)
            self?.setupThumbSlider(currentValue: currentTime, maxValue: self?.duration ?? 0)
        })
        .disposed(by: disposeBag)
    }
    
    private func setupTrackImageView() {
        trackImageView.layer.cornerRadius = trackImageView.frame.size.height / 2
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.layoutIfNeeded()
        let contentOffset = CGPoint(x: frame.width, y: 0.0)
        scrollView.setContentOffset(contentOffset, animated: false)
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    func scrollToPlayerPage() {
        let contentOffset = CGPoint(x: frame.width, y: 0.0)
        scrollView.setContentOffset(contentOffset, animated: false)
        pageControl.currentPage = 1
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = 2
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 1
    }
    
    private func setupSlider() {
        slider.maximumValue = 247
        slider.minimumValue = 0
    }
    
    private func setupThumbSlider(currentValue: Int, maxValue: Int) {
        slider.setProgressTime(time: stringFromTimeInterval(interval: currentValue) + " / " + stringFromTimeInterval(interval: maxValue))
    }
    
    func stringFromTimeInterval(interval: Int) -> String {
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func setupControlPlayerView() {
        controlPlayerView.layoutIfNeeded()
        controlPlayerViewY = frame.height - controlPlayerView.frame.size.height - ScreenSize.getBottomSafeArea()
    }
}

extension PlayerView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = scrollView.contentOffset.x / frame.size.width
        pageControl.currentPage = Int(currentPage)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        controlPlayerView.frame.origin.y = controlPlayerViewY + (containerBottomView.frame.size.height + ScreenSize.getBottomSafeArea()) * (frame.width - scrollView.contentOffset.x) / frame.width
    }
}

extension Reactive where Base: PlayerView {
    var hide: ControlEvent<Void> {
        return base.hideButton.rx.tap
    }
}