#!/urs/bin/env bash
echo "Update local project in directory ../gitlab/wp-project"
cp ../gitlab/resources/02-update/* ../gitlab/wp-project/
echo "Add, commit, tag and push"
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project add .
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project commit -m 'update wordpress'
export GIT_SSL_NO_VERIFY=1
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project tag -a v1.0 -m 'version 1.0'
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project push
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project push --tags
echo "Gitlab-runner is working..."
sleep 20
