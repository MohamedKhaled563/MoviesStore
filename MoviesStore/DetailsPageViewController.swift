//
//  DetailsPageViewController.swift
//  MoviesStore
//
//  Created by Mohamed Khalid on 18/01/2021.
//

import UIKit

protocol DetailsPageViewControllerDelegate: class {
    func detailsPageViewControllerDelegateRequireDetails(_ controller: DetailsPageViewController) -> MovieDetails
}


class DetailsPageViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    weak var delegate: DetailsPageViewControllerDelegate?
    
    var movieDetails: MovieDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        print("Scene loaded")
        movieDetails = delegate?.detailsPageViewControllerDelegateRequireDetails(self)
        print ("title: \(movieDetails?.title)")
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
