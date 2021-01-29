//
//  ViewController.swift
//  MoviesStore
//
//  Created by Mohamed Khalid on 18/01/2021.
//

import UIKit
import CoreData
import SDWebImage

class MainPageViewController: UIViewController {

    // MARK:- Properties
    //
    var movies: ResultWrapper?
    var savedMovies: [NSManagedObject]?
    var filteredMovies: [NSManagedObject] = []
    var selectedMovieIndex: Int!
    var searchItem: String?
    var isValidTitle: Bool {
        if filteredMovies.count == 0{
            return false
        }
        else {
            return true
        }
    }
    
    // MARK:- Outlets
    //
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // MARK:- Methods
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        searchBar.delegate = self
        
        let cellNib = UINib(nibName: "MoviesTableViewCell", bundle: .none)
        moviesTableView.register(cellNib, forCellReuseIdentifier: "MovieCellIdentifier")
        
        loadMovies()
    }
    
    
    
    // MARK:- Helper methods
    //
    func loadMovies(){
        
        // Trying load data from core data
        loadDataFromCoreData()
        
        // If data exist --> finish loading data
        if savedMovies?.count != 0 {
            print("Data is loaded from core data")
            moviesTableView.reloadData()
            print("Table refreshed")
            return
        }
        
        // If data doesn't exist, try download them
        loadDataFromInternetAndSaveIt()
    }
    
    func getSearchResults(){
        filteredMovies.removeAll()
        guard let movies = savedMovies else { return }
        var correctMovie: NSManagedObject?
//        for i in 0..<movies.count{
//            if movies[i].value(forKey: "title") as? String == searchItem{
//                correctMovie = movies[i]
//                break
//            }
//        }
        
        for movie in movies {
            if movie.value(forKey: "title") as? String == searchItem{
                correctMovie = movie
                break
            }
        }

        if let correctMovie = correctMovie{
            filteredMovies.append(correctMovie)
            moviesTableView.reloadData()
        }
    }
    // MARK:- Networking
    //
    func loadDataFromInternetAndSaveIt(){
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
                let resultWrapper = try JSONDecoder().decode(ResultWrapper.self, from: data)
                self.movies = resultWrapper
                print ("Data loaded from internet")
                DispatchQueue.main.async {
                    self.saveData(data: resultWrapper)
                    self.moviesTableView.reloadData()
                    print("Table refreshed")
                }
            }
            catch{
                print("Downloading error: '\(error.localizedDescription)'")
            }
        }
        dataTask.resume()
    }
}


// MARK:- Table view deletages
//
extension MainPageViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isValidTitle{
            return filteredMovies.count
        } else{
            return savedMovies?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellIdentifier", for: indexPath) as! MoviesTableViewCell
        if (isValidTitle){
            cell.movieNameLabel.text = filteredMovies[indexPath.row].value(forKey: "title") as? String
            let movieURL = filteredMovies[indexPath.row].value(forKey: "image") as? String
            cell.movieImageView.sd_setImage(with: URL(string: movieURL ?? ""), placeholderImage: UIImage(named: "movieImage.png"))
        } else {
            cell.movieNameLabel.text = savedMovies?[indexPath.row].value(forKey: "title") as? String
            let movieURL = savedMovies?[indexPath.row].value(forKey: "image") as? String
            cell.movieImageView.sd_setImage(with: URL(string: movieURL ?? ""), placeholderImage: UIImage(named: "movieImage.png"))
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMovieIndex = indexPath.row
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let detailsVC = storyBoard.instantiateViewController(identifier: "DetailsVC") as! DetailsPageViewController
        detailsVC.delegate = self
        navigationController?.pushViewController(detailsVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK:- Search bar delegate
//
extension MainPageViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchItem = searchBar.text
        // If search for nothing, do nothing
        if (searchItem != "")
        {
            print ("you searched about \(searchItem ?? "")")
            getSearchResults()
        }
        else{
            print ("you searched about \(searchItem ?? "")")
            filteredMovies.removeAll()
            moviesTableView.reloadData()
        }
    }
}

// MARK:- Details page delegate methods
//
extension MainPageViewController: DetailsPageViewControllerDelegate{
    func detailsPageViewControllerDelegateRequireDetails(_ controller: DetailsPageViewController) -> NSManagedObject {
        return savedMovies?[selectedMovieIndex] ?? NSManagedObject()
    }
    
//    func detailsPageViewControllerDelegateRequireDetails(_ controller: DetailsPageViewController) -> MovieDetails {
//        return movies![selectedMovieIndex]
//    }
}

// MARK:- Core Data methods
//
extension MainPageViewController{
    func saveData(data: ResultWrapper){
        // App delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        // Context
        let context = appDelegate.persistentContainer.viewContext
        // NSManagedObject
        let entity = NSEntityDescription.entity(forEntityName: "Movie", in: context)
        guard let unwrappedEntity = entity else{return}
        // Set movie
        for i in 0..<data.count{
            let movie = NSManagedObject(entity: unwrappedEntity, insertInto: context)
            movie.setValue(data[i].title, forKey: "title")
            movie.setValue(data[i].image, forKey: "image")
            movie.setValue(data[i].rating, forKey: "rating")
            movie.setValue(data[i].releaseYear, forKey: "releaseYear")
            let genreString = data[i].genre.joined(separator: ", ")
            movie.setValue(genreString, forKey: "genre")
            do{
                try context.save()
                self.savedMovies?.append(movie)
            } catch{
                print ("Saving error: '\(error.localizedDescription)'")
            }
        }
        print("Data saved to core data")
    }
    
    func loadDataFromCoreData(){
        // App delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Context
        let context = appDelegate.persistentContainer.viewContext
        // Fetching
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Movie")
        do{
            savedMovies?.removeAll()
            try savedMovies = context.fetch(fetchRequest)
        } catch{
            print("Cannot fetch the data: '\(error.localizedDescription)'")
        }
    }
}
