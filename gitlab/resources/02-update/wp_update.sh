#!/usr/bin/env bash
cd /var/www/wordpress
/usr/local/bin/wp post create --post_title='Этот пост из GitLab' \
--post_content='Этот пост пришёл из GitLab' --post_status=publish
