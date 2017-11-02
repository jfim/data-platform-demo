kubectl port-forward -n data-platform sparkmagic-0 10000:8888 &
kubectl port-forward -n data-platform wherehows-frontend-0 10001:9000 &
kubectl port-forward -n data-platform wherehows-elasticsearch-0 10002:9200 &
kubectl port-forward -n data-platform drelephant-0 10003:8080 &
kubectl port-forward -n data-platform azkaban-0 10004:8081 &
kubectl port-forward -n data-platform pinot-controller-0 10005:9000 &
