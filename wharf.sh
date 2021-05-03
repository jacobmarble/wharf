#! /bin/sh

set -e

CONFIG_PATH="$1"

if [ ! -d "$CONFIG_PATH" ]; then
	echo "invalid config path"
	exit 1
fi

cd "$CONFIG_PATH"
CONFIG_PATH=$(pwd)

ls * | while read REPO_CONFIG; do
	LOCAL_PATH=$(sed -n '1p' ${REPO_CONFIG})
	LOCAL_BRANCH=$(sed -n '2p' ${REPO_CONFIG})
	LOCAL_DOCKERFILE=$(sed -n '3p' ${REPO_CONFIG})
	LOCAL_IMAGE=$(sed -n '4p' ${REPO_CONFIG})
	LOCAL_HASH=$(sed -n '5p' ${REPO_CONFIG})

	echo $LOCAL_PATH
	echo $LOCAL_BRANCH
	echo $LOCAL_DOCKERFILE
	echo $LOCAL_HASH

	cd "$LOCAL_PATH"
	git checkout "$LOCAL_BRANCH"
	git pull --quiet
	REMOTE_HASH=$(git log -n 1 --pretty=format:%h)

	if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
		break
	fi

	docker build . --file "$LOCAL_DOCKERFILE" --tag ${LOCAL_IMAGE}:${REMOTE_HASH}
	docker tag ${LOCAL_IMAGE}:${REMOTE_HASH} ${LOCAL_IMAGE}:latest
	docker push ${LOCAL_IMAGE}:${REMOTE_HASH}
	docker push ${LOCAL_IMAGE}:latest

	cd "$CONFIG_PATH"
	sed -i "5s/.*/$REMOTE_HASH/" "$REPO_CONFIG"
done

