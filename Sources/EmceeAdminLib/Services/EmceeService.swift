import AtomicModels
import Foundation
import QueueClient
import QueueModels
import RequestSender
import Services
import SocketModels
import Timer
import Types
import WorkerAlivenessModels

public final class EmceeService: Service, CustomStringConvertible {
    enum ActionId: String {
        case kickstartWorker
        case enableWorker
        case disableWorker
    }
    
    enum StateId: String {
        case isRegistered
        case isAlive
        case isEnabled
    }
    
    private let workerAlivenesses = AtomicValue([WorkerId: WorkerAliveness]())
    private let callbackQueue = DispatchQueue(label: "EmceeService.callbackQueue")
    private let queueSocketAddress: SocketAddress
    private let updateTimer = DispatchBasedTimer(repeating: .seconds(5), leeway: .seconds(1))
    private let emceeVersion: Version
    
    public init(
        queueSocketAddress: SocketAddress,
        version: Version
    ) {
        self.queueSocketAddress = queueSocketAddress
        self.emceeVersion = version
    }
    
    public var name: String {
        "Emcee Queue"
    }
    
    public var socketAddress: SocketAddress {
        queueSocketAddress
    }
    
    public var version: String {
        emceeVersion.value
    }
    
    public var serviceWorkers: [ServiceWorker] {
        workerAlivenesses.currentValue().map {
            EmceeServiceWorker(workerId: $0.key, workerAliveness: $0.value)
        }
    }
    
    public func updateWorkers() {
        let group = DispatchGroup()
        
        group.enter()
        
        let statusFetcher = WorkerStatusFetcherImpl(
            requestSender: RequestSenderImpl(
                urlSession: .shared,
                queueServerAddress: queueSocketAddress
            )
        )
        statusFetcher.fetch(callbackQueue: callbackQueue) { [weak self] (response: Either<[WorkerId: WorkerAliveness], Error>) in
            defer { group.leave() }
            
            guard let self = self else { return }
            guard let aliveness = try? response.dematerialize() else { return }
            self.workerAlivenesses.set(aliveness)
        }
        
        group.wait()
    }
    
    public var description: String { "<\(type(of: self)) \(queueSocketAddress) \(emceeVersion.value) \(serviceWorkers)>" }
    
    public func execute(action: ServiceWorkerAction, serviceWorker: ServiceWorker) {
        guard let serviceWorker = serviceWorker as? EmceeServiceWorker else { return }
        guard let action = action as? EmceeWorkerAction else { return }
        
        let requestSenderProvider = DefaultRequestSenderProvider()
        let requestSender = requestSenderProvider.requestSender(socketAddress: queueSocketAddress)
        
        let group = DispatchGroup()
        
        group.enter()
        switch action.actionId {
        case .disableWorker:
            WorkerDisablerImpl(requestSender: requestSender).disableWorker(workerId: serviceWorker.workerId, callbackQueue: .global(), completion: { _ in group.leave() })
        case .enableWorker:
            WorkerEnablerImpl(requestSender: requestSender).enableWorker(workerId: serviceWorker.workerId, callbackQueue: .global(), completion: { _ in group.leave() })
        case .kickstartWorker:
            WorkerKickstarterImpl(requestSender: requestSender).kickstart(workerId: serviceWorker.workerId, callbackQueue: .global(), completion: { _ in group.leave() })
        }
        group.wait()
    }
}

final class EmceeServiceWorker: ServiceWorker, CustomStringConvertible {
    let workerId: WorkerId
    let workerAliveness: WorkerAliveness
    
    init(
        workerId: WorkerId,
        workerAliveness: WorkerAliveness
    ) {
        self.workerId = workerId
        self.workerAliveness = workerAliveness
    }
    
    var id: String { workerId.value }
    var name: String { workerId.value }
    
    var states: [ServiceWorkerState] {
        [
            EmceeWorkerState(id: .isRegistered, name: "Registered", status: workerAliveness.registered ? "Registered" : "Never Started", isPositive: workerAliveness.registered),
            EmceeWorkerState(id: .isAlive, name: "Alive", status: !workerAliveness.silent ? "Alive" : "Silent", isPositive: !workerAliveness.silent),
            EmceeWorkerState(id: .isEnabled, name: "Enabled", status: !workerAliveness.disabled ? "Enabled" : "Disabled", isPositive: !workerAliveness.disabled),
        ]
    }
    
    var actions: [ServiceWorkerAction] {
        var actions = [ServiceWorkerAction]()
        
        if !workerAliveness.registered || workerAliveness.silent {
            actions.append(EmceeWorkerAction(actionId: .kickstartWorker, name: "Kickstart \(workerId.value)", workerId: workerId))
        }
        if !workerAliveness.disabled {
            actions.append(EmceeWorkerAction(actionId: .disableWorker, name: "Disable \(workerId.value)", workerId: workerId))
        } else {
            actions.append(EmceeWorkerAction(actionId: .enableWorker, name: "Enable \(workerId.value)", workerId: workerId))
        }
        
        return actions
    }
    
    var description: String { "<\(type(of: self)) \(workerId.value) states=\(states) actions=\(actions)>" }
}

final class EmceeWorkerState: ServiceWorkerState, CustomStringConvertible {
    public let id: String
    public let name: String
    public let status: String
    public let isPositive: Bool
    
    init(
        id: EmceeService.StateId,
        name: String,
        status: String,
        isPositive: Bool
    ) {
        self.id = id.rawValue
        self.name = name
        self.status = status
        self.isPositive = isPositive
    }
    
    var description: String { "<\(id) \(status)>" }
}

final class EmceeWorkerAction: ServiceWorkerAction, CustomStringConvertible {
    let actionId: EmceeService.ActionId
    let name: String
    let workerId: WorkerId
    
    init(
        actionId: EmceeService.ActionId,
        name: String,
        workerId: WorkerId
    ) {
        self.actionId = actionId
        self.name = name
        self.workerId = workerId
    }
    
    var id: String { actionId.rawValue }
    var description: String { id }
}
