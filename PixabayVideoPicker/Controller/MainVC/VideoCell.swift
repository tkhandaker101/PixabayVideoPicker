//
//  VideoCell.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 22/5/23.
//

import UIKit

class VideoCell: UICollectionViewCell {
    
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var video: PixabayHitModel?
    var imageId: Int?
    
    private var currentPhotoID: Int?
    private var imageDownloader = ImageDownloader()
    
    func setDuration(totalSec: Int) {
        let time = totalSec
        
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        var durationString = ""
        var formatString = ""
        if hours == 0 {
            if(minutes < 10) {
                formatString = "%2d:%0.2d"
            }else {
                formatString = "%0.2d:%0.2d"
            }
            
            durationString = String(format: formatString,minutes,seconds)
            //return String(format: formatString,minutes,seconds)
        }else {
            formatString = "%2d:%0.2d:%0.2d"
            durationString = String(format: formatString,minutes,seconds)
        }
        duration.text = durationString
    }
    
    func configure(with pixabayModel: PixabayHitModel) {
        autoreleasepool {
            self.currentPhotoID = pixabayModel.id
            setDuration(totalSec: pixabayModel.duration)
            self.userName.text = pixabayModel.user
            let size = "\(pixabayModel.videos.tiny.width)x\(pixabayModel.videos.tiny.height)"
            let url = URL(string: "https://i.vimeocdn.com/video/\(pixabayModel.pictureID)_\(size).jpg")!
            downloadImage(with: url, and: currentPhotoID!)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        duration.text = ""
        userName.text = ""
        currentPhotoID = nil
        imageDownloader.cancel()
    }
    
    private func downloadImage(with url: URL, and id: Int) {
        let downloadPhotoID = id 
        imageDownloader.downloadPhoto(with: url, completion: { [weak self] (image, isCached) in
            guard let strongSelf = self, strongSelf.currentPhotoID == downloadPhotoID else {
                return }

            if isCached {
                strongSelf.imageView.image = image
            } else {
                UIView.transition(with: strongSelf, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    strongSelf.imageView.image = image
                }, completion: nil)
            }
        })
    }
}
