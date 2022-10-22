при развертывании на сервере не забываем про .env файл - его нужно создавать там вручную

не забываем (потом поправим в докере) сделать файлы исполняемыми, в каждой из папок:
chmod +x docker-entrypoint.sh

----


для запуска на локальном компе:
docker-compose -f docker-compose-dev.yml up -d --build

для запуска на боевом сервере:
docker-compose -f docker-compose.yml up -d --build