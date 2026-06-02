#!/usr/bin/env bash
set -e

echo "===== Backup ====="
cp docker-compose.yml docker-compose.yml.bak.$(date +%Y%m%d_%H%M%S)

echo ""
echo "===== Trecho com problema antes ====="
nl -ba docker-compose.yml | sed -n '300,350p'

echo ""
echo "===== Corrigindo CELERY_RESULT_BACKEND sem espaço ====="
sed -i 's/CELERY_RESULT_BACKEND:"/CELERY_RESULT_BACKEND: "/g' docker-compose.yml

echo ""
echo "===== Trecho após correção ====="
nl -ba docker-compose.yml | sed -n '300,350p'

echo ""
echo "===== Validando docker compose config ====="
docker compose config >/tmp/optiflow_compose_config_ok.yml

echo "OK: docker-compose.yml válido."

echo ""
echo "===== Subindo serviços base ====="
docker compose up --build -d timescaledb redis gateway historian context

echo ""
echo "===== Aguardando startup ====="
sleep 30

echo ""
echo "===== Status ====="
docker compose ps

echo ""
echo "===== Logs gateway ====="
docker compose logs --tail=80 gateway

echo ""
echo "===== Logs historian ====="
docker compose logs --tail=80 historian

echo ""
echo "===== Logs context ====="
docker compose logs --tail=80 context

echo ""
echo "===== Health ====="
curl -s http://localhost:8080/api/health || true
echo ""
curl -s http://localhost:8100/health || true
echo ""
curl -s http://localhost:8200/health || true
echo ""
