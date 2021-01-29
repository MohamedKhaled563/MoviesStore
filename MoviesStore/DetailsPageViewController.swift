//
//  DetailsPageViewController.swift
//  MoviesStore
//
//  Created by Mohamed Khalid on 18/01/2021.
//

import UIKit
import CoreData
import SDWebImage

protocol DetailsPageViewControllerDelegate: class {
//    func detailsPageViewControllerDelegateRequireDetails(_ controller: DetailsPageViewController) -> MovieDetails
        func detailsPageViewControllerDelegateRequireDetails(_ controller: DetailsPageViewController) -> NSManagedObject
}


class DetailsPageViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    weak var delegate: DetailsPageViewControllerDelegate?
    
   // var movieDetails: MovieDetails?
     var movieDetails: NSManagedObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        
        print("Scene loaded")
        movieDetails = delegate?.detailsPageViewControllerDelegateRequireDetails(self)
        putDataOnScreen()
        print ("title: \(movieDetails?.value(forKey: "title") ?? "")")
        // Do any additional setup after loading the view.
    }
    

    // MARK:- Helpers
    //
    func putDataOnScreen(){
//        titleLabel.text?.append(movieDetails?.title ?? "")
//        // TODO:- Add image download pod and download image in and put it in the view
//        ratingLabel.text?.append("\(movieDetails?.rating ?? 0)" )
//        releaseYearLabel.text?.append("\(movieDetails?.releaseYear ?? 0)" )
//        genreLabel.text?.append(movieDetails?.genre.joined(separator: ", ") ?? "")
        
        titleLabel.text?.append("\(movieDetails?.value(forKey: "title" ) ?? "")")
        // TODO:- Add image download pod and download image in and put it in the view
        let movieURL = movieDetails?.value(forKey: "image") as? String
        movieImageView.sd_setImage(with: URL(string: movieURL ?? ""), placeholderImage: UIImage(named: "movieImage.png"))
        ratingLabel.text?.append("\(movieDetails?.value(forKey: "rating") ?? 0)" )
        releaseYearLabel.text?.append("\(movieDetails?.value(forKey: "releaseYear") ?? 0)" )
        genreLabel.text?.append("\(movieDetails?.value(forKey: "genre") ?? "")")
    }

}
