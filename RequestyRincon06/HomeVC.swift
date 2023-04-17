//
//  ViewController.swift
//  RequestyRincon06
//
//  Created by Nick Rodriguez on 17/04/2023.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet var lblPost: UILabel!
    
    
    @IBAction func btnCallTuRincon(_ sender: UIButton) {
        store.fetchTuRinconPosts { result in
            switch result{
            case let .success(post_list):
                print("Successfully got data from API")
// we could load postArray = [TuRinconPost] here but this would evade core data.
            case .failure:
                print("Failed to get data")
            }
        }
    }
    
    @IBAction func btnSavePersist(_ sender: UIButton) {
        store.saveData()
    }
    
    @IBAction func btnDisplayPost(_ sender: UIButton) {
        self.updateDataSource()
    }
    
    var store: PostStore!
    var postArray = [Post]() {
        didSet{
            print("postArray has \(postArray.count) posts")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        store = PostStore()
        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
    }
    
    func updateDataSource() {
        print("- updateDataSource called -")
        store.fetchPostsFromCoreData { post_cd_list in
            self.postArray = post_cd_list
            self.lblPost.text = post_cd_list[0].post_text
        }
    }

}

