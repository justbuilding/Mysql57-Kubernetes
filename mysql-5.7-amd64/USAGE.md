# MySQL 5.7 Kubernetes 部署使用文档 (支持 amd64 和 ARM64 架构)

本文档描述了如何使用提供的 Kubernetes 配置文件部署和管理 MySQL 5.7 数据库，适用于 amd64 (x86_64) 和 ARM64 (aarch64) 架构的服务器。

## 架构兼容性

**重要更新**：此配置现在支持 ARM64 架构！
- 使用阿里云容器镜像服务提供的 MySQL 5.7 ARM64 镜像
- 同时兼容 amd64 (x86_64) 架构
- 提供了 MySQL 5.7 在 ARM64 平台上的支持

## MySQL 5.7 ARM64 镜像

本配置使用阿里云容器镜像服务提供的 MySQL 5.7 ARM64 镜像：

### 镜像信息

- **镜像名称**：`registry.cn-hangzhou.aliyuncs.com/public_hjj_images/mysql:57arm64`
- **MySQL 版本**：5.7
- **支持架构**：ARM64 (aarch64) 和 amd64 (x86_64)
- **来源**：[阿里云容器镜像服务](https://cr.console.aliyun.com/)

### 镜像特性

- **默认密码**：123456
- **字符集**：utf8mb4
- **表名大小写**：不区分大小写
- **时区**：Asia/Shanghai

### 环境变量

- `MYSQL_ROOT_PASSWORD`：root 用户密码（默认：123456）

## MySQL 密码管理

### 修改 root 密码

部署后，建议修改默认密码以提高安全性：

1. **进入 Pod**：
   ```bash
   kubectl exec -it $(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- /bin/bash
   ```

2. **登录 MySQL**：
   ```bash
   mysql -u root -p123456
   ```

3. **修改密码**（示例：改为 MYSQL_ROOT_PASSWORD123456）：
   ```sql
   ALTER USER 'root'@'%' IDENTIFIED BY 'MYSQL_ROOT_PASSWORD123456';
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'MYSQL_ROOT_PASSWORD123456';
   GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
   GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';
   FLUSH PRIVILEGES;
   exit;
   ```

4. **验证新密码**：
   ```bash
   mysql -u root -pMYSQL_ROOT_PASSWORD123456
   ```

## 数据持久化

### 验证数据持久化

MySQL 数据存储在持久卷中，重启 Pod 后数据仍然存在：

1. **创建测试数据库**：
   ```sql
   CREATE DATABASE aaa;
   exit;
   ```

2. **重启 Pod**：
   ```bash
   kubectl rollout restart deployment mysql-deployment
   ```

3. **验证数据库存在**：
   ```sql
   SHOW DATABASES;
   ```

   结果应包含 `aaa` 数据库：
   ```
   +--------------------+
   | Database           |
   +--------------------+
   | information_schema |
   | aaa                |
   | mysql              |
   | performance_schema |
   | sys                |
   +--------------------+
   ```

### 存储配置

- **持久卷**：使用 `hostPath` 类型，路径为 `/data/mysql`
- **存储容量**：10Gi
- **访问模式**：ReadWriteOnce
- **存储类**：manual

## 部署前准备

1. **确保 Kubernetes 集群可用**
   - 目标服务器已安装并运行 Kubernetes
   - 可通过 `kubectl cluster-info` 验证集群状态

2. **准备存储目录**
   - 确保主机上存在 `/data/mysql` 目录
   - 如不存在，执行：`mkdir -p /data/mysql`

3. **文件位置**
   - 所有配置文件已复制到服务器的 `/root/` 目录

## 部署步骤

按以下顺序执行部署命令：

1. **创建持久卷 (PV)**
   ```bash
   kubectl apply -f /root/mysql-pv.yaml
   ```

2. **创建持久卷声明 (PVC)**
   ```bash
   kubectl apply -f /root/mysql-pvc.yaml
   ```

3. **部署 MySQL**
   ```bash
   kubectl apply -f /root/mysql-deployment.yaml
   ```

4. **创建服务**
   ```bash
   kubectl apply -f /root/mysql-service.yaml
   ```

## 验证部署

1. **检查 PV 和 PVC 状态**
   ```bash
   kubectl get pv,pvc
   ```
   确保状态为 `Bound`

2. **检查部署状态**
   ```bash
   kubectl get deployment mysql-deployment
   ```
   确保 `READY` 状态为 `1/1`

3. **检查服务状态**
   ```bash
   kubectl get service mysql-service
   ```
   确保服务已创建并分配了端口

4. **检查 Pod 状态**
   ```bash
   kubectl get pods -l app=mysql
   ```
   确保 Pod 状态为 `Running`

## 访问 MySQL

### 从集群外部访问

使用节点 IP 和 NodePort 端口 (30306) 访问：

```bash
mysql -h <节点IP> -P 30306 -u root -p
```

### 从集群内部访问

使用服务名称访问：

```bash
mysql -h mysql-service -P 3306 -u root -p
```

## 配置 MySQL

### 进入 Pod 内部

```bash
kubectl exec -it $(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- /bin/bash
```

### 修改 MySQL 密码和权限

默认密码为 `123456`，建议部署后修改为更安全的密码。

在 Pod 内部执行以下命令：

```bash
mysql -uroot -p123456

# 使用 mysql 数据库
USE mysql;

# 修改 root 用户密码（示例：改为 MYSQL_ROOT_PASSWORD123456）
ALTER USER 'root'@'%' IDENTIFIED BY 'MYSQL_ROOT_PASSWORD123456';
ALTER USER 'root'@'localhost' IDENTIFIED BY 'MYSQL_ROOT_PASSWORD123456';

# 授权
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';

# 刷新权限
FLUSH PRIVILEGES;

# 退出后使用新密码登录
# mysql -uroot -pMYSQL_ROOT_PASSWORD123456
```

### 解决旧客户端连接问题

如果使用旧客户端连接 MySQL 8 出现认证错误，执行：

```bash
ALTER USER 'root'@'%' IDENTIFIED WITH 'mysql_native_password' BY '密码';
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '密码';
FLUSH PRIVILEGES;
```

## 数据备份与恢复

### 备份数据

```bash
# 从 Pod 中备份所有数据库
kubectl exec $(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- mysqldump --all-databases -uroot -p'密码' > /root/all-databases.sql

# 备份特定数据库
kubectl exec $(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- mysqldump -uroot -p'密码' 数据库名 > /root/数据库名.sql
```

### 恢复数据

```bash
# 将备份文件复制到 Pod 内部
kubectl cp /root/备份文件.sql $(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}'):/tmp/

# 在 Pod 内部恢复数据
kubectl exec -it $(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- mysql -uroot -p'密码' 数据库名 < /tmp/备份文件.sql
```

## 管理操作

### 查看 Pod 日志

```bash
kubectl logs $(kubectl get pods -l app=mysql -o jsonpath='{.items[0].metadata.name}')
```

### 重启 MySQL

```bash
kubectl rollout restart deployment mysql-deployment
```

### 扩缩容

```bash
# 查看当前副本数
kubectl get deployment mysql-deployment

# 调整副本数（MySQL 通常只需要一个副本）
kubectl scale deployment mysql-deployment --replicas=1
```

### 删除部署

```bash
# 按顺序删除资源
kubectl delete service mysql-service
kubectl delete deployment mysql-deployment
kubectl delete pvc mysql-pvc
kubectl delete pv mysql-pv
```

## 常见问题与解决方案

### 1. PVC 无法绑定到 PV

**原因**：PV 和 PVC 的存储类或选择器不匹配

**解决方案**：
- 检查 `storageClassName` 是否一致
- 检查 `selector` 标签是否匹配
- 确保 PV 处于 `Available` 状态

### 2. Pod 启动失败

**原因**：可能是存储权限问题或配置错误

**解决方案**：
- 查看 Pod 日志：`kubectl logs <pod-name>`
- 检查存储目录权限：`chmod 777 /data/mysql`
- 确保 MySQL 密码设置正确

### 3. 无法连接到 MySQL

**原因**：网络配置问题或 MySQL 权限设置错误

**解决方案**：
- 检查服务是否正常：`kubectl get service mysql-service`
- 验证 NodePort 是否可访问：`telnet <节点IP> 30306`
- 检查 MySQL 权限设置

### 4. 数据丢失

**原因**：持久卷配置错误或未正确挂载

**解决方案**：
- 确保 PV 使用了正确的存储类型
- 验证数据是否存储在 `/data/mysql` 目录
- 定期执行数据备份

## 配置说明

### MySQL 配置参数

部署中使用了以下 MySQL 配置参数：

- `--lower-case-table-names=1`：表名不区分大小写
- `--character-set-server=utf8mb4`：使用 UTF-8 字符集
- `--collation-server=utf8mb4_general_ci`：使用 UTF-8 校对规则

### 存储配置

- PV 容量：10Gi
- 访问模式：ReadWriteOnce
- 存储类型：hostPath（仅用于开发测试环境）
- 挂载路径：`/var/lib/mysql`

### 网络配置

- 容器端口：3306
- 服务类型：NodePort
- 节点端口：30306

## 注意事项

1. **版本兼容性（重要）**：
   - **MySQL 不支持版本降级**：如果持久卷中已存在来自更高版本 MySQL 的数据，使用较低版本的容器会失败
   - **错误示例**：`Invalid MySQL server downgrade: Cannot downgrade from 90600 to 80045`
   - **解决方案**：使用与现有数据版本匹配的 MySQL 容器版本
   - **建议**：记录并保持 MySQL 版本的一致性

2. **生产环境建议**：
   - 使用更可靠的存储解决方案（如 NFS、Ceph 等）
   - 配置 MySQL 主从复制以提高可用性
   - 使用 Secret 管理敏感信息（如密码）

3. **性能优化**：
   - 根据实际需求调整 PV 容量
   - 考虑使用 StatefulSet 而非 Deployment 以获得更稳定的网络标识

4. **安全性**：
   - 定期更新 MySQL 密码
   - 限制 MySQL 服务的访问范围
   - 启用 MySQL 日志审计

---

本部署方案基于 amd64 (x86_64) 架构，使用 `mysql:5.7` 镜像，适用于 x86_64 架构的服务器。

## MySQL 5.7 特性

- **认证插件**：默认使用 `mysql_native_password`
- **密码策略**：相对宽松，便于测试环境使用
- **JSON 支持**：开始支持 JSON 类型
- **稳定性**：经过广泛验证的稳定版本

## 架构限制

- **仅支持 amd64**：此配置不适用于 ARM64 服务器
- **无官方 ARM64 支持**：MySQL 5.7 官方未提供 ARM64 镜像
- **ARM64 替代方案**：请使用 `mysql-9.6.0-arm` 目录中的 MySQL 9.6.0 配置