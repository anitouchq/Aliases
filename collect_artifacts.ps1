# Collect real MySQL artifacts from the running assignment container.
$ErrorActionPreference = "Stop"
$container = "mysql_alias"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

docker inspect $container *> $null
if ($LASTEXITCODE -ne 0) {
    throw "Контейнер mysql_alias не найден. Сначала выполните команды запуска из README.md."
}

$running = docker inspect -f "{{.State.Running}}" $container
if ($running -ne "true") {
    throw "Контейнер mysql_alias не запущен. Запустите его командой: docker start mysql_alias"
}

Write-Host "Получение настоящего general.log из контейнера..."
docker cp "${container}:/var/lib/mysql/general.log" (Join-Path $root "general.log")
if ($LASTEXITCODE -ne 0) { throw "Не удалось скопировать general.log." }

Write-Host "Формирование фильтрованного лога SQL-действий..."
$patterns = 'CREATE DATABASE|CREATE TABLE|INSERT INTO|SELECT|UPDATE|DELETE|ALTER TABLE|DROP TABLE|SHOW TABLES'
Get-Content (Join-Path $root "general.log") |
    Select-String -Pattern $patterns |
    ForEach-Object { $_.Line } |
    Set-Content -Encoding utf8 (Join-Path $root "my_actions.log")

Write-Host "Экспорт базы alias_db через mysqldump..."
$dumpLines = docker exec $container sh -c 'MYSQL_PWD=123 mysqldump -uroot --default-character-set=utf8mb4 --single-transaction --routines --triggers --databases alias_db'
if ($LASTEXITCODE -ne 0) { throw "mysqldump завершился с ошибкой." }
$dumpText = ($dumpLines -join "`n") + "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path $root "alias_dump.sql"), $dumpText, $utf8NoBom)

Write-Host ""
Write-Host "Готово. Созданы/обновлены файлы:"
Write-Host " - general.log"
Write-Host " - my_actions.log"
Write-Host " - alias_dump.sql"
