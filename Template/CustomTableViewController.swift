
//
//  CustomTableViewController.swift
//  Template
//
//  Created by Mateo Garcia on 4/4/17.
//  Copyright © 2017 StreetCode. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MobileCoreServices
import Alamofire
import AlamofireImage
import AVKit

class CustomTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var posts = [Post]()
    var users = [String: InstaUser]()
    var videofileurl: NSURL?
    var thumbnailImage: UIImage?
    let imageDownloader = ImageDownloader(configuration: ImageDownloader.defaultURLSessionConfiguration(), downloadPrioritization: .fifo, maximumActiveDownloads: 4, imageCache: AutoPurgingImageCache())

    override func viewDidLoad() {
        super.viewDidLoad()
        /*var user1 = InstaUser(id: "123", dictionary: ["name": "Drake", "email": "drake@gmail.com", "imageurl": "drake.jpeg"] as AnyObject)
        users.append(user1)
        var post = Post(id: "123", dictionary: ["mics": 2, "imageurl": "drake.jpeg", "videourl": "drake_video.jpeg"] as AnyObject)
        posts.append(post)
        var user2 = InstaUser(id: "1234", dictionary: ["name": "Willow", "email": "willow@gmail.com", "imageurl": "imwillowsmith.jpeg"] as AnyObject)
        users.append(user2)
        var post2 = Post(id: "1234", dictionary: ["mics": 4, "imageurl": "imwillowsmith.jpeg", "videourl": "Willow_Smith.jpeg"] as AnyObject)
        posts.append(post2)*/
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let rootNode = Database.database().reference()
        
        // Observe users
        let usersNode = rootNode.child("users")
        usersNode.observe(.childAdded) { (snapshot: DataSnapshot) in
            let userId = snapshot.key
            let user = InstaUser(id: userId, dictionary: snapshot.value as AnyObject)
            self.users[userId] = user
        }

        // Observe posts
        let postsNode = rootNode.child("posts")
        postsNode.observe(.childAdded) { (snapshot: DataSnapshot) in
            let postId = snapshot.key
            let post = Post(id: postId, dictionary: snapshot.value as AnyObject)
            self.posts.append(post)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell

        // Configure the cell...
        let post = posts[indexPath.row]
        if let imageurl = post.imageurl {
            let urlRequest = URLRequest(url: URL(string: imageurl)!)
                imageDownloader.download(urlRequest, completion: { (response: DataResponse<Image>) in
                    if let image = response.result.value {
                        
                        cell.videoImageView.image = image
                    }
            })
        }

        cell.profileImageView.image = nil
        if let userid = post.userid, let user = users[userid] {
            cell.usernameLabel.text = user.name

            if let imageurl = user.imageurl {
                let urlRequest = URLRequest(url: URL(string: imageurl)!)
                imageDownloader.download(urlRequest, completion: { (response: DataResponse<Image>) in
                    if let image = response.result.value {
                        
                        cell.profileImageView.image = image
                    }
                })
            }
        }
        else {
            cell.usernameLabel.text = nil
        }
        cell.usernameLabel.adjustsFontSizeToFitWidth = true
        cell.micCountLabel.text = "\(post.mics!)"
        cell.videourl = post.videourl
        cell.delegate = self

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }*/
     @IBAction func onSignOutButton(_ sender: UIBarButtonItem) {
        do {
            
            try Auth.auth().signOut()
        }
        catch let error {
            
            print("Unable to sign out: \(error)")
        }
     }
 
    @IBAction func onCameraButton(_ sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.mediaTypes = [kUTTypeMovie as String]
        
        let OptionMenu = UIAlertController(title: nil, message: "please choose a video source", preferredStyle: .actionSheet)
        let cameraOption = UIAlertAction(title: "Camera", style: .default) { (alert: UIAlertAction) in
            if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
                picker.sourceType = .camera
                picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
            } else {
                print("No camera")
            }
        }
        let albumOption = UIAlertAction(title: "Photo Album", style: .default) { (alert: UIAlertAction) in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) in
        }
        OptionMenu.addAction(cameraOption)
        OptionMenu.addAction(albumOption)
        OptionMenu.addAction(cancelOption)
        present(OptionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videofileurl = info[UIImagePickerControllerMediaURL] as? NSURL {
            thumbnailImage = getThumbnailImage(forVideoFileUrl: videofileurl)
            if let currentUserId = InstaUser.currentUser?.id {
                let rootNode = Database.database().reference()
                let postNode = rootNode.child("posts").childByAutoId()
                
                let storageNode = Storage.storage().reference()
                let postImageNode = storageNode.child("postImages").child("\(postNode.key).png")
                if let imageData = UIImagePNGRepresentation(thumbnailImage!) {
                    // Save image.
                    postImageNode.putData(imageData, metadata: nil, completion: { (metadata: StorageMetadata?, error: Error?) in
                        
                        if error == nil {
                            let imageUrl = metadata?.downloadURL()
                            let postVideoNode = storageNode.child("postVideos").child("\(postNode.key).mov")
                            // Save video.
                            postVideoNode.putFile(from: videofileurl as URL, metadata: nil, completion: { (metadata: StorageMetadata?, error: Error?) in
                                
                                if error == nil {
                                    let videoUrl = metadata?.downloadURL()
                                    let values = [
                                        "userid": currentUserId as Any,
                                        "mics": 0 as Any,
                                        "imageurl": imageUrl?.absoluteString ?? "" as Any,
                                        "videourl": videoUrl?.absoluteString ?? "" as Any
                                    ]
                                    // Save post.
                                    postNode.updateChildValues(values, withCompletionBlock: { (error: Error?, database: DatabaseReference) in
                                         // Do this by observing instead?
                                         if error == nil {
                                            postNode.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                                                let postId = snapshot.key
                                                let post = Post(id: postId, dictionary: snapshot.value as AnyObject)
                                                self.posts.append(post)
                                            })
                                        }
                                    })
                                }
                            })
                            
                        }
                    })
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func getThumbnailImage(forVideoFileUrl videoFileUrl: NSURL) -> UIImage? {
        
        let imageGenerator = AVAssetImageGenerator(asset: AVAsset(url: videoFileUrl as URL))
        
        do {
            let thumbailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbailCGImage)
        }
        catch {
            return UIImage()
        }
    }    
}

extension CustomTableViewController: CustomTableViewCellDelegate {
    
    func cellPlayVideo(forVideoUrl videoUrl: URL) {
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = AVPlayer(url: videoUrl)
        present(playerViewController, animated: true){
            playerViewController.player!.play()
        }
    }
}
