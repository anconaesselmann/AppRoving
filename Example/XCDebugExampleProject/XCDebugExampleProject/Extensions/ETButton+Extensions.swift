//  Created by Axel Ancona Esselmann on 11/13/23.
//

import EventTriggeredButton

extension ETButton {
    @MainActor
    func register(_ event: EventId) -> Self {
        register(eventId: event.uuid, manager: CustomEventManager.shared)
    }
}
