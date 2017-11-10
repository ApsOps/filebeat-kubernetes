# filebeat-kubernetes

[![Docker Pulls](https://img.shields.io/docker/pulls/apsops/filebeat-kubernetes.svg)](https://hub.docker.com/r/apsops/filebeat-kubernetes/)
[![](https://images.microbadger.com/badges/image/apsops/filebeat-kubernetes.svg)](https://microbadger.com/images/apsops/filebeat-kubernetes "")

Filebeat container, alternative to fluentd used to ship kubernetes cluster and pod logs

## Getting Started
This container is designed to be run in a pod in Kubernetes to ship logs to logstash for further processing.
You can provide following environment variables to customize it.

```bash
LOGSTASH_HOSTS=example.com:4083,example.com:4084
LOG_LEVEL=info  # log level for filebeat. Defaults to "error".
FILEBEAT_HOST=ip-a-b-c-d # custom "host" field. Refer following manifest to set it to k8s nodeName
CLUSTER_NAME=my_cluster # Kubernetes cluster name to identity if you have multiple clusters. Default value is "default".
```

The endpoints listed by `LOGSTASH_HOSTS` should be listening with the [Beats input plugin](https://www.elastic.co/guide/en/logstash/5.6/plugins-inputs-beats.html).

This should be run as a Kubernetes Daemonset (a pod on every node). Example manifest:

```yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: filebeat
  namespace: kube-system
  labels:
    app: filebeat
spec:
  template:
    metadata:
      labels:
        app: filebeat
      name: filebeat
    spec:
      containers:
      - name: filebeat
        image: apsops/filebeat-kubernetes:v0.4
        resources:
          limits:
            cpu: 50m
            memory: 50Mi
        env:
          - name: LOGSTASH_HOSTS
            value: myhost.com:5000
          - name: LOG_LEVEL
            value: info
          - name: CLUSTER_NAME
            value: my_cluster
          - name: FILEBEAT_HOST
            valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
        volumeMounts:
        - name: varlog
          mountPath: /var/log/containers
        - name: varlogpods
          mountPath: /var/log/pods
          readOnly: true
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      terminationGracePeriodSeconds: 30
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      volumes:
      - name: varlog
        hostPath:
          path: /var/log/containers
      - name: varlogpods
        hostPath:
          path: /var/log/pods
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

Filebeat parses docker json logs and applies multiline filter on the node before pushing logs to logstash.

Make sure you add a filter in your logstash configuration if you want to process the actual log lines.

```ruby
filter {
  if [type] == "kube-logs" {

    mutate {
      rename => ["log", "message"]
    }

    date {
      match => ["time", "ISO8601"]
      remove_field => ["time"]
    }

    grok {
        match => { "source" => "/var/log/containers/%{DATA:pod_name}_%{DATA:namespace}_%{GREEDYDATA:container_name}-%{DATA:container_id}.log" }
        remove_field => ["source"]
    }
  }
}
```

This grok pattern would add the fields - `pod_name`, `namespace`, `container_name` and `container id` to log entry in Elasticsearch.

## Contributing
I plan to make this more modular and reliable.

Feel free to open issues and pull requests for bug fixes or features.

## Licence

This project is licensed under the MIT License. Refer [LICENSE](https://github.com/ApsOps/filebeat-kubernetes/blob/master/LICENSE) for details.

