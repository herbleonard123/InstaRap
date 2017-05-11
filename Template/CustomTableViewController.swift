
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

class CustomTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var posts = [Post]()
    var videofileurl: NSURL?
    var thumbnailImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        // TODO: This code is incomplete. Need to set up the cell based on info from the post object. Could use AlamofireImage to download the image based on the image URL.
        //cell.videoImageView.image =
        cell.micCountLabel.text = "\(post.mics)"

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
            
            try FIRAuth.auth()?.signOut()
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
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
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
            if let currentUserId = User.currentUser?.id {
                let rootNode = FIRDatabase.database().reference()
                let postNode = rootNode.child("posts").child(currentUserId).childByAutoId()
                
                let storageNode = FIRStorage.storage().reference()
                let postImageNode = storageNode.child("postImages").child("\(postNode.key).png")
                if let imageData = UIImagePNGRepresentation(thumbnailImage!) {
                    // Save image.
                    postImageNode.put(imageData, metadata: nil, completion: { (metadata: FIRStorageMetadata?, error: Error?) in
                        
                        if error == nil {
                            let imageUrl = metadata?.downloadURL()
                            let postVideoNode = storageNode.child("postVideos").child("\(postNode.key).mov")
                            // Save video.
                            postVideoNode.putFile(videofileurl as URL, metadata: nil, completion: { (metadata: FIRStorageMetadata?, error: Error?) in
                                
                                if error == nil {
                                    let videoUrl = metadata?.downloadURL()
                                    let values = [
                                        "mics": 0 as Any,
                                        "imageurl": imageUrl?.absoluteString ?? "" as Any,
                                        "videourl": videoUrl?.absoluteString ?? "" as Any
                                    ]
                                    // Save post.
                                    postNode.updateChildValues(values, withCompletionBlock: { (error: Error?, database: FIRDatabaseReference) in
                                        if error == nil {
                                            postNode.observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
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
