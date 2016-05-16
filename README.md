# filebeat-kubernetes
Filebeat container, alternative to fluentd used to ship kubernetes cluster and pod logs

## Getting Started
This container is designed to be run in a pod in Kubernetes to ship logs to logstash for further processing.
You can provide following environment variables to customize it.

```
LOGSTASH_HOSTS="'example.com:4083','example.com:4084'"
LOG_LEVEL=info
```

You should run a Kubernetes pod on every node. Example pod manifest:

```
apiVersion: v1
kind: Pod
metadata:
  name: filebeat
  namespace: kube-system
  labels:
    k8s-app: filebeat
spec:
  containers:
  - name: filebeat
    image: apsops/filebeat-kubernetes:v0.1
    resources:
      limits:
        memory: 200Mi
      requests:
        cpu: 100m
        memory: 200Mi
    env:
      - name: LOGSTASH_HOSTS
        value: "'myhost.com:5000'"
      - name: LOG_LEVEL
        value: info
    volumeMounts:
    - name: varlog
      mountPath: /var/log/containers
    - name: varlibdockercontainers
      mountPath: /var/lib/docker/containers
      readOnly: true
  terminationGracePeriodSeconds: 30
  volumes:
  - name: varlog
    hostPath:
      path: /var/log/containers
  - name: varlibdockercontainers
    hostPath:
      path: /var/lib/docker/containers
```

Make sure you add a filter in your logstash configuration if you want to process the actual log lines.

```
filter {
  if [type] == "kube-logs" {
    json {
      source => "message"
    }

    mutate {
      rename => ["log", "message"]
    }

    date {
      match => ["time", "ISO8601"]
      remove_field => ["time"]
    }
  }
}
```

## Contributing
I plan to make this more modular and reliable.

Feel free to open issues and pull requests for bug fixes or features.

## Licence

This project is licensed under the MIT License. Refer [LICENSE](https://github.com/ApsOps/filebeat-kubernetes/blob/master/LICENSE) for details.

