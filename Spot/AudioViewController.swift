//
//  AudioViewController.swift
//  Spot
//
//  Created by Lanre Akomolafe on 11/17/16.
//  Copyright © 2016 lvnre. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AudioViewController: UIViewController {
    
    var songImage = UIImage()
    var songTitle = String()
    var mainPreviewURL = String()
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        background.image = songImage
        imageView.image = songImage
        label.text = songTitle
        
        //Start downloading the preview
        downloadFileFromURL(url: URL(string: mainPreviewURL)!)
    }
    
    func downloadFileFromURL(url: URL) {
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (downloadedURL, response, error) in
            self.playSong(url: downloadedURL!)
        })
        downloadTask.resume()
    }
    
    func playSong(url: URL) {
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
        } catch {
            print(error)
        }
    }
    
    
}
