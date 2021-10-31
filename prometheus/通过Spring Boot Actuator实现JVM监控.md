# 通过Spring Boot Actuator 实现Spring Boot应用的JVM监控
## 一、简介
### 1.1 目标
将Spring Boot应用在运行过程中的JVM指标参数暴露出来，并通过工具收集展示，以供应用运行状况分析和应用预警。

### 1.2 工具介绍
#### 1.2.1 Spring Boot Actuator
Spring 官方提供给Spring Boot应用来监控管理的插件，主要功能是应用审计、应用健康、指标收集。暴露指标的方式有HTTP和JMX两种。

在本文中的主要作用是应用指标暴露。

[官网地址](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)

#### 1.2.2 Prometheus	
Prometheus 是由 SoundCloud 开源监控告警解决方案。
Prometheus 存储的是时序数据，即按相同时序(相同名称和标签)，以时间维度存储连续的数据的集合。

其数据查询使用的是PromQL，是Prometheus自己开发的数据查询DSL语言。

在本文中的主要作用是指标收集与存储。

[官网地址](https://prometheus.io)

#### 1.2.3 Grafana
Grafana是一款用Go语言开发的开源数据可视化工具，可以做数据监控和数据统计，带有告警功能。

在本文中的主要作用是指标的图形化展示。

[官网地址](https://grafana.com)

##  二、操作步骤
### 2.1 pom中增加maven依赖
```xml
pom.xml

<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
        <groupId>io.micrometer</groupId>
        <artifactId>micrometer-registry-prometheus</artifactId>
    </dependency>
</dependencies>
```

### 2.2 application.properities中添加配置
开启除shutdown以外的所有endpoint，并给这些指标打上应用名的tag

```
application.properities

spring.application.name=readme
management.endpoints.web.exposure.include=*
management.endpoints.web.exposure.exclude=shutdown
management.metrics.tags.application=${spring.application.name}
management.endpoint.health.show-details=always
```
### 2.3 暴露JVM指标
在工程的启动主类中添加如下Bean来监控JVM性能指标：

```
@SpringBootApplication
@EnableAspectJAutoProxy
@EnableTransactionManagement
@EnableJpaRepositories(repositoryBaseClass = BaseRepositoryImpl.class)
public class ReadmeApplication {

    public static void main(String[] args) {
        SpringApplication.run(ReadmeApplication.class, args);
    }

    @Bean
    MeterRegistryCustomizer<MeterRegistry> configurer(@Value("${spring.application.name}") String applicationName) {
        return meterRegistry -> meterRegistry.config().commonTags("application", applicationName);
    }
}
```

启动应用后访问http://localhost:8080/actuator/prometheus

### 2.4 配置Prometheus
Prometheus配置文件中增加数据收集目标，其中https和tls的配置按需添加。添加后重启Prometheus。

```yaml
prometheus.yml
- job_name: 'application'
  scheme: https
  tls_config: 
    insecure_skip_verify: true
  static_configs:
  - targets: ['readme.jason.com']
  metrics_path: '/actuator/prometheus'
```

### 2.5 配置Grafana面板
添加监控面板，面板ID：4701。导入模板时选择对应数据源即可。
