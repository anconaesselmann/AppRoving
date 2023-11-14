//  Created by Axel Ancona Esselmann on 11/13/23.
//

import Foundation
import Combine
import EventTriggeredButton

class CustomEventManager: ObservableObject, EventManager {

    static let shared = CustomEventManager()
    
    var events = PassthroughSubject<Event, Never>()
    
    func eventFired(_ event: Event) {
        events.send(event)
    }
}
