#https://github.com/cloudfoundry-incubator/credhub-cli/releases
#https://github.com/pivotal-cf/pcf-pipelines/tree/master/docs/samples/colocated-credhub-ops
#https://github.com/pivotal-cf/pcf-pipelines/blob/master/docs/samples/concourse-with-credhub.yml
#https://github.com/pivotal-cf/pcf-pipelines/blob/master/docs/credhub-integration.md
export concourse_elb=concourse.aws.com
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
  -o operations/add-credhub-to-atcs.yml \
  -o operations/static-db.yml \
  --var network_name=private \
  --var external_host=$concourse_elb \
  --var external_url=https://$concourse_elb \
  --var web_vm_type=default \
  --var db_vm_type=default \
  --var db_persistent_disk_type=10GB \
  --var worker_vm_type=default \
  --var web_instances=1 \
  --var worker_instances=1 \
  --var deployment_name=concourse \
  --var web_network_name=private \
  --var web_network_vm_extension=lb \
  --var local_user.username=admin \
  --var local_user.password=PASSWORD \
  --var atc_basic_auth.username=admin \
  --var atc_basic_auth.password=PASSWORD \
  --var external_lb_common_name=$concourse_elb \
  --var concourse_host=$concourse_elb \
  --var db_ip=10.0.31.190