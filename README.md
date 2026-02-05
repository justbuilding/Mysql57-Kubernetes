# MySQL Kubernetes Deployments for Aarch64 (Kylin10) Or Amd64 (Ubuntu/Centos)

This repository contains Kubernetes deployment configurations for MySQL databases optimized for ARM64 architecture, specifically for KylinOS V10 on Aarch64 servers.

## 目录结构

```
.
├── mysql-5.7-amd64/         # MySQL 5.7 for AMD64 architecture
│   ├── README.md             # Deployment-specific documentation
│   └── Kubernetes files
├── mysql-5.7-arm64/         # MySQL 5.7 for ARM64 architecture
│   ├── README.md             # Deployment-specific documentation
│   └── Kubernetes files
├── mysql-9.6.0-arm64/        # MySQL 9.6.0 for ARM64 architecture
│   ├── README.md             # Deployment-specific documentation
│   └── Kubernetes files
├── README.md                 # Main documentation
└── USAGE.md                  # General usage documentation
```

## 部署说明

### MySQL 5.7 (AMD64) 部署

**支持架构**：仅 AMD64

**镜像信息**：
- MySQL 5.7 (AMD64): `registry.cn-hangzhou.aliyuncs.com/public_hjj_images/mysql:57amd64`

**部署步骤**：
```bash
cd mysql-5.7-amd64
kubectl apply -f mysql-pv.yaml
kubectl apply -f mysql-pvc.yaml
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml
```

### MySQL 5.7 (ARM64) 部署

**支持架构**：仅 ARM64

**镜像信息**：
- MySQL 5.7 (ARM64): `registry.cn-hangzhou.aliyuncs.com/public_hjj_images/mysql:57arm64`

**部署步骤**：
```bash
cd mysql-5.7-arm64
kubectl apply -f mysql-pv.yaml
kubectl apply -f mysql-pvc.yaml
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml
```

### MySQL 9.6.0 (ARM64) 部署

**支持架构**：仅 ARM64

**镜像信息**：
- MySQL 9.6.0 (ARM64): `registry.cn-hangzhou.aliyuncs.com/public_hjj_images/mysql9.6.0:arm64`

**部署步骤**：
```bash
cd mysql-9.6.0-arm64
kubectl apply -f mysql-pv.yaml
kubectl apply -f mysql-pvc.yaml
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml
```

## 存储配置

所有部署使用持久卷存储 MySQL 数据：

- **存储路径**：`/data/k8s/mysql`
- **存储容量**：10Gi
- **访问模式**：ReadWriteOnce
- **存储类型**：hostPath（仅用于开发测试环境）

## 网络配置

- **MySQL 服务端口**：3306
- **NodePort**：30306
- **服务类型**：NodePort

## 密码配置

请参照以下配置信息，并根据需要修改密码：

### MySQL 5.7 (AMD64)
- **密码类型**：root 密码
- **默认密码**：root
- **环境变量**：无需设置密码环境变量

### MySQL 5.7 (ARM64)
- **密码类型**：空密码
- **默认密码**：无（直接登录）
- **环境变量**：无需设置密码环境变量

### MySQL 9.6.0 (ARM64)
- **密码类型**：root 密码
- **默认密码**：123456
- **环境变量**：`MYSQL_ROOT_PASSWORD`

## 版本兼容性

- **MySQL 5.7 (AMD64)**：仅支持 AMD64 架构
- **MySQL 5.7 (ARM64)**：仅支持 ARM64 架构
- **MySQL 9.6.0 (ARM64)**：仅支持 ARM64 架构

## 注意事项

1. **目录创建**：部署前请确保宿主机上存在 `/data/k8s/mysql` 目录
   ```bash
   mkdir -p /data/k8s/mysql
   chmod 755 /data/k8s/mysql
   ```

2. **权限设置**：确保目录权限正确，MySQL 进程需要读写权限

3. **数据迁移**：从旧版本迁移数据时，请使用 `mysqldump` 进行备份和恢复

4. **版本降级**：MySQL 不支持版本降级，请谨慎操作

5. **镜像拉取**：首次部署时会拉取镜像，可能需要一些时间

## 镜像来源

所有镜像均来自阿里云容器镜像服务，提供更快的拉取速度和更好的稳定性：

- MySQL 5.7 (AMD64): `registry.cn-hangzhou.aliyuncs.com/public_hjj_images/mysql:57amd64`
- MySQL 5.7 (ARM64): `registry.cn-hangzhou.aliyuncs.com/public_hjj_images/mysql:57arm64`
- MySQL 9.6.0 (ARM64): `registry.cn-hangzhou.aliyuncs.com/public_hjj_images/mysql9.6.0:arm64`

## 故障排除

### 常见问题

1. **镜像拉取失败**：
   - 检查网络连接
   - 确认阿里云镜像仓库地址正确
   - 验证节点架构是否为 ARM64

2. **存储挂载失败**：
   - 确认 `/data/k8s/mysql` 目录存在
   - 检查目录权限

3. **服务无法访问**：
   - 检查 NodePort 配置
   - 验证防火墙规则
   - 查看 Pod 状态和日志

### 查看日志

```bash
# 查看 MySQL 5.7 日志
kubectl logs -l app=mysql -n default

# 查看 MySQL 9.6.0 日志
kubectl logs -l app=mysql -n default
```

## 版本信息

- **MySQL 5.7**：稳定版本，支持多架构
- **MySQL 9.6.0**：最新版本，针对 ARM64 优化

## 适用场景

- **开发测试**：快速部署 MySQL 实例
- **生产环境**：建议使用持久化存储和高可用配置
- **国产化环境**：针对 KylinOS V10 on Aarch64 优化

## 维护说明

- 定期备份数据
- 监控数据库性能
- 根据业务需求调整资源配置
- 及时更新镜像版本以获取安全补丁

---


**更新时间**：2026-02-05
