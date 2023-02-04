```
touch ppay_app/.env
cp ppay_app/.env.dev.example ppay_app/.env.dev
```

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



-----
просмотр логов контейнера с sidekiq:

root@299119:~/repos/ppay_repo# docker-compose logs worker

-----

комментарии по контейнеру cron:

крон просто запускает perform_async и этим кладёт в редис
потом уже в сайдкике из редиса задачи включаются
сайдкик это другой контейнер

есть лог крона какой-то - если ты его запустишь в воркере, то ничего не видно будет из лога, будет только лог сайдкика

сайдкик и крон вообще не обязаны вместе работать
в сайдкик воркеры попадают и с сервера, не только из крона

------
