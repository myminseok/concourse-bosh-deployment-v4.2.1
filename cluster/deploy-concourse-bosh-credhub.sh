#https://github.com/cloudfoundry-incubator/credhub-cli/releases
#https://github.com/pivotal-cf/pcf-pipelines/tree/master/docs/samples/colocated-credhub-ops
#https://github.com/pivotal-cf/pcf-pipelines/blob/master/docs/samples/concourse-with-credhub.yml
#https://github.com/pivotal-cf/pcf-pipelines/blob/master/docs/credhub-integration.md

export concourse_elb=concoursxxx.amazonaws.com



bosh deploy -n --no-redact -d concourse concourse.yml \
  -l ../versions.yml \
  --vars-store cluster-creds.yml \
  -o operations/basic-auth.yml \
  -o operations/privileged-http.yml \
  -o operations/privileged-https.yml \
  -o operations/tls.yml \
  -o operations/tls-vars.yml \
  -o operations/web-network-extension.yml \
  -o operations/scale.yml \
  -o operations/static-db.yml \
  -o operations/worker-ephemeral-disk.yml \
  -o operations/credhub.yml \
  --var network_name=private \
  --var external_host=$concourse_elb \
  --var external_url=https://$concourse_elb \
  --var web_vm_type=default \
  --var db_vm_type=default \
  --var db_persistent_disk_type=10GB \
  --var worker_ephemeral_disk=100GB_ephemeral_disk \
  --var worker_vm_type=default \
  --var web_instances=1 \
  --var worker_instances=1 \
  --var deployment_name=concourse \
  --var web_network_name=private \
  --var web_network_vm_extension=lb \
  --var local_user.username= \
  --var local_user.password= \
  --var atc_basic_auth.username= \
  --var atc_basic_auth.password= \
  --var external_lb_common_name=$concourse_elb \
  --var concourse_host=$concourse_elb \
  --var db_ip=10.0.31.190 \
  --var credhub_url=https://10.0.0.6:8844 \
  --var credhub_client_id=concourse_to_credhub \
  --var credhub_client_secret=  \
  -l ./credhub_ca.ca
