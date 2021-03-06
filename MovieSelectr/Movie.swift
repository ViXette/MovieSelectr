//
//  Movie.swift
//  MovieSelectr
//
//  Created by VX on 27/11/2016.
//  Copyright © 2016 VXette. All rights reserved.
//

import UIKit

public struct Movie {
	
	static let APIKEY = "f94699f112fb8169ba914cf356c6d779"
	private static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
	
	public var title :String!
	public var imagePath :String!
	public var description :String!
	
	
	init (title :String, imagePath :String, description :String) {
		self.title = title
		self.imagePath = imagePath
		self.description = description
	}
	
	
	private static func getMovieData (with completion :@escaping (_ success :Bool, _ object :AnyObject?) -> () ) {
		let session = URLSession(configuration: .default)
		
		let request = URLRequest(url: URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(APIKEY)")!)
		
		session.dataTask(with: request) {
			(data: Data?, response: URLResponse?, error: Error?) in
			
			if let data = data {
				let json = try? JSONSerialization.jsonObject(with: data, options: [])
				
				if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
					completion(true, json as AnyObject?)
				} else {
					completion(false, json as AnyObject?)
				}
			}
		}.resume()
	}
	
	
	public static func nowPlaying (with completion :@escaping (_ success :Bool, _ movies :[Movie]?) -> () ) {
		Movie.getMovieData {
			(success, object) in
			
			if success {
				var movieArray = [Movie]()
				
				if let movieResult = object?["results"] as? [Dictionary<String, AnyObject>] {
					for movie in movieResult {
						guard let posterImage = movie["poster_path"] as? String else{
							continue
						}
						
						let title = movie["original_title"] as! String
						let description = movie["overview"] as! String
						
						let movieObj = Movie(title: title, imagePath: posterImage, description: description)
						
						movieArray.append(movieObj)
					}
					completion(true, movieArray)
				} else {
					completion(false, nil)
				}
			}
		}
	}
	
	
	private static func getDocumentDirectory () -> String? {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		
		guard let documents = paths.first else {
			return nil
		}
		
		return documents
	}
	
	
	private static func checkForImageData (withMovieObject movie :Movie) -> String? {
		if let documents = getDocumentDirectory() {
			let movieImagePath = documents + "/\(movie.title!)"
			
			let escapedImagePath = movieImagePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
			
			if FileManager.default.fileExists(atPath: escapedImagePath) {
				return escapedImagePath
			}
		}
		
		return nil
	}
	
	
	public static func getImage (forCell cell :AnyObject, withMovieObject movie :Movie) {
		if let imagePath = checkForImageData(withMovieObject: movie) { // Image already downloaded
			if let imageData = FileManager.default.contents(atPath: imagePath) {
				setImageForCell(cell, imageData: imageData)
			}
		} else { // Download an image and save on device
			let imagePath = Movie.imageBaseURL + movie.imagePath
			
			let imageUrl = URL(string: imagePath)
			
			DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
				do {
					let data = try Data(contentsOf: imageUrl!)
					
					let documents = getDocumentDirectory()
					
					let imageFilePathString = documents! + "/\(movie.title!)"
					
					let escapedImagePath = imageFilePathString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
					
					if FileManager.default.createFile(atPath: escapedImagePath, contents: data, attributes: nil) {
						print("Image saved")
					}
					
					DispatchQueue.main.async(execute: { 
						setImageForCell(cell, imageData: data)
					})
				} catch {
					print("No image at speciied location")
				}
			}
		}
	}
	
	
	private static func setImageForCell (_ cell :AnyObject, imageData data :Data) {
		if cell is UITableViewCell {
			let tableViewCell = cell as! UITableViewCell
			tableViewCell.imageView?.image = UIImage(data: data)
			tableViewCell.setNeedsLayout()
		} else {
			// TODO: Add CollectionViewCell Implemenation
		}
	}
	
}
