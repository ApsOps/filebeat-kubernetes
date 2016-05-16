# filebeat-kubernetes
Filebeat container, alternative to fluentd used to ship kubernetes cluster and pod logs

## Getting Started
This container is designed to be run in a pod in Kubernetes to ship logs to logstash for further processing.
You can provide following environment variables to customize it.

```
LOGSTASH_HOSTS="'example.com:4083','example.com:4084'"
LOG_LEVEL=info
```

Make sure you add a filter in your logstash configuration if you want to process the actual log lines.

```
filter {
  if [type] == "kube-logs" {
    mutate {
      rename => ["log", "message"]
    }
  }

    date {
      match => ["time", "ISO8601"]
      remove_field => ["time"]
    }
}
```

## Contributing
I plan to make this more modular and reliable.

Feel free to open issues and pull requests for bug fixes or features.

## Licence

This project is licensed under the MIT License. Refer [LICENSE](https://github.com/ApsOps/filebeat-kubernetes/blob/master/LICENSE) for details.

