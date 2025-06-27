import Kafka
import Logging
import ServiceLifecycle

import class Foundation.ProcessInfo

@main
struct Producer {
  public static func main() async {
    do {
      let logger = {
        var _logger = Logger(label: "IDK")
        _logger.logLevel = .trace
        return _logger
      }()

      let kafkaHost = ProcessInfo.processInfo.environment["KAFKA_HOST"] ?? "localhost"
      let kafkaPort: Int = Int(ProcessInfo.processInfo.environment["KAFKA_PORT"] ?? "9092")!
      logger.debug("\(kafkaHost):\(kafkaPort)")
      let brokerAddress = KafkaConfiguration.BrokerAddress(host: kafkaHost, port: kafkaPort)
      let configuration = KafkaProducerConfiguration(bootstrapBrokerAddresses: [brokerAddress])

      let (producer, events) = try KafkaProducer.makeProducerWithEvents(
        configuration: configuration,
        logger: logger
      )

      await withThrowingTaskGroup(of: Void.self) { group in

        // Run Task
        group.addTask {
          let serviceGroup = ServiceGroup(
            services: [producer],
            logger: logger)
          try await serviceGroup.run()
        }

        // Task sending message and receiving events
        group.addTask {
          var count = 0
          while !Task.isCancelled {
            // What do I do with message ID?
            _ = try producer.send(
              KafkaProducerMessage(
                topic: "topic-name",
                value: "Hello, World! \(count)"
              )
            )
            count += 1
            try? await Task.sleep(for: .milliseconds(1))
          }

          for await event in events {
            switch event {
            case .deliveryReports(let deliveryReports):
              print(deliveryReports)
            // Check what messages the delivery reports belong to
            default:
              break  // Ignore any other events
            }
          }
        }
      }
    } catch {
      print(error)
    }
  }
}
