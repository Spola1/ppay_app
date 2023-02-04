## Запуск локально


```bash
bundle
bin/setup
bin/dev
```

## Запуск в докере

#### Подготовка проекта

Создать `.env` и `.env.dev`

```bash
touch ppay_app/.env
cp ppay_app/.env.dev.example ppay_app/.env.dev
```

#### Заупск контейнеров

```bash
docker-compose -f docker-compose-dev.yml up --build
```

---

### Как зайти в:

#### Работающий контейнер

```bash
docker-compose exec app bash
```

#### Консоль

```bash
docker-compose exec app bin/rails c
```

#### Логи `sidekiq`

```bash
docker-compose logs worker
```


## Примечания и комментарии

#### По контейнеру `cron`:

`cron` запускает `perform_async` и этим кладёт сообщение в `redis`.
Потом в отдельном контейнере `worker` выполняются задачи с помощью `sidekiq`.

В контейнере `cron` логи самого `cron` не видно, они лежат отдельно.

В контейнер `sidekiq` попадают воркеры и с сервера, и с крона.
