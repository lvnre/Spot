//
//  ViewController.swift
//  Spot
//
//  Created by Lanre Akomolafe on 11/14/16.
//  Copyright © 2016 lvnre. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

var player = AVAudioPlayer()

struct post {
    let image:  UIImage!
    let name:   String!
    let url: String!
}

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    //var searchURL = "https://api.spotify.com/v1/search?q=21+Savage&type=track"
    @IBOutlet weak var searchBar: UISearchBar!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("hahahah")
        //Get the user's search bar input, modify it to be URL-friendly
        let keywords = searchBar.text?.replacingOccurrences(of: " ", with: "+")
        //store the spotify GET request URL and call the function to populate table view
        //be sure to unwrap keywords since it'll return an optional
        let searchURL = "https://api.spotify.com/v1/search?q=\(keywords!)&type=track"
        //Reset the posts array
        posts = [post]()
        callAlamo(url: searchURL)
        self.view.endEditing(true)
        
    }
    
    //Since we're gonna use this alot, make a typealias for it
    typealias JSONStd = [String : AnyObject]
    
    //Array of song names
    var names = [String]()
    var posts = [post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.resignFirstResponder()
        // Do any additional setup after loading the view, typically from a nib.
        //callAlamo(url: searchURL)
        //callAlamo(url: "https://alaye.biz/category/blog/")
        
    }
    
    func forUncle(JSONData : Data) {
        do {
            
            let json = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStd
            print(json)
            
        } catch {
            
            print(error)
            
        }
    }

    
    func callAlamo(url: String) {
        print("calling")
        //Request JSON from the given url
        Alamofire.request(url).responseJSON(completionHandler: {
            //'response' is the raw JSON received once completed
            response in
            //parse the JSON to a [String : AnyObject] typealias for indexing
            if let json = response.result.value as? JSONStd {
                //Start indexing into JSON to get song names
                if let tracks = json["tracks"] {
                    if let items = tracks["items"] {
                        for item in items as! [JSONStd] {
                            
                            //Store the name of the song
                            let name = item["name"] as! String
                            
                            //Store the url of the 30-sec preview
                            let previewURL = item["preview_url"] as! String
                            
                            //Get the album artwork
                            if let album = item["album"] {
                                if let images = album["images"] as? [JSONStd]{
                                    //High quality image is first element in images[]
                                    let imageData = images[0]
                                    //Get the URL of the image, and the data from the URL
                                    let mainImageURL = URL(string: imageData["url"] as! String)
                                    let mainImageData = NSData(contentsOf: mainImageURL!)
                                    //Create the UIImage
                                    let mainImage = UIImage(data: mainImageData as! Data)
                                    //Append a new post with the name and image
                                    self.posts.append(post.init(image: mainImage, name: name, url: previewURL))
                                    //Reload the data
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        //Declare the imageView and label
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        //Fill them in
        mainImageView.image = posts[indexPath.row].image
        mainLabel.text = posts[indexPath.row].name
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow?.row
        let vc = segue.destination as! AudioViewController
        //unwrap indexPath when indexing because indexPathForSelectedRow is an optional
        vc.songImage = posts[indexPath!].image
        vc.songTitle = posts[indexPath!].name
        vc.mainPreviewURL = posts[indexPath!].url
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

