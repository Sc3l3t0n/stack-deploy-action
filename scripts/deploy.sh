#!/usr/bin/env bash
set -ex

mkdir -p ~/.ssh
chmod 0700 ~/.ssh

ssh-keyscan -p "${INPUT_PORT}" -H "${INPUT_HOST}" >> ~/.ssh/known_hosts
ssh-keygen -q -f ~/.ssh/id_rsa -N "" -C "docker-stack-deploy-action"

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

sshpass -p "${INPUT_PASS}" \
    ssh-copy-id -p "${INPUT_PORT}" -i ~/.ssh/id_rsa \
        "${INPUT_USER}@${INPUT_HOST}"

ssh -p "${INPUT_PORT}" "${INPUT_USER}@${INPUT_HOST}" docker info

docker context create remote --docker "host=ssh://${INPUT_USER}@${INPUT_HOST}:${INPUT_PORT}"
docker context ls
docker context use remote
docker stack deploy -c "${INPUT_FILE}" "${INPUT_NAME}"

ssh -p "${INPUT_PORT}" "${INPUT_USER}@${INPUT_HOST}" \
    "sed -i '/docker-stack-deploy-action/d' ~/.ssh/authorized_keys"
