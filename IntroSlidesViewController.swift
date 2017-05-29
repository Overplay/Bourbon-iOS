//
//  IntroSlidesViewController.swift
//  Absinthe-iOS-X8
//
//  Created by Alyssa Torres on 2/17/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//
//  based on tutorial: http://sweettutos.com/2015/04/13/how-to-make-a-horizontal-paging-uiscrollview-with-auto-layout-in-storyboards-swift/

import UIKit

class IntroSlidesViewController: UIViewController, UIScrollViewDelegate {
    
    let slideImages: [UIImage] = [
        UIImage(named: "TestSlide1")!,
        UIImage(named: "TestSlide3")!,
        UIImage(named: "TestSlide4")!
    ]
    
    
    let slideImageURLs: [String] = [
        OGCloud.belliniCore + "bourbon/intro/slide1.jpg",
        OGCloud.belliniCore + "bourbon/intro/slide2.jpg",
        OGCloud.belliniCore + "bourbon/intro/slide3.jpg",
    ]
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MAK not sure why these are forced to main thread, but it works
    @IBAction func cancel(_ sender: Any) {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "fromIntroToReg", sender: nil)
        })
    }
    
    @IBAction func start(_ sender: Any) {
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "fromIntroToReg", sender: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set number of slides
        //self.pageControl.numberOfPages = self.slideImages.count
        
        // MK switching to URLs for post-launch mods
        self.pageControl.numberOfPages = self.slideImageURLs.count

        
        // set frame of scroll view to fill screen
        self.scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        let scrollViewWidth: CGFloat = self.scrollView.frame.width
        let scrollViewHeight: CGFloat = self.scrollView.frame.height
        
        // add slide images
//        for (idx, slideImage) in self.slideImages.enumerated() {
//            let x: CGFloat = scrollViewWidth * CGFloat(idx)
//            let imageView = UIImageView(frame: CGRect(x:x, y:0, width:scrollViewWidth, height:scrollViewHeight))
//            imageView.image = slideImage
//            self.scrollView.addSubview(imageView)
//        }

        for (idx, slideImageURL) in self.slideImageURLs.enumerated() {
            let x: CGFloat = scrollViewWidth * CGFloat(idx)
            let imageView = UIImageView(frame: CGRect(x:x, y:0, width:scrollViewWidth, height:scrollViewHeight))
            
            let url = URL(string: slideImageURL)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    guard let data = data else {
                        return self.cancel(self)
                    }
                    imageView.image = UIImage(data: data)

                }
            }
            
            self.scrollView.addSubview(imageView)
        }

        
        
        // change content size of scroll view to fit slides
        self.scrollView.contentSize = CGSize(width:scrollViewWidth * CGFloat(self.slideImages.count), height:scrollViewHeight)
        
        self.scrollView.delegate = self
        self.pageControl.currentPage = 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // test the offset and calculate the current page
        let pageWidth: CGFloat = self.scrollView.frame.width
        let currentPage: CGFloat = floor((self.scrollView.contentOffset.x-pageWidth/2)/pageWidth) + 1
        
        // change the page indicator
        self.pageControl.currentPage = Int(currentPage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
