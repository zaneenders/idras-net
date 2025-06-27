import Kafka
import Logging
import ServiceLifecycle

import class Foundation.ProcessInfo

@main
struct Consumer {
  public static func main() async {
    let logger = {
      var _logger = Logger(label: "IDK")
      _logger.logLevel = .trace
      return _logger
    }()
    do {
      let brokerAddress = KafkaConfiguration.BrokerAddress(host: "localhost", port: 9092)
      let configuration = KafkaConsumerConfiguration(
        consumptionStrategy: .partition(
          KafkaPartition(rawValue: 0),
          topic: "topic-name"
        ),
        bootstrapBrokerAddresses: [brokerAddress]
      )

      let consumer = try KafkaConsumer(
        configuration: configuration,
        logger: logger
      )

      await withThrowingTaskGroup(of: Void.self) { group in

        // Run Task
        group.addTask {
          let serviceGroup = ServiceGroup(
            services: [consumer],
            logger: logger
          )
          try await serviceGroup.run()
        }

        // Task receiving messages
        group.addTask {
          for try await message in consumer.messages {
            print(String(buffer: message.value))
          }
        }
      }
    } catch {
      print(error)
    }
  }
}
