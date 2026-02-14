#!/bin/bash
set -euo pipefail

CONFIG_PATH=/data/options.json

urlencode() {
  jq -rn --arg v "$1" '$v|@uri'
}

generate_totp() {
  local secret="${1//[[:space:]]/}"
  [[ -z "$secret" ]] && return 1
  oathtool --totp -b "$secret" 2>/dev/null
}

auth_token() {
  local api_base api_key username password otp otp_secret password_base64 password_for_auth payload otp_param code otp_value

  api_base=$(jq -r '.api_base' "$CONFIG_PATH")
  api_key=$(jq -r '.api_key' "$CONFIG_PATH")
  username=$(jq -r '.username' "$CONFIG_PATH")
  password=$(jq -r '.password' "$CONFIG_PATH")
  otp=$(jq -r '.otp // ""' "$CONFIG_PATH")
  otp_secret=$(jq -r '.otp_secret // ""' "$CONFIG_PATH")
  password_base64=$(jq -r '.password_base64 // false' "$CONFIG_PATH")

  password_for_auth="$password"
  if [[ "$password_base64" == "true" ]]; then
    password_for_auth=$(printf '%s' "$password" | base64 | tr -d '\n')
  fi

  otp_param=""
  otp_value="$otp"
  if [[ -z "$otp_value" ]] && [[ -n "$otp_secret" ]]; then
    otp_value="$(generate_totp "$otp_secret" || true)"
  fi
  if [[ -n "$otp_value" ]]; then
    otp_param="&otp=$(urlencode "$otp_value")"
  fi

  payload="grant_type=password&username=$(urlencode "$username")&password=$(urlencode "$password_for_auth")${otp_param}"

  code=$(curl -sS -o /tmp/aruba_auth_body.json -w "%{http_code}" -X POST "${api_base%/}/auth/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Authorization-Key: ${api_key}" \
    --data "$payload" 2>/tmp/aruba_auth_err.log || true)

  if [[ "$code" != "200" ]]; then
    echo "auth token failed: HTTP ${code}; $(jq -r '.error_description // .error // .Message // .message // "auth failed"' /tmp/aruba_auth_body.json 2>/dev/null || cat /tmp/aruba_auth_err.log)" >&2
    return 1
  fi

  jq -r '.access_token // empty' /tmp/aruba_auth_body.json
}

api_get_zone() {
  local token="$1"
  local zone="$2"
  local api_base encoded_zone
  api_base=$(jq -r '.api_base' "$CONFIG_PATH")
  encoded_zone=$(urlencode "$zone")

  curl -fsSL "${api_base%/}/api/domains/dns/${encoded_zone}/details" \
    -H "Authorization: ${token}"
}

api_post_record() {
  local token="$1"
  local payload="$2"
  local api_base
  api_base=$(jq -r '.api_base' "$CONFIG_PATH")

  curl -fsSL -X POST "${api_base%/}/api/domains/dns/record" \
    -H "Content-Type: application/json" \
    -H "Authorization: ${token}" \
    --data "$payload"
}

api_delete_record() {
  local token="$1"
  local id_record="$2"
  local api_base
  api_base=$(jq -r '.api_base' "$CONFIG_PATH")

  curl -fsSL -X DELETE "${api_base%/}/api/domains/dns/record/${id_record}" \
    -H "Authorization: ${token}"
}

domain_to_zone() {
  local domain="$1"
  local normalized="${domain%.}"
  local best=""
  local candidate

  while IFS= read -r candidate; do
    [[ -z "$candidate" || "$candidate" == "null" ]] && continue
    candidate="${candidate%.}"

    if [[ "$normalized" == "$candidate" || "$normalized" == *."$candidate" ]]; then
      if [[ ${#candidate} -gt ${#best} ]]; then
        best="$candidate"
      fi
    fi
  done < <(jq -r '[.records[].zone, (.lets_encrypt.zones[]?)] | flatten | unique[]?' "$CONFIG_PATH")

  echo "$best"
}

deploy_challenge() {
  local domain="$1" _token_filename="$2" token_value="$3"
  local token domain_no_wildcard zone fqdn zone_data zone_id payload wait_seconds existing_same

  domain_no_wildcard="${domain#*.}"
  if [[ "$domain" != \*.* ]]; then
    domain_no_wildcard="${domain}"
  fi
  domain_no_wildcard="${domain_no_wildcard%.}"

  zone=$(domain_to_zone "$domain_no_wildcard")
  if [[ -z "$zone" ]]; then
    echo "Cannot resolve zone for domain ${domain_no_wildcard} from records/zones config" >&2
    return 1
  fi

  fqdn="_acme-challenge.${domain_no_wildcard}"
  token=$(auth_token)

  zone_data=$(api_get_zone "$token" "$zone")
  zone_id=$(echo "$zone_data" | jq -r '.Id // empty')
  if [[ -z "$zone_id" ]]; then
    echo "Cannot resolve zone id for ${zone}" >&2
    return 1
  fi

  existing_same=$(echo "$zone_data" | jq -r \
    --arg n "${fqdn,,}" \
    --arg c "$token_value" \
    '[.Records[]? | select((.Name // "" | ascii_downcase | sub("\\.$";"")) == ($n | sub("\\.$";"")) and ((.Type // "" | ascii_downcase) == "txt") and ((.Content // "") == $c))] | length')
  if [[ "$existing_same" -gt 0 ]]; then
    return 0
  fi

  payload=$(jq -nc \
    --argjson idDomain "$zone_id" \
    --arg typeVal "tXT" \
    --arg name "$fqdn" \
    --arg content "$token_value" \
    '{IdDomain: $idDomain, Type: $typeVal, Name: $name, Content: $content}')

  api_post_record "$token" "$payload" >/dev/null

  wait_seconds=$(jq -r '.lets_encrypt.propagation_seconds // 120' "$CONFIG_PATH")
  sleep "$wait_seconds"
}

clean_challenge() {
  local domain="$1" _token_filename="$2" token_value="$3"
  local token domain_no_wildcard zone fqdn zone_data ids id

  domain_no_wildcard="${domain#*.}"
  if [[ "$domain" != \*.* ]]; then
    domain_no_wildcard="${domain}"
  fi
  domain_no_wildcard="${domain_no_wildcard%.}"

  zone=$(domain_to_zone "$domain_no_wildcard")
  [[ -z "$zone" ]] && return 0

  fqdn="_acme-challenge.${domain_no_wildcard}"
  token=$(auth_token)

  zone_data=$(api_get_zone "$token" "$zone")
  ids=$(echo "$zone_data" | jq -r \
    --arg n "${fqdn,,}" \
    --arg c "$token_value" \
    '[.Records[]? | select((.Name // "" | ascii_downcase | sub("\\.$";"")) == ($n | sub("\\.$";"")) and ((.Type // "" | ascii_downcase) == "txt") and ((.Content // "") == $c)) | .Id] | .[]?')

  while IFS= read -r id; do
    [[ -z "$id" ]] && continue
    api_delete_record "$token" "$id" >/dev/null || true
  done <<< "$ids"
}

deploy_cert() {
  local _domain="$1" keyfile="$2" _certfile="$3" fullchainfile="$4" _chainfile="$5" _timestamp="$6"
  local target_cert target_key

  target_cert=$(jq -r '.lets_encrypt.certfile' "$CONFIG_PATH")
  target_key=$(jq -r '.lets_encrypt.keyfile' "$CONFIG_PATH")

  cp -f "$fullchainfile" "/ssl/${target_cert}"
  cp -f "$keyfile" "/ssl/${target_key}"
}

HANDLER="$1"; shift || true
if [[ "$HANDLER" =~ ^(deploy_challenge|clean_challenge|deploy_cert)$ ]]; then
  "$HANDLER" "$@"
fi
