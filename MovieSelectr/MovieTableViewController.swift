//
//  MovieTableViewController.swift
//  MovieSelectr
//
//  Created by VX on 27/11/2016.
//  Copyright © 2016 VXette. All rights reserved.
//

import UIKit

class MovieTableViewController: UITableViewController {
	
	var nowPlaying = [Movie]()

	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		loadData()
	}
	
	
	func loadData() {
		Movie.nowPlaying {
			(success: Bool, movieList :[Movie]?) in
			
			if success {
				self.nowPlaying = movieList!
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		}
	}


	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}


	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return nowPlaying.count
	}

	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		let movie = nowPlaying[indexPath.row]
		
		cell.textLabel?.text = movie.title
		cell.detailTextLabel?.text = movie.description
		
		Movie.getImage(forCell: cell, withMovieObject: movie)

		return cell
	}

}
