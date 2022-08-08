#!/urs/bin/env bash

git init ../gitlab/wp-project
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project remote add origin https://root:Net0logy@gitlab.uttuer.ru/root/wp-project.git
echo "copy files and take git push"
cp -rT ../gitlab/resources/01-init ../gitlab/wp-project
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project add .
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project commit -m 'init'
export GIT_SSL_NO_VERIFY=1
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project push -u origin master
echo "All done. Wait 1 minute before next CI/CD commit"
echo "Waiting commit 2"
sleep 60
