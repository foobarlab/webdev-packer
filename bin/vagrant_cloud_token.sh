#!/bin/bash -ue
# vim: ts=4 sw=4 et

source "${BUILD_LIB_UTILS:-./bin/lib/utils.sh}" "$*"

require_commands curl jq

if [ -z "${VAGRANT_CLOUD_TOKEN:-}" ]; then
    if [ -f "$BUILD_FILE_VAGRANT_TOKEN" ]; then
        step "Loading previously stored auth token: '$BUILD_FILE_VAGRANT_TOKEN'"
        VAGRANT_CLOUD_TOKEN=`cat ${BUILD_FILE_VAGRANT_TOKEN}`
    else
        warn "No auth token found."
        echo
        note "We will do the upload via API on the behalf of your Vagrant Cloud"
        note "account. For this we will use an auth token. Please keep this token"
        note "in a secure place or delete it after upload."
        echo
        echo "Please enter your Vagrant Cloud credentials to proceed:"
        echo
        echo -n "Username: "
        read auth_username
        echo -n "Password: "
        read -s auth_password
        echo
        echo

        # Request auth token
        upload_auth_request=$( \
        curl -sS \
          --header "Content-Type: application/json" \
          https://app.vagrantup.com/api/v1/authenticate \
          --data '{"token": {"description": "Login from cURL"},"user": {"login": "'$auth_username'","password": "'$auth_password'"}}' \
        )

        upload_auth_request_success=`echo $upload_auth_request | jq '.success'`
        if [ $upload_auth_request_success == 'false' ]; then
            error "Request for auth token failed."
            info "Response from API:"
            echo $upload_auth_request | jq
            result "Please consult the error above and try again."
            exit 1
        fi

        VAGRANT_CLOUD_TOKEN=`echo $upload_auth_request | jq '.token' | tr -d '"'`

        result "OK, we got authorized."

        read -p "Do you want to store the auth token for future use (y/N)? " choice
        case "$choice" in
          y|Y ) step "Storing auth token ..."
                echo "$VAGRANT_CLOUD_TOKEN" > "$BUILD_FILE_VAGRANT_TOKEN"
                chmod 600 "$BUILD_FILE_VAGRANT_TOKEN"
                ;;
          * ) step "Not storing auth token."
              ;;
        esac

    fi
    export VAGRANT_CLOUD_TOKEN
else
    if_not_silent result "Reusing in-memory auth token."
fi
