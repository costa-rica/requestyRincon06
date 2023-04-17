//
//  PostStore.swift
//  RequestyRincón05
//
//  Created by Nick Rodriguez on 16/04/2023.
//

import Foundation
import CoreData

enum PostError: Error {
    case processingFailed
    case anotherError
}

class PostStore {
    
    // host persistent container property
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name:"RequestyRincon06")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
    
    
    // host session
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    // dataTask call api
    func fetchTuRinconPosts(completion: @escaping(Result<[Post],Error>) -> Void) {
        let url = URLBuilder.createUrl()
        var request = URLRequest(url:url)
        
        var httpBodyData:Data?
        
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        
        do {
            httpBodyData = try JSONSerialization.data(
                withJSONObject: ["rincon_id": "2"],
                options: [])
            print("Successfully JSONSErialization- ed")
        } catch{ print("failed to convert to jsonData")}
        
        request.httpBody = httpBodyData
        
        
        let task = session.dataTask(with:request) { (data,response,error) in
            var result = self.processTuRinconPosts(data: data, error: error)
            if case .success = result {

                print("processed data into Core Data successfully!")
            }
            OperationQueue.main.addOperation{
                completion(result)
            }
        }
        task.resume()
    }
    
    
    //process api response
    private func processTuRinconPosts(data: Data?, error: Error?) -> Result<[Post], Error> {
        guard let unwrapped_data = data else {
            return .failure(error!)
        }
        var post_list: [Post]!
        let context = persistentContainer.viewContext
        do {
            let decoder = JSONDecoder()
            let tuRinconPostsArray = try decoder.decode([TuRinconPost].self,from:unwrapped_data)
            let posts = tuRinconPostsArray.map { tuRinconPost -> Post in
                
                /* This is all the code necessary to check what prevent duplicates added to Core Data based on the post_id*/
                let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
                let predicate = NSPredicate(
                    format: "\(#keyPath(Post.post_id)) == \(tuRinconPost.post_id)"
                )
                fetchRequest.predicate = predicate
                var fetchedPosts: [Post]?
                context.performAndWait {
                    fetchedPosts = try? fetchRequest.execute()
                }
                if let existingPost = fetchedPosts?.first {
                    return existingPost
                }
                /* end duplicate prevention via post_id */
                
                var post: Post!
                context.performAndWait{
                    post = Post(context: context)
                    post.post_id = tuRinconPost.post_id
                    post.date = tuRinconPost.date
                    post.post_text = tuRinconPost.post_text// This might be a problem
                    post.username = tuRinconPost.username
                }
                print("* Did we get here? ")
                
                return post
            }
            post_list = posts
            
        } catch {
            print("Failed decoding")
            return .failure(error)
        }
        print("Some other container type error")
        return .success(post_list)
    }
    
    
    func saveData(){
        do {
            try self.persistentContainer.viewContext.save()
        } catch {
//            result = .failure(error)
            print("Unable to save data")
        }
    }
    
    func fetchPostsFromCoreData(completion:@escaping([Post]) -> Void) {
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPosts = try viewContext.fetch(fetchRequest)
                print("- fetching from Core data ok")
                    completion(allPosts)

                
            } catch {
                print("Failed to return posts from core data.")
            }
        }
    }
    
}
