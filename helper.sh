#!/usr/bin/env bash

# ===> COMMON SECTION START  ===>

# http://bash.cumulonim.biz/NullGlob.html
shopt -s nullglob
# -------------------------------
this_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
if [ -z "$this_folder" ]; then
  this_folder=$(dirname $(readlink -f $0))
fi
parent_folder=$(dirname "$this_folder")
# -------------------------------
debug(){
    local __msg="$1"
    echo " [DEBUG] `date` ... $__msg "
}

info(){
    local __msg="$1"
    echo " [INFO]  `date` ->>> $__msg "
}

warn(){
    local __msg="$1"
    echo " [WARN]  `date` *** $__msg "
}

err(){
    local __msg="$1"
    echo " [ERR]   `date` !!! $__msg "
}
# ---------- CONSTANTS ----------
export FILE_VARIABLES=${FILE_VARIABLES:-".variables"}
export FILE_LOCAL_VARIABLES=${FILE_LOCAL_VARIABLES:-".local_variables"}
export FILE_SECRETS=${FILE_SECRETS:-".secrets"}
export NAME="bashutils"
export INCLUDE_FILE=".${NAME}"
export TAR_NAME="${NAME}.tar.bz2"
# -------------------------------
if [ ! -f "$this_folder/$FILE_VARIABLES" ]; then
  warn "we DON'T have a $FILE_VARIABLES variables file - creating it"
  touch "$this_folder/$FILE_VARIABLES"
else
  info "loading variables from  $this_folder/$FILE_VARIABLES"
  . "$this_folder/$FILE_VARIABLES"
fi

if [ ! -f "$this_folder/$FILE_LOCAL_VARIABLES" ]; then
  warn "we DON'T have a $FILE_LOCAL_VARIABLES variables file - creating it"
  touch "$this_folder/$FILE_LOCAL_VARIABLES"
else
  info "loading local variables from  $this_folder/$FILE_LOCAL_VARIABLES"
  . "$this_folder/$FILE_LOCAL_VARIABLES"
fi

if [ ! -f "$this_folder/$FILE_SECRETS" ]; then
  warn "we DON'T have a $FILE_SECRETS secrets file - creating it"
  touch "$this_folder/$FILE_SECRETS"
else
  info "loading secrets from  $this_folder/$FILE_SECRETS"
  . "$this_folder/$FILE_SECRETS"
fi

# ---------- include bashutils ----------
. ${this_folder}/${INCLUDE_FILE}

# ---------- FUNCTIONS ----------

update_bashutils(){
  echo "[update_bashutils] ..."

  tar_file="${NAME}.tar.bz2"
  _pwd=`pwd`
  cd "$this_folder"

  curl -s https://api.github.com/repos/jtviegas/bashutils/releases/latest \
  | grep "browser_download_url.*${NAME}\.tar\.bz2" \
  | cut -d '"' -f 4 | wget -qi -
  tar xjpvf $tar_file
  if [ ! "$?" -eq "0" ] ; then echo "[update_bashutils] could not untar it" && cd "$_pwd" && return 1; fi
  rm $tar_file

  cd "$_pwd"
  echo "[update_bashutils] ...done."
}

# <=== COMMON SECTION END  <===
# -------------------------------------

# =======>    MAIN SECTION    =======>

# ---------- LOCAL CONSTANTS ----------


# ---------- LOCAL FUNCTIONS ----------

cdk_on()
{
  info "[cdk_on|in]"
  which node
  if [ "0" -ne "$?" ]; then
    err "[cdk_on] have to install node" && return 1
  fi
  sudo npm install -g aws-cdk
  cdk -h
  result=$?
  info "[cdk_on|out] => $result"
  return $result
}

commands() {
  cat <<EOM

  handy commands:

  cdk init app --language typescript  create new cdk app on typescript
  npm run build                       compile typescript to js
  npm run watch                       watch for changes and compile
  npm run test                        perform the jest unit tests
  cdk deploy                          deploy this stack to your default AWS account/region
  cdk diff                            compare deployed stack with current state
  cdk synth                           emits the synthesized CloudFormation template
  aws cloudformation delete-stack --stack-name CDKToolkit   delete to later recreate with bootstrap (see https://stackoverflow.com/questions/71280758/aws-cdk-bootstrap-itself-broken/71283964#71283964)
  cdk init app --language typescript
EOM
}

cdk_bootstrap()
{
  info "[cdk_bootstrap|in]"

  #aws cloudformation delete-stack --stack-name CDKToolkit
  cdk bootstrap
  result=$?
  info "[cdk_bootstrap|out] => $result"
  return $result
}

cdk_deploy()
{
  info "[cdk_deploy|in]"

  cdk deploy
  result=$?
  info "[cdk_deploy|out] => $result"
  return $result
}

cdk_destroy()
{
  info "[cdk_destroy|in]"

  cdk destroy
  result=$?
  info "[cdk_destroy|out] => $result"
  return $result
}

cdk_synth()
{
  info "[cdk_synth|in]"

  cdk synth
  result=$?
  info "[cdk_synth|out] => $result"
  return $result
}

# -------------------------------------
usage() {
  cat <<EOM
  usage:
  $(basename $0) { OPTION }
      options:
      - update_bashutils        : updates the include '.bashutils' file
      - commands                : prints handy cdk related commands
      - cdk_on                  : install aws cdk
      - cdk_bootstrap
      - cdk_synth
      - cdk_deploy
      - cdk_destroy
EOM
  exit 1
}

debug "1: $1 2: $2 3: $3 4: $4 5: $5 6: $6 7: $7 8: $8 9: $9"

case "$1" in
  package)
    package
    ;;
  update_bashutils)
    update_bashutils
    ;;
  commands)
    commands
    ;;
  cdk_on)
    cdk_on
    ;;
  cdk_bootstrap)
    cdk_bootstrap
    ;;
  cdk_synth)
    cdk_synth
    ;;
  cdk_deploy)
    cdk_deploy
    ;;
  cdk_destroy)
    cdk_destroy
    ;;
  *)
    usage
    ;;
esac