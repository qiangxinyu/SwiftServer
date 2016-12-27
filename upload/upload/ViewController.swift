//
//  ViewController.swift
//  upload
//
//  Created by 强新宇 on 2016/12/26.
//  Copyright © 2016年 强新宇. All rights reserved.
//

import UIKit
import AFNetworking
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
       
        
        
        
        
       
        
    }
    @IBOutlet weak var clickBtn: UIButton!
    @IBAction func clickBtn(_ sender: Any) {
        var imageData: Data
        
        do {
            
            let url = "file://" + Bundle.main.path(forResource: "IMG_0243", ofType: "png")!
            
            let imageURL = URL(string: url)!
            
            imageData = try Data(contentsOf: imageURL)
            
            let manager = AFHTTPSessionManager()
            
            manager.post("", parameters: nil, constructingBodyWith: { (formData) in
                
            }, progress: nil, success: nil, failure: nil)
            
            manager.post("http://0.0.0.0:8181/v2/upload", parameters: nil, constructingBodyWith: { (formData) in
                
                formData.appendPart(withFileData: imageData, name: "ongif", fileName: "IMG_0243.png", mimeType: "image/png")
                
                
                print("uploading....")
            }, progress: nil, success: { (task, responseObject) in
                print(responseObject as Any)
            }) { (task, error) in
                print(error)
            }
            
            
//            
//            manager.post("http://0.0.0.0:8181/v1/my", parameters: ["foo":12.3,"five":53.1], progress: nil, success: { (task, responsObject) in
//                print(responsObject as Any)
//            }, failure: { (task, error) in
//                print(error)
//            })
        } catch {
            
        }
        
    }

    @IBOutlet weak var clickDownloadBtn: UIButton!
    
    @IBAction func clickDownloadBtn(_ sender: Any) {
        let manager = AFHTTPSessionManager()

        let url = URL(string: "http://0.0.0.0:8181/IMG_0090.m4v")!
        let request = URLRequest(url: url)
        
        weak var weakSelf = self
        
        let task = manager.downloadTask(with: request, progress: { (progress) in
            print("\(progress.totalUnitCount) ==> \(progress.completedUnitCount)")
        }, destination: { (pathURL, response) -> URL in
            return weakSelf!.downloadFileURL()
        }) { (reponse, fileURL, error) in
            
            if let downloadURL = fileURL {
               
                let queue = DispatchQueue.main
                queue.async {
                    let playerItem = AVPlayerItem(url: downloadURL)
                    let player = AVPlayer(playerItem: playerItem)
                    let playerLayer = AVPlayerLayer(player: player)
                    playerLayer.frame = CGRect(x: 0, y: 300, width: weakSelf!.view.frame.size.width, height: 367)
                    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
                    playerLayer.backgroundColor = UIColor.black.cgColor
                    
                    weakSelf!.view.layer.addSublayer(playerLayer)
                    
                    
                    player.play()
                }
                return
            }
            
            print("Error: \(error)")
            
        }
        
        task.resume()
        
       
        
    }
    
    func downloadFileURL() -> URL {
        
        let documentsDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documentsDirectoryURL.appendingPathComponent("video_file.m4v")
    }
    
    @IBAction func clickPlayBtn(_ sender: Any) {
        
        let url = URL(string: "http://0.0.0.0:8181/IMG_0090.m4v")!

        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 300, width: self.view.frame.size.width, height: 367)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer.backgroundColor = UIColor.black.cgColor
        
        self.view.layer.addSublayer(playerLayer)
        
        
        player.play()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

