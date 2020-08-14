import AtomicModels
import Foundation
import QueueClient
import QueueModels
import RequestSender
import SocketModels
import Timer
import Types
import WorkerAlivenessModels

public final class EmceeService: Service {
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
    private let version: Version
    
    public init(
        queueSocketAddress: SocketAddress,
        version: Version
    ) {
        self.queueSocketAddress = queueSocketAddress
        self.version = version
    }
    
    public var id: String {
        queueSocketAddress.asString + version.value
    }
    
    public var name: String {
        "Emcee Qeueue Server \(queueSocketAddress.asString) \(version)"
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
}

public final class EmceeServiceWorker: ServiceWorker {
    private let workerId: WorkerId
    private let workerAliveness: WorkerAliveness
    
    public init(
        workerId: WorkerId,
        workerAliveness: WorkerAliveness
    ) {
        self.workerId = workerId
        self.workerAliveness = workerAliveness
    }
    
    public var id: String { workerId.value }
    public var name: String { workerId.value }
    
    public var states: [ServiceWorkerState] {
        [
            EmceeWorkerState(id: .isRegistered, name: "Registered", status: "\(workerAliveness.registered)"),
            EmceeWorkerState(id: .isAlive, name: "Alive", status: "\(workerAliveness.alive)"),
            EmceeWorkerState(id: .isEnabled, name: "Enabled", status: "\(workerAliveness.enabled)"),
        ]
    }
    
    public var actions: [ServiceWorkerAction] {
        var actions = [ServiceWorkerAction]()
        
        if !workerAliveness.registered || !workerAliveness.silent {
            actions.append(EmceeWorkerAction(id: .kickstartWorker, name: "Kickstart \(workerId)"))
        }
        if workerAliveness.enabled {
            actions.append(EmceeWorkerAction(id: .disableWorker, name: "Disable \(workerId)"))
        } else {
            actions.append(EmceeWorkerAction(id: .enableWorker, name: "Enable \(workerId)"))
        }
        
        return actions
    }
}

final class EmceeWorkerState: ServiceWorkerState {
    public let id: String
    public let name: String
    public let status: String
    
    init(
        id: EmceeService.StateId,
        name: String,
        status: String
    ) {
        self.id = id.rawValue
        self.name = name
        self.status = status
    }
}

final class EmceeWorkerAction: ServiceWorkerAction {
    let id: String
    let name: String
    
    init(
        id: EmceeService.ActionId,
        name: String
    ) {
        self.id = id.rawValue
        self.name = name
    }
}
