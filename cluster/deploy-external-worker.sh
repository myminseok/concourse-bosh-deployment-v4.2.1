bosh -e d deploy -d concourse-worker external-worker.yml \
  -l ../versions.yml \
  -v external_worker_network_name=deployment-network \
  -v worker_vm_type=medium.disk \
  -v instances=1 \
  -v azs=[az2] \
  -v deployment_name=concourse-worker \
  -v tsa_host=10.10.10.210 \
  -v worker_tags=[pcf] \
  -l ./deploy-external-worker-secret.yml
