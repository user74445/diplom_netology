# Дипломный практикум в YandexCloud.
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
      * [Регистрация доменного имени](#регистрация-доменного-имени)
      * [Создание инфраструктуры](#создание-инфраструктуры)
          * Установка Nginx и LetsEncrypt
          * Установка кластера MySQL
          * Установка WordPress
          * Установка Gitlab CE, Gitlab Runner и настройка CI/CD
          * Установка Prometheus, Alert Manager, Node Exporter и Grafana

---
## Цели:
1. Зарегистрировать доменное имя (любое на ваш выбор в любой доменной зоне).
2. Подготовить инфраструктуру с помощью Terraform на базе облачного провайдера YandexCloud.
3. Настроить внешний Reverse Proxy на основе Nginx и LetsEncrypt.
4. Настроить кластер MySQL.
5. Установить WordPress.
6. Развернуть Gitlab CE и Gitlab Runner.
7. Настроить CI/CD для автоматического развёртывания приложения.
8. Настроить мониторинг инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana.

Полное описание задания можно посомтреть здесь [README.md](../README.md)

---
## Этапы выполнения:
## Регистрация доменного имени

- Зарегистрирован домен `uttuer.ru`
- Настроен хостинг DNS для домена в YandexCloud `ns1.yandexcloud.net` и `ns2.yandexcloud.net`


Создан S3 bucket в YC аккаунте.
![](pics/pic_1.png)

## Создание инфраструктуры
Структура файлов:
- `main.tf`      Настройки instance.
- `providers.tf` Содержит настройки для подклчюения к провайдеру.
- `variables.tf` Содержит переменные. acme_server - используемый для получения сертификатов LetsEncrypte. 
- `network.tf`   Содержит настройки сетей.
- `output.tf`    Выходное значение.
- `inventory.tf` Содержит описание подключение к хостам и записывает его в папку `ansible.
- `group_vars.tf`Описание переменных и запись в`/ansible/group_vars/all.yml`

```

Настройки S3 укзаны в variables.tf в секции backend S3 вида 

endpoint   = "storage.yandexcloud.net"
bucket     = <your-bucket-name>
region     = "ru-central1"
key        = "terraform.tfstate"
access_key = <your-access-key>
secret_key = <your-secret-key>
skip_region_validation      = true
skip_credentials_validation = true
```
-  DNS записи указаны в `dns.tf` и передаются в YandexCloud.

![](pics/pic_2.png)

-  Подключение к облаку происходит через `service account` с ключем `service_account_key_file = "key.json"`. Ключ убран из репозитория.

Развертывание инфраструктуры выполняется командой `terraform apply` из каталога `terraform` данного репозитория.

Запуск в среде stage:

```bash

$ terraform workspace new stage
$ terraform workspace select stage 
$ terraform plan
$ terraform apply
```
Инфраструктура раззвёрнута.

![](pics/pic_3.png)

![](pics/pic_4.png)

## Ansible.

 Версия `ansible [core 2.13.2]`. Роли находятся в каталоге `ansible\roles`. 
 - `ansible\inventory\stage.yml` находится inventory для playbook.
 - `ansible\site.yml` сам playbook
 
Все действия описаны в `ansible.tf`, запускается вместе с `terraform apply`. 

Команды для тестирования ролей.
 
ansible-playbook -i ../ansible/inventory/stage.yml -t squid ../ansible/site.yml"

ansible-playbook -i ../ansible/inventory/stage.yml -t preconfigure ../ansible/site.yml"

ansible-playbook -i ../ansible/inventory/stage.yml -t nginx ../ansible/site.yml"

ansible-playbook -i ../ansible/inventory/stage.yml -t mysql ../ansible/site.yml"

ansible-playbook -i ../ansible/inventory/stage.yml -t wordpress ../ansible/site.yml"

ansible-playbook -i ../ansible/inventory/stage.yml -t prometheus ../ansible/site.yml"

ansible-playbook -i ../ansible/inventory/stage.yml -t alertmanager ../ansible/site.yml"

ansible-playbook -i ../ansible/inventory/stage.yml -t grafana ../ansible/site.yml"

ansible-playbook -i ../ansible/inventory/stage.yml -t gitlab ../ansible/site.yml"

ansible-playbook -i ../ansible/inventory/stage.yml -t runner ../ansible/site.yml"

ansible-playbook -i ../ansible/inventory/stage.yml -t copy_ssh ../ansible/site.yml"

После завершения открывется страница с установленным Wordpress `https://www.uttuer.ru`

![](pics/pic_5.png)

## Gitlab и СICD

Имя пользоватля `root` пароль `gitlab_initial_root_password` находится здесь `group_vars\cvs`

![](pics/pic_06.png) 

В папке`gitlab\tf-scripts` есть два скрипта `gitlab_01.sh` и `gitlab_02.sh` Первый - для запуска коммита, второй - для обновление по tag. 

`gitlab_01.sh`
```
git init ../gitlab/wp-project
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project remote add origin https://root:Net0logy@gitlab.uttuer.ru/root/wp-project.git
echo "copy files and take git push"
cp -rT ../gitlab/resources/01-init ../gitlab/wp-project
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project add .
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project commit -m 'init'
export GIT_SSL_NO_VERIFY=1
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project push -u origin master


Перечисление объектов: 14, готово.
Подсчет объектов: 100% (14/14), готово.
При сжатии изменений используется до 8 потоков
Сжатие объектов: 100% (14/14), готово.
Запись объектов: 100% (14/14), 2.41 КиБ | 410.00 КиБ/с, готово.
Всего 14 (изменения 5), повторно использовано 0 (изменения 0)

 * [new branch]      master -> master
Ветка «master» отслеживает внешнюю ветку «master» из «origin».
```

`gitlab_02.sh`
```
# Применим теперь обновление по tag
# Cкопируем файл изменениями в папку c проектом wp-project

cp ../gitlab/resources/02-update/* ../gitlab/wp-project/
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project add .
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project commit -m 'update wordpress'
export GIT_SSL_NO_VERIFY=1
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project tag -a v1.0 -m 'version 1.0'
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project push
git --git-dir=../gitlab/wp-project/.git --work-tree=../gitlab/wp-project push --tags

```
После применения коммита по tag мы увидем изменения на сайте.

![](pics/pics/pic_7.png)
<br>

![](pics/pic_8.png) 
<br>

## Grafana
![](pics/pic_9.png)

## Prometheus
![](pics/pic_10.png)<br>
![](pics/pic_11.png)

## Alertmanager
![](pics/pic_12.png)
