при развертывании на сервере не забываем про .env файл - его нужно создавать там вручную

не забываем (потом поправим в докере) сделать файлы исполняемыми, в каждой из папок:
chmod +x docker-entrypoint.sh

----


для запуска на локальном компе:
docker-compose -f docker-compose-dev.yml up -d --build
(с отображением консоли)
docker-compose -f docker-compose-dev.yml up --build

для запуска на боевом сервере:
docker-compose -f docker-compose.yml up -d --build

----
cloud.canister.io:5000/ffyy289/ppay_app:latest

----
docker system prune --volumes


скрываем консоль (-d):
docker-compose -f docker-compose.yml up -d --build

не скрываем консоль:
docker-compose -f docker-compose.yml up --build

заходим в работающий контейнер:
root@299119:~/repos/ppay_repo# docker-compose exec app sh

