//
//  ViewController.swift
//  Simple Webinar
//
//  Created by RAMDHAN CHOUDHARY on 09/08/19.
//  Copyright © 2019 RDC. All rights reserved.
//

import UIKit
import OpenTok


class ViewController: UIViewController {

    //TODO : Signup and Login to https://tokbox.com/account
    //go to Project - Create New Project - OpenTokAPI - Follow the steps to get kApiKey, kSessionId and kToken
    
    
    // Replace with your OpenTok API key
    var kApiKey = "YOUR_API_KEY"
    // Replace with your generated session ID
    //var kSessionId = "d78c83b229e6a064f27570c7428314eb0c8207d0"
    var kSessionId = "YOUR_SESSION_ID"

    //1_MX40NjQwMTcwMn5-MTU2NTMzNzQ2MTQ3NH4wNWtLTTFXRmtrN0lWVEd1T3lqbmlRSG1-fg
    
    // Replace with your generated token
    var kToken = "YOUR_TOKEN"
    
    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        connectToAnOpenTokSession()
    }
    func connectToAnOpenTokSession() {
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)
        var error: OTError?
        session?.connect(withToken: kToken, error: &error)
        if error != nil {
            print(error!)
        }
    }

}

// MARK: - OTSessionDelegate callbacks
extension ViewController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("The client connected to the OpenTok session.")
        
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        guard let publisher = OTPublisher(delegate: self, settings: settings) else {
            return
        }
        
        var error: OTError?
        session.publish(publisher, error: &error)
        guard error == nil else {
            print(error!)
            return
        }
        
        guard let publisherView = publisher.view else {
            return
        }
        let screenBounds = UIScreen.main.bounds
        publisherView.frame = CGRect(x: screenBounds.width - 150 - 20, y: screenBounds.height - 150 - 20, width: 150, height: 150)
        view.addSubview(publisherView)
    }

    
    func sessionDidDisconnect(_ session: OTSession) {
        print("The client disconnected from the OpenTok session.")
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("The client failed to connect to the OpenTok session: \(error).")
    }
    
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("A stream was created in the session.")

        subscriber = OTSubscriber(stream: stream, delegate: self)
        guard let subscriber = subscriber else {
            return
        }
        
        var error: OTError?
        session.subscribe(subscriber, error: &error)
        guard error == nil else {
            print(error!)
            return
        }
        
        guard let subscriberView = subscriber.view else {
            return
        }
        subscriberView.frame = UIScreen.main.bounds
        view.insertSubview(subscriberView, at: 0)
    }

    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("A stream was destroyed in the session.")
    }
}

// MARK: - OTPublisherDelegate callbacks
extension ViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("The publisher failed: \(error)")
    }
}

// MARK: - OTSubscriberDelegate callbacks
extension ViewController: OTSubscriberDelegate {
    public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        print("The subscriber did connect to the stream.")
    }
    
    public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("The subscriber failed to connect to the stream.")
    }
}


