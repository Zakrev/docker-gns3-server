# Проект для запуска GNS3 с поддержкой Docker в Docker контейнере

## Управление

Смотри `script/control.sh`.

```bash
# Открыть GNS3 в браузере
script/control.sh open

# Запустить/остановить Docker контейнер с GNS3
script/control.sh start
script/control.sh stop

# Создать интерфейс для связи хост<->GNS3
script/control.sh create_iface

# Подключиться к Docker контейнеру с GNS3 и перейти в host-files
script/control.sh console

# Собрать контейнер
script/control.sh build
```

## host-files

В каталоге `./host-files` (появится после запуска контейнера) хранятся файлы хоста, например Docker файлы для сборки внутри контейнера.
