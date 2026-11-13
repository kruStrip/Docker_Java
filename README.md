# Docker + Java

Минимальный пример: как собрать Java-приложение в контейнер и проверить его отдельной конфигурацией.

**Стек:** Java · Docker

## Что внутри

- `App.java` — приложение
- `Dockerfile` — образ для запуска
- `test.Dockerfile` — отдельная конфигурация для проверки

## Запуск

```bash
javac App.java && java App
docker build -t java-app .
docker run --rm java-app
```
