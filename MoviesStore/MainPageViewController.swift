//
//  ViewController.swift
//  MoviesStore
//
//  Created by Mohamed Khalid on 18/01/2021.
//

import UIKit

class MainPageViewController: UIViewController {

    // MARK:- Properties
    //
    var movies: ResultWrapper?
    var titles: [String] = [""]
    var selectedMovieIndex: Int!
    
    // MARK:- Outlets
    //
    @IBOutlet weak var moviesTableView: UITableView!
    
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! DetailsPageViewController
        controller.delegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        
        
        
        let cellNib = UINib(nibName: "MoviesTableViewCell", bundle: .none)
        moviesTableView.register(cellNib, forCellReuseIdentifier: "MovieCellIdentifier")
        
        // Networking
        guard let url = URL(string: "https://api.androidhive.info/json/movies.json") else {return}
        let urlRequest = URLRequest(url: url)
        let urlSession = URLSession(configuration: .default)
        let dataTask = urlSession.dataTask(with: urlRequest){data,_,error in
            guard let data = data else {return}
            /*do{
                let data = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [Dictionary<String, Any>]
                self.loadDataAndRefreshTable(with: data)
            }*/
            do{
                self.titles.removeAll()
                let resultWrapper = try JSONDecoder().decode(ResultWrapper.self, from: data)
                self.loadDataAndRefreshTable(with: resultWrapper)
                print ("Data loaded")
            }
            catch{
                print("Downloading error: '\(error.localizedDescription)'")
            }
        }
        dataTask.resume()
    }
    
    
    
    // Helper methods
    //
    func loadDataAndRefreshTable(with data: ResultWrapper){
        /*
        movies.removeAll()
        for movie in data{
            for (key, value) in movie{
                if key == "title"{
                    movies.append(value as! String)
                }
            }
        }
        DispatchQueue.main.async {
            self.moviesTableView.reloadData()
        }*/
        
        for movie in data{
            titles.append(movie.title)
        }
        DispatchQueue.main.async {
            self.moviesTableView.reloadData()
        }
    }
    

}

// Table view deletages
//
extension MainPageViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellIdentifier", for: indexPath) as! MoviesTableViewCell
        cell.movieNameLabel.text = titles[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMovieIndex = indexPath.row
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let detailsVC = storyBoard.instantiateViewController(identifier: "DetailsVC") as! DetailsPageViewController
        navigationController?.pushViewController(detailsVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension MainPageViewController: DetailsPageViewControllerDelegate{
    func detailsPageViewControllerDelegateRequireDetails(_ controller: DetailsPageViewController) -> MovieDetails {
        let dummyMovie = MovieDetails(title: "vvv", image: "njkh", rating: 5.6, releaseYear: 23, genre: [""])
        return dummyMovie
        //return movies![selectedMovieIndex]
    }
}
