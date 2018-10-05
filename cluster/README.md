# Cluster Concourse deployment

##  create uaac client 
https://docs.cloudfoundry.org/uaa/uaa-user-management.html

```
$ uaac target https://10.0.0.6:8443 --skip-ssl-validation
$ uaac token client get uaa_admin -s <password> => password는 bbl > vars/director_vars_store.yaml참조

사용자 추가시 권한 참조: https://github.com/pivotal-cf/pcf-pipelines/blob/master/docs/credhub-integration.md#uaa-client-setup

$ uaac client add concourse_to_credhub --authorities "credhub.read,credhub.write" --scope "" --authorized-grant-types "client_credentials"

bosh credhub test
jumpbox로 ssh 접속
download credhub cli: https://github.com/cloudfoundry-incubator/credhub-cli/releases
$ ./credhub api -s https://10.0.0.6:8844 --ca-cert ./credhub.ca --skip-tls-validation
$ ./credhub login --client-name=concourse_to_credhub --client-secret=xxxxxx
   => credhub인증정보는 bbl > vars/director_vars_store.yaml참조
$ ./credhub set -n /test -t value
$ ./credhub get -n /test

```

## concourse에서 bosh-credhub를 바라보게 작업하기
https://github.com/pivotal-cf/pcf-pipelines/blob/master/docs/credhub-integration.md


```
이 파일의 스펙은 https://github.com/concourse/concourse-bosh-release/blob/master/jobs/atc/spec 참조

operations/credhub.yml 

- type: replace
  path: /instance_groups/name=web/jobs/name=atc/properties/credhub?
  value:
    url: ((credhub_url))
    client_id: ((credhub_client_id))
    client_secret: ((credhub_client_secret))
    tls:
      ca_cert:
        certificate: ((credhub_ca_cert))
      insecure_skip_verify: true

```

```
operations/static-db.yml 

- type: replace
  path: /instance_groups/name=db/networks/0/static_ips?
  value: [((db_ip))]

```


```
jobs:
- name: atc
  ...
   properties:
    ...
    credhub:
      url: https://<cred_hub_server_ip_or_fqdn>:<credhub_server_port>
      tls:
        ca_cert: <cred_hub_server_ca>
      client_id: <uaa_client_id_for_concourse>
      client_secret: <uaa_client_secret_for_concourse>
```



```
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
  -o operations/credhub.yml \
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
  --var local_user.username= \
  --var local_user.password= \
  --var atc_basic_auth.username=admin \
  --var atc_basic_auth.password=PASSWORD \
  --var external_lb_common_name=$concourse_elb \
  --var concourse_host=$concourse_elb \
  --var db_ip=10.0.31.190 \
  --var credhub_url=https://10.0.0.6:8844 \
  --var credhub_client_id=concourse_to_credhub \
  --var credhub_client_secret=PASSWORD \
  -l ./credhub_ca.ca

=> credhub_url는 bbl director-address
=> credhub_client_id, credhub_client_secret는 앞에서 추가한 사용자정보
=> credhub_ca.ca 파일 생성은
cd bbl
bosh int ./vars/director_vars_stores.yml --path /credhub_ca/certificate
위 명령으로 credhub인증서를 추출한 후 아래 포맷으로 credhub_ca.ca 파일에 저장.

credhub_ca_cert: |
----- BEGIN -----
xxxx
---- END -----
  ```

## concourse배포

 ```
bbl 설치 폴더로 이동

eval "$(bbl print-env)"

$ ./deploy-concourse.sh
 ```



