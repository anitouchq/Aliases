# SQL Aliases

Практическая работа по теме **SQL Aliases (псевдонимы таблиц и столбцов)** на MySQL 8.0.

## Содержание

- [Цель работы](#цель-работы)
- [Структура проекта](#структура-проекта)
- [Требования](#требования)
- [1. Конфигурация MySQL](#1-конфигурация-mysql)
- [2. Запуск MySQL в Docker](#2-запуск-mysql-в-docker)
- [3. Выполнение SQL-заданий](#3-выполнение-sql-заданий)
- [4. Получение логов и дампа](#4-получение-логов-и-дампа)
- [5. Результаты](#5-результаты)
- [Вывод](#вывод)

## Цель работы

Изучить применение псевдонимов (aliases) в SQL: переименование столбцов и таблиц, использование псевдонимов в JOIN и self-join, подзапросах, группировке, сортировке и фильтрации. Отдельно проверить неоднозначные имена столбцов и ограничения использования псевдонимов в WHERE.

## Структура проекта

```text
Aliases/
├── README.md
├── my.cnf
├── aliases.sql
├── alias_dump.sql
├── collect_artifacts.ps1
├── general.log          # создаётся после реального запуска
├── my_actions.log       # создаётся после реального запуска
└── screenshots/
    ├── 01-container.png
    ├── 02-database-tables.png
    ├── 03-inserted-data.png
    ├── 04-table-column-aliases.png
    ├── 05-joins.png
    ├── 06-self-join.png
    ├── 07-subqueries.png
    ├── 08-group-by-having.png
    └── 09-logs-and-dump.png
```

## Требования

- Docker Desktop
- MySQL 8.0 (образ Docker `mysql:8.0`)
- Windows PowerShell
- Git Bash (необязательно)

## 1. Конфигурация MySQL

В файле `my.cnf` заданы кодировка UTF-8, включённый общий журнал запросов (General Query Log) и запись журнала в файл `/var/lib/mysql/general.log`.

## 2. Запуск MySQL в Docker

Откройте PowerShell в каталоге репозитория и выполните:

```powershell
docker volume create mysql_alias_data

docker run --name mysql_alias `
  -e MYSQL_ROOT_PASSWORD=123 `
  -v mysql_alias_data:/var/lib/mysql `
  -v "${PWD}/my.cnf:/etc/mysql/conf.d/my.cnf:ro" `
  -d mysql:8.0
```

Проверьте контейнер:

```powershell
docker ps
docker logs mysql_alias
```

Дождитесь сообщения о готовности MySQL принимать подключения.

## 3. Выполнение SQL-заданий

Скопируйте SQL-файл в контейнер:

```powershell
docker cp .\aliases.sql mysql_alias:/tmp/aliases.sql
```

Очистите журнал перед выполнением практической части, чтобы в нём остались записи текущего запуска:

```powershell
docker exec mysql_alias sh -c "truncate -s 0 /var/lib/mysql/general.log"
```

Выполните SQL-файл:

```powershell
docker exec mysql_alias sh -c "mysql --default-character-set=utf8mb4 -uroot -p123 < /tmp/aliases.sql"
```

В файле `aliases.sql` находятся команды создания базы `alias_db`, таблиц `customers`, `orders`, `employees`, заполнения тестовыми данными и практические запросы по aliases.

Проверить созданные таблицы можно так:

```powershell
docker exec -it mysql_alias mysql -uroot -p123 -e "USE alias_db; SHOW TABLES;"
```

## 4. Получение логов и дампа

После успешного выполнения SQL-файла запустите скрипт:

```powershell
.\collect_artifacts.ps1
```

Скрипт извлечёт из работающего контейнера настоящий General Query Log, сформирует фильтрованный лог запросов и экспортирует базу командой `mysqldump`. Полученные файлы будут сохранены в корне репозитория.

Если скрипт не запускается из-за политики PowerShell, выполните:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\collect_artifacts.ps1
```

Файлы `general.log`, `my_actions.log` и `alias_dump.sql` после этого должны быть получены из вашего контейнера. Не заменяйте их вручную набранными примерами: лог должен отражать реальное выполнение запросов.

## 5. Результаты
<img width="523" height="280" alt="2" src="https://github.com/user-attachments/assets/f8dc67c3-5597-4f05-8199-8624adca8293" />
<img width="1041" height="257" alt="1" src="https://github.com/user-attachments/assets/6bd335e5-1401-4152-8cd2-a69adf4d1e49" />
<img width="856" height="272" alt="3" src="https://github.com/user-attachments/assets/d4600a2e-6abf-4432-bed7-0fd1692e3fbf" />
<img width="497" height="233" alt="4" src="https://github.com/user-attachments/assets/76c04209-1b9c-4c12-a788-82b307cec088" />
<img width="407" height="207" alt="5" src="https://github.com/user-attachments/assets/a4649f06-9aea-4b72-904a-f04bfeb84a2d" />
<img width="245" height="263" alt="6" src="https://github.com/user-attachments/assets/16c72875-c2f5-4db1-86fa-879b53de58c6" />
<img width="387" height="167" alt="7" src="https://github.com/user-attachments/assets/ff433423-4d42-4e27-b27a-3d03c6d0c4f8" />
<img width="452" height="230" alt="8" src="https://github.com/user-attachments/assets/82d3500e-0c75-458e-aa54-96624d4c87b9" />
<img width="640" height="177" alt="9" src="https://github.com/user-attachments/assets/e5dd47ba-b796-419d-98d7-773797bf8732" />
<img width="577" height="197" alt="10" src="https://github.com/user-attachments/assets/9a0005d2-daa9-4438-b2f7-b636882afecd" />




## Вывод

В ходе работы рассмотрены псевдонимы таблиц и столбцов, их применение при соединении таблиц, включая self-join, в производных таблицах и подзапросах. Проверено использование aliases в ORDER BY, GROUP BY и HAVING. Также рассмотрено ограничение: псевдоним столбца из SELECT нельзя использовать в WHERE на том же уровне запроса; для фильтрации можно повторить выражение либо обернуть запрос в производную таблицу.
