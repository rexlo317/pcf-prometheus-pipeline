#!/bin/bash

function login_to_director() {
	CREDS=${1}
	DIRECTOR_FOR_DEPLOYMENT=${2}

	if [[ ${DIRECTOR_FOR_DEPLOYMENT} == "external_bosh" ]]; then
		source "$CREDS/external_bosh.sh"
	elif [[ -f $CREDS/bosh2_commandline_credentials ]]; then
		source "$CREDS/bosh2_commandline_credentials"
	else
		export BOSH_CA_CERT=$(cat "$CREDS/bosh-ca.pem")
		export BOSH_ENVIRONMENT="$(cat "$CREDS/director_ip")"
		export BOSH_CLIENT=$(cat "$CREDS/bosh-username")
		export BOSH_CLIENT_SECRET=$(cat "$CREDS/bosh-pass")
	fi
}

function login_to_cf_uaa() {
	echo "Getting UAA credentials..."

	uaa_client=${1}
	uaa_secret=${2}
	system_domain=${3}

	uaac target https://uaa.${system_domain} --skip-ssl-validation
	uaac token client get ${uaa_client} -s ${uaa_secret}
}

function login_to_bosh_uaa() {
	echo "Getting BOSH director IP..."
	director_ip=${1}

	echo "Getting BOSH UAA creds..."
	uaa_login_password=${2}
	uaa_admin_password=${3}

	echo "Logging into BOSH UAA..."
	uaac target https://$director_ip:8443 --skip-ssl-validation
	uaac token owner get login -s $uaa_login_password<<EOF
admin
$uaa_admin_password
EOF
}