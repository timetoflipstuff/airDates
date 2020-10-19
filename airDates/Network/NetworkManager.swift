//
//  NetworkManager.swift
//  airDates
//
//  Created by Alex Mikhaylov on 02/12/2019.
//  Copyright © 2019 Alexander Mikhaylov. All rights reserved.
//

import Foundation
import UIKit

final class NetworkManager {

    static func getSearchQueryResults(query: String, page: Int, completion: @escaping (Results?) -> Void) {

        let query = query.replacingOccurrences(of: " ", with: "%20")
        let urlString = "https://www.episodate.com/api/search?q=\(query)&page=\(page)"
        guard let url = URL(string: urlString) else {return}
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { (data : Data?, response: URLResponse?, error : Error?) in

            if let error = error {
                print(error.localizedDescription)
            }

            guard let data = data else {return}

            do {
                let objects = try JSONDecoder().decode(Results.self, from: data)
                completion(objects)
            } catch {
                print(error)
                completion(nil)
            }
        }

        task.resume()
    }
    
    static func downloadImage(link: String, completion: @escaping(UIImage?) -> Void) {

        let url = URL(string: link)
        let request = URLRequest(url: url!)

        let task = URLSession.shared.dataTask(with: request) { (data : Data?, response: URLResponse?, error : Error?) in

            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }

        task.resume()
    }

    static func getShowData(id: Int32, completion: @escaping(ShowInfo?) -> Void) {

        let url = URL(string: "https://www.episodate.com/api/show-details?q=\(id)")
        let request = URLRequest(url: url!)

        let task = URLSession.shared.dataTask(with: request) { (data : Data?, response: URLResponse?, error : Error?) in

            guard let data = data else {return}

            do {
                let objects = try JSONDecoder().decode(ShowInfoJSON.self, from: data)
                completion(objects.tvShow)
            } catch {
                print(error)
                completion(nil)
            }
        }

        task.resume()
    }

    static func getShowsData(ids: [Int32], completion: @escaping([ShowMetaInfo]) -> Void) {

        var showsArray: [ShowMetaInfo] = []

        let dispatchGroup = DispatchGroup()

        ids.forEach {
            dispatchGroup.enter()
            NetworkManager.getShowData(id: $0) { showData in
                if let showData = showData {
                    showsArray.append(ShowMetaInfo(showInfo: showData))
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            print("sssss \(showsArray.count)")
            completion(showsArray)
        }
    }
}
