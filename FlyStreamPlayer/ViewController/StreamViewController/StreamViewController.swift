//
//  StreamViewController.swift
//  FlyStream
//
//  Created by Jingwei Wu on 05/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

import UIKit
import FlyStream

enum StreamPlayStatus: Int {
    case none
    case opening
    case opened
    case playing
    case buffering
    case paused
    case EOF
    case closing
    case closed
}

enum StreamPlayOperation: Int {
    case none
    case open
    case play
    case pause
    case close
}

class StreamViewController: BaseViewController {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var viewContainer: UIView!
    
    weak var waitingIndicator: UIActivityIndicatorView?
    
    lazy var streamViewManager: FLYStreamManager = {
        return FLYStreamManager()
    }()
    
    var timer: DispatchSourceTimer?
    
    var restoreStream: Bool = false
    var status: StreamPlayStatus = .none
    var nextOperation: StreamPlayOperation = .none
    
    var url: String = ""
    var autoplay: Bool = false
    var repeatly: Bool = false
    var preventFromScreenLock: Bool = false
    var restorePlayAfterAppEnterForeground: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponent()
        
        url = "rtmp://203.207.99.19:1935/live/CCTV1"//"rtsp://streaming3.webcam.nl:1935/n233/n233.stream"
        
        urlTextField.delegate = self
        urlTextField.text = url
        urlTextField.clearButtonMode = .whileEditing
        updateTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initStreamManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        streamViewManager.close()
        unregisterNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTitle() {
        let txt = self.urlTextField.text
        self.navigationItem.title = ((txt?.characters.count == 0) ? "Stream Player" : URL.init(string: txt!)?.lastPathComponent)
    }
    
    private func registerNotification() {
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(notifyAppDidEnterBackground),
                       name: NSNotification.Name.UIApplicationDidEnterBackground,
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(notifyAppWillEnterForeground),
                       name: NSNotification.Name.UIApplicationWillEnterForeground,
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(notifyStreamViewManagerOpened),
                       name: NSNotification.Name.StreamOpened,
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(notifyStreamViewManagerClosed),
                       name: NSNotification.Name.StreamClosed,
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(notifyStreamViewManagerEOF),
                       name: NSNotification.Name.StreamEOF,
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(notifyStreamViewManagerOpenURLFailed(notification:)),
                       name: NSNotification.Name.StreamOpenURLFailed,
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(notifyStreamViewManagerBufferStateChanged),
                       name: NSNotification.Name.StreamBufferStateChanged,
                       object: nil)
    }
    
    private func unregisterNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    //
    // MARK: - initialize components
    //
    private func initComponent() -> () {
        self.urlTextField.keyboardType = .webSearch
        
        self.initStreamManager()
        self.status = .none;
        self.nextOperation = .none;
        
        self.autoplay = true;
        self.repeatly = true;
        self.preventFromScreenLock = true;
        self.restorePlayAfterAppEnterForeground = true;
    }
    
    private func initStreamManager() {
        let streamView: UIView = self.streamViewManager.streamView
        
        //
        // initial stream view
        //
        streamView.translatesAutoresizingMaskIntoConstraints = false
        self.viewContainer.addSubview(streamView)
        
        // Add constraints
        let streamViewLeadingConstraint = NSLayoutConstraint(item: streamView,
                                                             attribute: .leading,
                                                             relatedBy: .equal,
                                                             toItem: viewContainer,
                                                             attribute: .leading,
                                                             multiplier: 1.0,
                                                             constant: 0.0)
        
        let streamViewTrailingConstraint = NSLayoutConstraint(item: streamView,
                                                              attribute: .trailing,
                                                              relatedBy: .equal,
                                                              toItem: viewContainer,
                                                              attribute: .trailing,
                                                              multiplier: 1.0,
                                                              constant: 0.0)
        
        let streamViewTopConstraint = NSLayoutConstraint(item: streamView,
                                                         attribute: .top,
                                                         relatedBy: .equal,
                                                         toItem: viewContainer,
                                                         attribute: .top,
                                                         multiplier: 1.0,
                                                         constant: 0.0)
        
        let streamViewBottomConstraint = NSLayoutConstraint(item: streamView,
                                                            attribute: .bottom,
                                                            relatedBy: .equal,
                                                            toItem: viewContainer,
                                                            attribute: .bottom,
                                                            multiplier: 1.0,
                                                            constant: 0.0)
        
        self.viewContainer.addConstraints([streamViewLeadingConstraint,
                                           streamViewTrailingConstraint,
                                           streamViewTopConstraint,
                                           streamViewBottomConstraint])
        
        
        //
        // initial indicator
        //
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.translatesAutoresizingMaskIntoConstraints = false;
        indicator.hidesWhenStopped = true;
        self.viewContainer.addSubview(indicator)
        self.waitingIndicator = indicator
        
        
        // Add constraints
        let centerXConstraint = NSLayoutConstraint(item: indicator,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: streamView,
                                                   attribute: .centerX,
                                                   multiplier: 1.0,
                                                   constant: 0.0)
        
        let centerYConstraint = NSLayoutConstraint(item: indicator,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: streamView,
                                                   attribute: .centerY,
                                                   multiplier: 1.0,
                                                   constant: 0.0)
        
        viewContainer.addConstraints([centerXConstraint, centerYConstraint])
        
        
    }
    
    //
    // MARK: - Operations
    //
    private func open() {
        if self.status == .closing {
            self.nextOperation = .open
            return
        }
        
        if self.status != .none && self.status != .closed {
            return
        }
        
        self.status = .opening
        self.waitingIndicator?.isHidden = false
        self.waitingIndicator?.startAnimating()
        self.streamViewManager.openURL(url)
    }
    
    private func close() {
        if self.status == .opening {
            self.nextOperation = .close
            return
        }
        
        self.status = .closing
        UIApplication.shared.isIdleTimerDisabled = false
        self.streamViewManager.close()
    }
    
    private func play() {
        if self.status == .none || self.status == .closed {
            self.open()
            self.nextOperation = .play
        }
        
        if self.status != .opened && self.status != .paused && self.status != .EOF {
            return
        }
        
        self.status = .playing
        UIApplication.shared.isIdleTimerDisabled = preventFromScreenLock
        self.streamViewManager.play()
    }
    
    private func replay() {
        self.streamViewManager.position = 0
        self.play()
    }
    
    private func pause() {
        if self.status != .opened && self.status != .playing && self.status != .EOF {
            return
        }
        
        self.status = .paused
        UIApplication.shared.isIdleTimerDisabled = false
        self.streamViewManager.pause()
    }
    
    internal func go() {
        guard ((urlTextField.text?.lengthOfBytes(using: .utf8)) != nil) else {
            return
        }
        
        updateTitle()
        self.url = urlTextField.text!
        close()
        open()
    }
    
    @discardableResult
    private func doNextOperation(_ op: StreamPlayOperation) -> Bool {
        guard op != .none else {
            return false
        }
        
        switch op {
        case .open: open()
        case .play: play()
        case .pause: pause()
        case .close: close()
        default: break
        }
        
        self.nextOperation = .none
        return true
    }
    
    //
    // MARK: - Notifications
    //
    @objc
    private func notifyAppDidEnterBackground(notification: Notification) {
        if self.streamViewManager.playing {
            self.pause()
            
            if restorePlayAfterAppEnterForeground {
                restoreStream = true
            }
        }
    }

    @objc
    private func notifyAppWillEnterForeground(notification: Notification) {
        if restoreStream {
            restoreStream = false
            play()
        }
    }
    
    @objc
    private func notifyStreamViewManagerOpened(notification: Notification) {
        DispatchQueue.main.async {
            self.waitingIndicator?.stopAnimating()
        }
        if !self.streamViewManager.opened {
            self.status = .none
            self.doNextOperation(self.nextOperation)
            return
        }
        
        self.status = .opened
        DispatchQueue.main.async {
            var title: String? = nil
            if self.streamViewManager.metadata != nil {
                let metaDataTitle: String? = self.streamViewManager.metadata[("title" as NSString)] as? String
                let metaDataArtist: String? = self.streamViewManager.metadata[("artist" as NSString)] as? String
                
                if metaDataTitle != nil {
                    title = metaDataTitle
                } else if metaDataArtist != nil {
                    title = " - " + metaDataArtist!
                }
            }
            
            if title == nil {
                title = URL.init(string: self.url)?.lastPathComponent
            }
            
            self.createTimer()
        }
        if !self.doNextOperation(self.nextOperation) {
            if self.autoplay {
                self.play()
            }
        }
    }
    
    @objc
    private func notifyStreamViewManagerClosed(notification: Notification) {
        self.status = .closed
        waitingIndicator?.stopAnimating()
        self.destoryTimer()
        self.doNextOperation(self.nextOperation)
    }
    
    @objc
    private func notifyStreamViewManagerEOF(notification: Notification) {
        self.status = .EOF
        if(repeatly) {
            self.replay()
        } else {
            self.close()
        }
    }
    
    @objc
    private func notifyStreamViewManagerOpenURLFailed(notification: Notification) {
        DispatchQueue.main.async {
            self.waitingIndicator?.stopAnimating()
        }
        //if !self.streamViewManager.opened {
            self.status = .none
            self.doNextOperation(self.nextOperation)
        //}
        
        let err = notification.object as! NSError
        let errorCode: FLYErrorCode = FLYErrorCode(rawValue: err.code)!
        
        switch errorCode {
        case FLYErrorCode.ErrorCodeInvalidURL:
            break
        default:
            break
        }
        
        return
    }
    
    @objc
    private func notifyStreamViewManagerBufferStateChanged(notification: Notification) {
        let userInfo = notification.userInfo!
        let state: Bool = userInfo[StreamBufferStateNotificationKey as NSString] as! Bool
        
        if state {
            self.status = .buffering
            waitingIndicator?.startAnimating()
        } else {
            self.status = .playing
            waitingIndicator?.stopAnimating()
        }
    }

    
    //
    // MARK: - Timer
    //
    private func createTimer() {
        guard self.timer == nil else {
            return
        }

        let newTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        
        newTimer.scheduleRepeating(deadline: DispatchTime.now(),
                                   interval: .milliseconds(500),
                                   leeway: .seconds(1))
        
        newTimer.setEventHandler() {
            // do nothing syncHUD
        }
        
        newTimer.resume()
        self.timer = newTimer
    }
    
    private func destoryTimer() {
        guard self.timer != nil else {
            return
        }
        timer?.cancel()
        self.timer = nil
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}

extension StreamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let e = textField.returnKeyType.rawValue
        if textField.returnKeyType == .default {
            textField.resignFirstResponder()
            go()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if urlTextField.canResignFirstResponder {
            urlTextField.resignFirstResponder()
        }
    }
}


