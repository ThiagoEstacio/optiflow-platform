# OPERA · Simulador VRP — Demo executiva (15 min)

## Pré-requisitos
- Docker 24+ e Docker Compose v2.
- Portas livres: 1883, 5173, 5432, 8000, 8883, 9090, 3000.
- `mosquitto-clients` instalado (opcional, para inspeção CLI).

## Setup (10 min antes da reunião)

```bash
git clone <repo> opera-vrp-simulator && cd opera-vrp-simulator
cp .env.example .env
docker compose up -d --build
```

Aguarde 60 s e valide:

```bash
curl -s localhost:8000/api/health | jq
mosquitto_sub -h localhost -p 1883 -t '#' -C 5 -v
```

## Roteiro (15 min)

| t (mm:ss) | Ato | Ação | O que apontar |
|-----------|-----|------|---------------|
| 00:00 | Abertura | Browser em :5173 | 20 pinos verdes + R-CENTRAL |
| 02:00 | Inspector MQTT | Aba Inspector, filtro `VRP-SAO-` | "São os bytes voando agora — payload Vectora idêntico ao real" |
| 04:00 | Cenário 4 (vazamento) | Painel Cenários → vazamento em VRP-SAO-004 | Pino amarelo; pj cai, vz sobe |
| 06:00 | Cenário 6 (comm-loss) | Falha comm em VRP-GUA-001 e 002 | Pinos vermelhos; LWT no Inspector |
| 08:00 | Cenário 11 (falha de adução) | Toggle 5 min | h cai; 20 VRPs perdem p_mont juntas; zona alta perde setpoint primeiro |
| 11:00 | Round-trip de comando | Slider VRP-SAO-001 → 22 mca | Toast com Ack em ms; pj converge em 6–8 s |
| 12:30 | Health & escala | Grafana → painel Health | msgs/s estável, P95 < 800 ms |
| 14:00 | Fechamento | — | "Mesma stack que vai para produção" |

## Recuperação
- Se um painel não atualiza: refresh do browser (WS reconnect).
- Se um cenário travar: `docker compose restart simulator` (recupera estado em ~5 s graças a Config retain).
- Logs: `docker compose logs -f api ingestor simulator opera-bridge`.

## Encerramento

```bash
docker compose down -v   # remove volumes para próxima demo limpa
```
