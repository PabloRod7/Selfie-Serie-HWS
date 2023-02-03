//
//  ViewController.swift
//  Project25
//
//  Created by Pablo Rodrigues on 23/01/2023.
//
import MultipeerConnectivity
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate,MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    
    
    var images = [UIImage]()
    var peersText: String?
    var peerID: MCPeerID?
    var mcSession: MCSession?
    
    var advertiser: MCNearbyServiceAdvertiser!
    //    Challenge 3
    var leftBarButtonItems: [UIBarButtonItem]?
    var rightBarButtonItems: [UIBarButtonItem]?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Selfie share"
        
        let sendMessage = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(sendMessagePromt))
        let buttonPeers = UIBarButtonItem(title: "peers", style: .plain, target: self, action: #selector(numConnectedPeer))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPromt))
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPhotos))
        //       challenge 3
        navigationItem.leftBarButtonItems = [addButton, buttonPeers]
        
        navigationItem.rightBarButtonItems = [cameraButton, sendMessage]
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID!, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peerID!, discoveryInfo: nil, serviceType: "hws-project25")
        
    }
   
    @objc func sendMessagePromt(){
        let ac = UIAlertController(title: "Message", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak self, weak ac] _ in
            if let text = ac?.textFields?[0].text {
                self?.sendMessage(text)
            }
        }))
        present(ac, animated: true)
    }
    
    func sendMessage(_ text: String) {
           let data = Data(text.utf8)
           sendData(data)
       }
    func sendData(_ data: Data) {
            // send data to peers
            // is there an active session?
            guard let mcSession = mcSession else { return }
            // are there any peers to send to?
            if mcSession.connectedPeers.count > 0 {
                do {
                    // asynchronous method
                    try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
                }
                catch {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }


    

    @objc func importPhotos(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(100) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        return cell
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        
        images.insert(image, at: 0)
        collectionView.reloadData()
        
        guard let mcSession = mcSession else {return}
        if mcSession.connectedPeers.count > 0 {
            if let imageData = image.pngData() {
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch {
                    let ac = UIAlertController(title: "Send Error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                }
            }
        }
    }
    
    @objc func showConnectionPromt(){
        let ac = UIAlertController(title: "connect Others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session!", style: .default, handler: startSession))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default,handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func startSession(action: UIAlertAction) {
        advertiser = MCNearbyServiceAdvertiser(peer: peerID!, discoveryInfo: nil, serviceType: "hws-project25")
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        print("working")
        
    }
    
    func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else {return}
        
       
        let browser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        browser.delegate = self
        present(browser, animated: true)
        print("searching")
        
        
    }
    @objc func numConnectedPeer (){
        let ac = UIAlertController(title: "Connected Devices", message: "\(peersText ?? " no Devices")", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "ok", style: .cancel))
        present(ac, animated: true)
        
        }
                                                           
                                                           
    
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
      
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
    
    
    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected :
            print("Connected to \(peerID.displayName)")
        case .connecting:
            print("Connecting to \(peerID.displayName)")
        case .notConnected:
            print("Not connected to \(peerID.displayName)")
//            Challenge 1
            let ac = UIAlertController(title: "oops", message: "Device is disconnected", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
        @unknown default:
            print("unkwown state recieved: \(peerID.displayName)")
        }
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            }  else {
                let text = String(decoding: data, as: UTF8.self)
                let ac = UIAlertController(title: "Message received", message: "\n\(text)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(ac, animated: true)
                            
            }
        }
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        peersText = "\(peerID.displayName)"

        let ac = UIAlertController(title: title, message: "\(peerID.displayName) wants to connect", preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "Allow", style: .default, handler: { [weak self] _ in
            invitationHandler(true, self?.mcSession)
        }))

        ac.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: { _ in
            invitationHandler(false, nil)
        }))

        present(ac, animated: true)
    }

}

