# OPERA — Simulador VRP RMSP

Simulador hidráulico dinâmico: 1 reservatório central (R-CENTRAL) acoplado a 20 VRPs Vectora
curadas na RMSP, com publicação MQTT bidirecional fiel à taxonomia KXO/SCOA da Sabesp.

Ver página de spec no Notion para arquitetura, princípios de fidelidade e roadmap.

## Subir o ambiente

    cp .env.example .env
    docker compose up --build

## Mudar setpoint via MQTT (round-trip)

    curl -X POST http://localhost:8000/api/vrps/VRP-SAO-001/setpoint \
         -H 'Content-Type: application/json' \
         -d '{"sp": 22.0, "actor": "cli:test"}'

## Inspecionar broker

    mosquitto_sub -h localhost -p 1883 -t '#' -v