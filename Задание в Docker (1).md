

Работа по Multi-Stage сборке в Docker
В  данном  задании  вам  будет  необходимо  выполнить Multi-Stage сборку  в Docker для
приложения на фреймворке Spring Boot (язык Java).

Определение начальных условий
Создайте Dockerfile для  создания  образа  для  сборки  и  запуска  простого  приложения.
Используйте следующий фрагмент кода в качестве основного файла для запуска приложения
## (файл App.java):
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@SpringBootApplication
public class App {
@GetMapping("/")
public String hello() {
return "Hello from Spring Boot!";
## }

public static void main(String[] args) {
SpringApplication.run(App.class, args);
## }
## }

Шаги создания Dockerfile состоят из двух стадий.
Первая стадия — стадия сборки, включает следующие шаги:
- В качестве базового образа используйте один из образов с Docker Hub с установленным Java
Development Kit (например, amazoncorretto:25-jdk).
- Установите   сборочную   систему Gradle (последняя   версия   с GitHub:
https://github.com/gradle/gradle-distributions/releases/tag/v9.4.0). Для  скачивания  архива
можно воспользоваться wget или curl, распаковать архив в любую удобную директорию с
помощью unzip, например в /opt/gradle/.
- Добавьте в переменную окружения PATH путь до исполняемого файла gradle. Например,
командами
export GRADLE_PATH=/opt/gradle/gradle-9.4.0 && \
export PATH=$(PATH):$(GRADLE_PATH)/bin
- Создайте отдельную папку и используйте ее в качестве рабочей директории. Внутри нее
создайте проект Gradle:

gradle init --type java-application --dsl groovy --package com.test.springapp \
--project-name springapp --no-split-project --no-incubating
- Скопируйте файл App.java в контейнер по пути src/main/java/com/test/springapp/.
- Модифицируйте файл build.gradle: необходимо добавить в зависимости Spring Boot, для
этого требуется вставить несколько строк в секции зависимостей и плагинов. Для этого можно
воспользоваться sed:
sed -i \
-e "/dependencies {/a implementation 'org.springframework.boot:spring-boot-starter-web'" \
-e "/plugins {/a id 'org.springframework.boot' version '4.0.1'" \
-e "$a apply plugin: 'io.spring.dependency-management'" build.gradle
- Запустить сборку проекта:
gradle build -x test
Собранный .jar-файл будет находиться по пути build/libs.
Вторая стадия — стадия запуска, включает следующие шаги:
- В качестве базового образа используйте один из образов с Docker Hub с установленным Java
Runtime Environment (можно оставить amazoncorretto:25-jdk).
- Скопируйте .jar файл из предыдущей стадии в данный образ. Можете его переименовать,
например в app.jar.
- Определите команду для запуска .jar файла:
java -jar app.jar

Запуск контейнера
- Запустите контейнер с пробросом на хост порта 8080.
- Перейдите в браузере по адресу localhost:8080. Вы должны увидеть ответ сервиса.