unset CREDHUB_CA_CERT
unset CREDHUB_CLIENT
unset CREDHUB_PROXY
unset CREDHUB_SECRET
unset CREDHUB_SERVER

#export concourse_elb=https://xxxx:8844
credhub api --skip-tls-validation --ca-cert <(bosh int cluster-creds.yml --path /concourse-ca/ca) \
-s $concourse_elb 

PASS=$(bosh int cluster-creds.yml --path /uaa-users-admin)
#credhub login -u admin -p $PASS
credhub login --client-name=credhub-admin --client-secret=$PASS
unset PASS

