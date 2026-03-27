# Первая стадия — стадия сборки
FROM amazoncorretto:25-jdk AS builder

# Устанавливаем необходимые утилиты
RUN yum update -y && yum install -y wget unzip tar gzip sed findutils

# Скачиваем и распаковываем Gradle
RUN wget https://services.gradle.org/distributions/gradle-9.4.0-bin.zip -O gradle.zip && \
    unzip gradle.zip -d /opt/gradle && \
    rm gradle.zip

# Добавляем Gradle в PATH
ENV GRADLE_PATH=/opt/gradle/gradle-9.4.0
ENV PATH=${PATH}:${GRADLE_PATH}/bin

# Устанавливаем рабочую директорию
WORKDIR /app

# Создаем проект Gradle
RUN gradle init --type java-application --dsl groovy --package com.test.springapp \
    --project-name springapp --no-split-project --no-incubating

# Удаляем сгенерированные файлы по умолчанию (чтобы не было конфликтов с нашим App.java)
RUN rm -rf app/src/main/java/com/test/springapp/* app/src/test/java/com/test/springapp/*

# Копируем наш файл App.java в контейнер
COPY App.java app/src/main/java/com/test/springapp/App.java

# Модифицируем файл build.gradle с помощью sed
RUN sed -i \
    -e "/dependencies {/a     implementation 'org.springframework.boot:spring-boot-starter-web'" \
    -e "/plugins {/a     id 'org.springframework.boot' version '4.0.1'" \
    -e "\$a apply plugin: 'io.spring.dependency-management'" app/build.gradle

# Запускаем сборку проекта и выделяем Spring Boot fat jar (он большего размера)
RUN gradle build -x test && \
    FAT_JAR=$(ls -S app/build/libs/*.jar | head -n 1) && \
    cp "$FAT_JAR" /app/app.jar

# Вторая стадия — стадия запуска
FROM amazoncorretto:25-jdk

# Устанавливаем рабочую директорию
WORKDIR /app

# Скопируем собранный .jar файл из первой стадии
COPY --from=builder /app/app.jar .

# Проброс порта (документационно)
EXPOSE 8080

# Команда для запуска нашего Spring Boot приложения
CMD ["java", "-jar", "app.jar"]
